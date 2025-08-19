# PDF to Audio API Deployment Script
# Run this script as Administrator on your VM

Write-Host "🚀 PDF to Audio API Deployment Script" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check if running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  This script needs to be run as Administrator to configure firewall rules!" -ForegroundColor Yellow
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to continue anyway (firewall rules will be skipped)"
}

Write-Host ""
Write-Host "📋 Deployment Steps:" -ForegroundColor Cyan
Write-Host "1. Copy JAR file to C:\pdf-to-audio-api\" -ForegroundColor White
Write-Host "2. Configure Windows Firewall" -ForegroundColor White  
Write-Host "3. Create service startup script" -ForegroundColor White
Write-Host "4. PDF files will be stored in 'pdf' folder" -ForegroundColor White
Write-Host "5. Audio files will be stored in 'audio-files' folder" -ForegroundColor White
Write-Host ""

# Step 1: Create deployment directory and copy JAR
Write-Host "📁 Step 1: Setting up deployment directory..." -ForegroundColor Yellow
$deployDir = "C:\pdf-to-audio-api"
if (-not (Test-Path $deployDir)) {
    New-Item -Path $deployDir -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created directory: $deployDir" -ForegroundColor Green
} else {
    Write-Host "✅ Directory already exists: $deployDir" -ForegroundColor Green
}

# Copy JAR file
$jarSource = "target\pdf-to-audio-api-1.0.0.jar"
$jarDest = "$deployDir\pdf-to-audio-api-1.0.0.jar"

if (Test-Path $jarSource) {
    Copy-Item $jarSource $jarDest -Force
    Write-Host "✅ JAR file copied to: $jarDest" -ForegroundColor Green
} else {
    Write-Host "❌ JAR file not found at: $jarSource" -ForegroundColor Red
    Write-Host "Please run 'mvnw clean package' first!" -ForegroundColor Red
    exit 1
}

# Step 2: Configure Windows Firewall
Write-Host ""
Write-Host "🔥 Step 2: Configuring Windows Firewall..." -ForegroundColor Yellow
if ($isAdmin) {
    try {
        # Remove existing rule if it exists
        Remove-NetFirewallRule -DisplayName "PDF to Audio API" -ErrorAction SilentlyContinue
        
        # Add new firewall rule
        New-NetFirewallRule -DisplayName "PDF to Audio API" `
                           -Direction Inbound `
                           -Protocol TCP `
                           -LocalPort 8085 `
                           -Action Allow `
                           -Profile Any | Out-Null
        Write-Host "✅ Windows Firewall rule added for port 8085" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to add firewall rule: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Skipping firewall configuration (not running as Administrator)" -ForegroundColor Yellow
    Write-Host "Manual command: New-NetFirewallRule -DisplayName 'PDF to Audio API' -Direction Inbound -Protocol TCP -LocalPort 8085 -Action Allow -Profile Any" -ForegroundColor Gray
}

# Step 3: Create startup script
Write-Host ""
Write-Host "📝 Step 3: Creating startup script..." -ForegroundColor Yellow
$startScript = @"
@echo off
echo Starting PDF to Audio API...
cd /d C:\pdf-to-audio-api
java -jar pdf-to-audio-api-1.0.0.jar
pause
"@

$startScript | Out-File -FilePath "$deployDir\start-api.bat" -Encoding ASCII
Write-Host "✅ Startup script created: $deployDir\start-api.bat" -ForegroundColor Green

# Step 4: Create service script (optional)
Write-Host ""
Write-Host "⚙️  Step 4: Creating service installation script..." -ForegroundColor Yellow
$serviceScript = @"
@echo off
echo Installing PDF to Audio API as Windows Service...
echo.
echo Download NSSM (Non-Sucking Service Manager) from: https://nssm.cc/download
echo.
echo Commands to run after downloading NSSM:
echo nssm install "PDFToAudioAPI" "java.exe" "-jar C:\pdf-to-audio-api\pdf-to-audio-api-1.0.0.jar"
echo nssm set "PDFToAudioAPI" AppDirectory "C:\pdf-to-audio-api"
echo nssm set "PDFToAudioAPI" DisplayName "PDF to Audio API"
echo nssm set "PDFToAudioAPI" Description "Converts PDF files to audio summaries"
echo net start PDFToAudioAPI
echo.
pause
"@

$serviceScript | Out-File -FilePath "$deployDir\install-service.bat" -Encoding ASCII
Write-Host "✅ Service installation script created: $deployDir\install-service.bat" -ForegroundColor Green

# Final instructions
Write-Host ""
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Files created:" -ForegroundColor Cyan
Write-Host "   • JAR file: $jarDest" -ForegroundColor White
Write-Host "   • Start script: $deployDir\start-api.bat" -ForegroundColor White
Write-Host "   • Service script: $deployDir\install-service.bat" -ForegroundColor White
Write-Host ""
Write-Host "🚀 To start the application:" -ForegroundColor Cyan
Write-Host "   1. Double-click: $deployDir\start-api.bat" -ForegroundColor White
Write-Host "   2. Or run: java -jar $jarDest" -ForegroundColor White
Write-Host ""
Write-Host "📁 File Storage:" -ForegroundColor Cyan
Write-Host "   • PDF files saved to: $deployDir\pdf\" -ForegroundColor White
Write-Host "   • Audio files saved to: $deployDir\audio-files\" -ForegroundColor White
Write-Host "   • Files auto-cleaned (keeps 10 most recent)" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Access URLs:" -ForegroundColor Cyan
Write-Host "   • Local: http://localhost:8085/" -ForegroundColor White
Write-Host "   • External: http://20.193.252.234:8085/" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Additional steps if still not accessible:" -ForegroundColor Cyan
Write-Host "   1. Check VM's Network Security Group allows port 8085" -ForegroundColor White
Write-Host "   2. Verify no other firewall software is blocking" -ForegroundColor White  
Write-Host "   3. Check if cloud provider firewall allows port 8085" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host
