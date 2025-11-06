# Manufacturing Business Application - Status Check
param(
    [string]$ContainerName = "manufacturing-business-container",
    [int]$Port = 8082,
    [switch]$Help
)

if ($Help) {
    Write-Host "Manufacturing Business Application - Status Check" -ForegroundColor Green
    Write-Host "Usage: .\status.ps1 [-ContainerName name] [-Port port] [-Help]" -ForegroundColor Yellow
    exit 0
}

Write-Host "🏭 Manufacturing Business Application Status" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Check Docker service
Write-Host "🐳 Checking Docker..." -ForegroundColor Cyan
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ Docker is not running" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ Docker is running" -ForegroundColor Green

# Check container status
Write-Host "📦 Checking Container..." -ForegroundColor Cyan
$container = docker ps --filter "name=$ContainerName" --format "{{.ID}}"
if ($container) {
    $status = docker ps --filter "id=$container" --format "{{.Status}}"
    $ports = docker ps --filter "id=$container" --format "{{.Ports}}"
    
    Write-Host "   ✅ Container: Running" -ForegroundColor Green
    Write-Host "   📋 ID: $container" -ForegroundColor Blue
    Write-Host "   ⏱️  Status: $status" -ForegroundColor Blue
    Write-Host "   🔌 Ports: $ports" -ForegroundColor Blue
} else {
    $stoppedContainer = docker ps -a --filter "name=$ContainerName" --format "{{.ID}}"
    if ($stoppedContainer) {
        Write-Host "   ⚠️  Container: Stopped" -ForegroundColor Yellow
    } else {
        Write-Host "   ❌ Container: Not Found" -ForegroundColor Red
    }
}

# Test application if container is running
if ($container) {
    Write-Host "🌐 Testing Application..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -Method Head -TimeoutSec 5 -ErrorAction Stop
        Write-Host "   ✅ Application: Responding (Status: $($response.StatusCode))" -ForegroundColor Green
        Write-Host "   🌍 URL: http://localhost:$Port" -ForegroundColor Yellow
    } catch {
        Write-Host "   ❌ Application: Not responding" -ForegroundColor Red
    }
}

# Check image
Write-Host "🖼️  Checking Image..." -ForegroundColor Cyan
$image = docker images --filter "reference=manufacturing-business-app" --format "{{.ID}}"
if ($image) {
    Write-Host "   ✅ Image: Found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Image: Not Found" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔧 Available Commands:" -ForegroundColor Blue
Write-Host "  Deploy:    .\deploy.ps1" -ForegroundColor White
Write-Host "  Logs:      docker logs $ContainerName" -ForegroundColor White
Write-Host "  Stop:      docker stop $ContainerName" -ForegroundColor White
Write-Host "  Restart:   docker restart $ContainerName" -ForegroundColor White
Write-Host "  Cleanup:   .\cleanup.ps1" -ForegroundColor White