# Manufacturing Business Application - Status Check
param(
    [string]$ContainerName = "manufacturing-business-container",
    [int]$Port = 8082,
    [int]$Timeout = 10,
    [switch]$Detailed,
    [switch]$Help
)

if ($Help) {
    Write-Host "Manufacturing Business Application - Status Check" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\status.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -ContainerName  Container name to check (default: manufacturing-business-container)" -ForegroundColor White
    Write-Host "  -Port           Application port to test (default: 8082)" -ForegroundColor White
    Write-Host "  -Timeout        HTTP request timeout in seconds (default: 10)" -ForegroundColor White
    Write-Host "  -Detailed       Show detailed container information" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    exit 0
}

Write-Host "🏭 Manufacturing Business Application Status" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Status tracking
$overallStatus = "Healthy"
$checks = @()

# Check Docker service
Write-Host "🐳 Docker Service Check..." -ForegroundColor Cyan
try {
    docker info > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Docker is running" -ForegroundColor Green
        $checks += @{ Name = "Docker Service"; Status = "Healthy"; Message = "Docker daemon is running" }
    } else {
        Write-Host "   ❌ Docker is not running" -ForegroundColor Red
        $overallStatus = "Unhealthy"
        $checks += @{ Name = "Docker Service"; Status = "Unhealthy"; Message = "Docker daemon is not accessible" }
    }
} catch {
    Write-Host "   ❌ Docker check failed: $($_.Exception.Message)" -ForegroundColor Red
    $overallStatus = "Unhealthy"
    $checks += @{ Name = "Docker Service"; Status = "Unhealthy"; Message = $_.Exception.Message }
}

# Check if container exists and is running
Write-Host "📦 Container Status Check..." -ForegroundColor Cyan
$containerFormat = "table {{.ID}}"
$container = docker ps --filter "name=$ContainerName" --format $containerFormat
if ($container) {
    $statusFormat = "table {{.Status}}"
    $portsFormat = "table {{.Ports}}" 
    $imageFormat = "table {{.Image}}"
    
    $status = docker ps --filter "id=$container" --format $statusFormat
    $ports = docker ps --filter "id=$container" --format $portsFormat
    $image = docker ps --filter "id=$container" --format $imageFormat
    
    Write-Host "   ✅ Container Status: Running" -ForegroundColor Green
    Write-Host "   📋 Container ID: $container" -ForegroundColor Blue
    Write-Host "   ⏱️  Status: $status" -ForegroundColor Blue
    Write-Host "   🔌 Ports: $ports" -ForegroundColor Blue
    Write-Host "   🖼️  Image: $image" -ForegroundColor Blue
    
    $checks += @{ Name = "Container Status"; Status = "Healthy"; Message = "Container is running normally" }
    
    if ($Detailed) {
        Write-Host "   📊 Detailed Container Info:" -ForegroundColor Blue
        $statsFormat = "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        docker stats --no-stream --format $statsFormat $container
    }
} else {
    # Check if container exists but is stopped
    $stoppedContainer = docker ps -a --filter "name=$ContainerName" --format $containerFormat
    if ($stoppedContainer) {
        Write-Host "   ⚠️  Container Status: Stopped" -ForegroundColor Yellow
        $overallStatus = "Degraded"
        $checks += @{ Name = "Container Status"; Status = "Degraded"; Message = "Container exists but is not running" }
    } else {
        Write-Host "   ❌ Container Status: Not Found" -ForegroundColor Red
        $overallStatus = "Unhealthy"
        $checks += @{ Name = "Container Status"; Status = "Unhealthy"; Message = "Container does not exist" }
    }
}

# Test application endpoint
if ($container) {
    Write-Host "🌐 Application Health Check..." -ForegroundColor Cyan
    try {
        $startTime = Get-Date
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -Method Head -TimeoutSec $Timeout -ErrorAction Stop
        $duration = ((Get-Date) - $startTime).TotalMilliseconds
        
        Write-Host "   ✅ Application: Responding (Status: $($response.StatusCode))" -ForegroundColor Green
        Write-Host "   🚀 Response Time: $([math]::Round($duration, 2))ms" -ForegroundColor Blue
        Write-Host "   🌍 URL: http://localhost:$Port" -ForegroundColor Yellow
        
        $checks += @{ Name = "Application Health"; Status = "Healthy"; Message = "HTTP $($response.StatusCode) in $([math]::Round($duration, 2))ms" }
    } catch {
        Write-Host "   ❌ Application: Not responding ($($_.Exception.Message))" -ForegroundColor Red
        if ($overallStatus -eq "Healthy") { $overallStatus = "Degraded" }
        $checks += @{ Name = "Application Health"; Status = "Unhealthy"; Message = "HTTP request failed: $($_.Exception.Message)" }
    }
}

# Check Docker image
Write-Host "🖼️  Image Status Check..." -ForegroundColor Cyan
$imageIdFormat = "table {{.ID}}"
$image = docker images --filter "reference=manufacturing-business-app" --format $imageIdFormat
if ($image) {
    $imageInfoFormat = "table {{.Repository}}:{{.Tag}} ({{.Size}})"
    $imageInfo = docker images --filter "reference=manufacturing-business-app" --format $imageInfoFormat
    Write-Host "   ✅ Image Found: $imageInfo" -ForegroundColor Green
    $checks += @{ Name = "Docker Image"; Status = "Healthy"; Message = "Image exists: $imageInfo" }
} else {
    Write-Host "   ❌ Image Not Found: manufacturing-business-app" -ForegroundColor Red
    if ($overallStatus -ne "Unhealthy") { $overallStatus = "Degraded" }
    $checks += @{ Name = "Docker Image"; Status = "Unhealthy"; Message = "Docker image not found" }
}

# Summary
Write-Host ""
Write-Host "📊 Overall Status: " -NoNewline
switch ($overallStatus) {
    "Healthy" { Write-Host "$overallStatus" -ForegroundColor Green }
    "Degraded" { Write-Host "$overallStatus" -ForegroundColor Yellow }
    "Unhealthy" { Write-Host "$overallStatus" -ForegroundColor Red }
}

Write-Host ""
Write-Host "🔧 Available Commands:" -ForegroundColor Blue
Write-Host "  Deploy:    .\deploy.ps1" -ForegroundColor White
Write-Host "  Logs:      docker logs $ContainerName" -ForegroundColor White
Write-Host "  Stop:      docker stop $ContainerName" -ForegroundColor White
Write-Host "  Restart:   docker restart $ContainerName" -ForegroundColor White
Write-Host "  Cleanup:   .\cleanup.ps1" -ForegroundColor White

if ($overallStatus -ne "Healthy") {
    Write-Host ""
    Write-Host "💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  To start the application: .\deploy.ps1" -ForegroundColor White
    Write-Host "  To rebuild completely:    .\deploy.ps1 -CleanUp" -ForegroundColor White
    Write-Host "  To check logs:           docker logs $ContainerName" -ForegroundColor White
}

# Exit code based on status
switch ($overallStatus) {
    "Healthy" { exit 0 }
    "Degraded" { exit 1 }
    "Unhealthy" { exit 2 }
}