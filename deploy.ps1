# Manufacturing Business Application - Deploy Script
param(
    [string]$ImageName = "manufacturing-business-app",
    [string]$ContainerName = "manufacturing-business-container", 
    [int]$Port = 8082,
    [switch]$SkipBuild,
    [switch]$CleanUp,
    [switch]$Help
)

if ($Help) {
    Write-Host "Manufacturing Business Application - Deploy Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -ImageName      Docker image name (default: manufacturing-business-app)" -ForegroundColor White
    Write-Host "  -ContainerName  Docker container name (default: manufacturing-business-container)" -ForegroundColor White
    Write-Host "  -Port           Host port to map to container port 80 (default: 8082)" -ForegroundColor White
    Write-Host "  -SkipBuild      Skip Angular build step" -ForegroundColor White
    Write-Host "  -CleanUp        Remove existing containers and images before deploy" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\deploy.ps1                           # Basic deployment" -ForegroundColor White
    Write-Host "  .\deploy.ps1 -Port 9000               # Deploy on port 9000" -ForegroundColor White
    Write-Host "  .\deploy.ps1 -CleanUp                 # Clean up and redeploy" -ForegroundColor White
    Write-Host "  .\deploy.ps1 -SkipBuild               # Skip Angular build" -ForegroundColor White
    exit 0
}

Write-Host "Manufacturing Business Application - Deploy" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Cyan
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running" -ForegroundColor Red
    exit 1
}
Write-Host "Docker is running" -ForegroundColor Green

# Cleanup if requested
if ($CleanUp) {
    Write-Host "Cleaning up existing resources..." -ForegroundColor Cyan
    docker stop $ContainerName 2>$null | Out-Null
    docker rm $ContainerName 2>$null | Out-Null
    docker rmi $ImageName 2>$null | Out-Null
    Write-Host "Cleanup completed" -ForegroundColor Green
}

# Build Angular app
if (-not $SkipBuild) {
    Write-Host "Building Angular application..." -ForegroundColor Cyan
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Angular build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "Angular build completed" -ForegroundColor Green
} else {
    Write-Host "Skipping Angular build" -ForegroundColor Yellow
}

# Stop existing container
Write-Host "Stopping existing container..." -ForegroundColor Cyan
docker stop $ContainerName 2>$null | Out-Null
docker rm $ContainerName 2>$null | Out-Null

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Cyan
docker build -t $ImageName .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "Docker image built successfully" -ForegroundColor Green

# Run container
Write-Host "Starting container on port $Port..." -ForegroundColor Cyan
$containerId = docker run -d -p "${Port}:80" --name $ContainerName $ImageName

if ($containerId) {
    Write-Host ""
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "URL: http://localhost:$Port" -ForegroundColor Yellow
    Write-Host "Container ID: $containerId" -ForegroundColor Blue
    Write-Host "Container Name: $ContainerName" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  Status:  .\status.ps1" -ForegroundColor White
    Write-Host "  Logs:    docker logs $ContainerName" -ForegroundColor White
    Write-Host "  Cleanup: .\cleanup.ps1" -ForegroundColor White
} else {
    Write-Host "Error: Failed to start container" -ForegroundColor Red
    exit 1
}