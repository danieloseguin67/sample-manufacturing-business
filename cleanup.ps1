# Manufacturing Business Application - Cleanup Script
param(
    [switch]$DryRun,
    [string]$LogPath,
    [int]$RetentionDays = 30,
    [switch]$Force,
    [switch]$Help
)

if ($Help) {
    Write-Host "Manufacturing Business Application - Cleanup Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\cleanup.ps1 [OPTIONS]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -DryRun         Simulate cleanup without making changes" -ForegroundColor White
    Write-Host "  -LogPath        Path to write execution log" -ForegroundColor White
    Write-Host "  -RetentionDays  Days to retain logs and backups (default: 30)" -ForegroundColor White
    Write-Host "  -Force          Force removal of protected files" -ForegroundColor White
    Write-Host "  -Help           Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\cleanup.ps1                         # Standard cleanup" -ForegroundColor White
    Write-Host "  .\cleanup.ps1 -DryRun                # Preview cleanup actions" -ForegroundColor White
    Write-Host "  .\cleanup.ps1 -Force                 # Force cleanup all resources" -ForegroundColor White
    exit 0
}

Write-Host "🧹 Manufacturing Business Application - Cleanup" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Magenta
}

# Log function
function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    if ($LogPath) {
        $logMessage | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
    
    switch ($Level) {
        "INFO" { Write-Host $Message -ForegroundColor White }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "ERROR" { Write-Host $Message -ForegroundColor Red }
    }
}

# Stop and remove container
Write-Host "🔄 Stopping and removing container..." -ForegroundColor Cyan
$container = docker ps -a --filter "name=manufacturing-business-container" --format "{{.ID}}"
if ($container) {
    if (-not $DryRun) {
        docker stop $container | Out-Null
        docker rm $container | Out-Null
    }
    Write-Log "✅ Container removed (ID: $container)" "SUCCESS"
} else {
    Write-Log "ℹ️ No container found" "INFO"
}

# Remove image
Write-Host "🔄 Removing Docker image..." -ForegroundColor Cyan
$image = docker images --filter "reference=manufacturing-business-app" --format "{{.ID}}"
if ($image) {
    if (-not $DryRun) {
        docker rmi $image | Out-Null
    }
    Write-Log "✅ Image removed (ID: $image)" "SUCCESS"
} else {
    Write-Log "ℹ️ No image found" "INFO"
}

# Clean up build artifacts
Write-Host "🔄 Cleaning build artifacts..." -ForegroundColor Cyan
if (Test-Path "dist") {
    if (-not $DryRun) {
        if ($Force) {
            Remove-Item -Recurse -Force "dist"
        } else {
            Remove-Item -Recurse "dist"
        }
    }
    Write-Log "✅ Build artifacts cleaned (dist folder)" "SUCCESS"
} else {
    Write-Log "ℹ️ No build artifacts found" "INFO"
}

# Clean up node_modules if Force is specified
if ($Force) {
    Write-Host "🔄 Cleaning node_modules (Force mode)..." -ForegroundColor Cyan
    if (Test-Path "node_modules") {
        if (-not $DryRun) {
            Remove-Item -Recurse -Force "node_modules"
        }
        Write-Log "✅ Node modules cleaned" "SUCCESS"
    } else {
        Write-Log "ℹ️ No node_modules found" "INFO"
    }
}

# Clean up old log files (if RetentionDays specified)
if ($RetentionDays -gt 0) {
    Write-Host "🔄 Cleaning old log files (older than $RetentionDays days)..." -ForegroundColor Cyan
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $logFiles = Get-ChildItem -Path "." -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoffDate }
    
    if ($logFiles) {
        foreach ($logFile in $logFiles) {
            if (-not $DryRun) {
                Remove-Item $logFile.FullName -Force
            }
            Write-Log "✅ Removed old log file: $($logFile.Name)" "SUCCESS"
        }
    } else {
        Write-Log "ℹ️ No old log files found" "INFO"
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "🔍 DRY RUN COMPLETED - No actual changes made" -ForegroundColor Magenta
} else {
    Write-Host "🎉 Cleanup completed!" -ForegroundColor Green
}

if ($LogPath) {
    Write-Host "📝 Log written to: $LogPath" -ForegroundColor Blue
}