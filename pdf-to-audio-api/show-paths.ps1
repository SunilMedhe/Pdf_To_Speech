# PDF-to-Audio API - Path Information Script

Write-Host "📂 PDF-to-Audio API - File Storage Paths" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Get current directory
$currentDir = Get-Location
Write-Host "🏠 Current Working Directory:" -ForegroundColor Cyan
Write-Host "   $currentDir" -ForegroundColor White
Write-Host ""

# Show where PDF files will be saved
Write-Host "📄 PDF Files will be saved to:" -ForegroundColor Cyan
$pdfPath = Join-Path $currentDir "pdf"
Write-Host "   $pdfPath" -ForegroundColor Yellow
Write-Host ""

# Show where Audio files will be saved  
Write-Host "🎵 Audio Files will be saved to:" -ForegroundColor Cyan
$audioPath = Join-Path $currentDir "audio-files"
Write-Host "   $audioPath" -ForegroundColor Yellow
Write-Host ""

# Check if directories exist
Write-Host "📁 Directory Status:" -ForegroundColor Cyan
if (Test-Path $pdfPath) {
    Write-Host "   ✅ PDF directory exists: $pdfPath" -ForegroundColor Green
    $pdfFiles = Get-ChildItem $pdfPath -Filter "*.pdf" -ErrorAction SilentlyContinue
    Write-Host "      📄 PDF files: $($pdfFiles.Count)" -ForegroundColor White
} else {
    Write-Host "   ❌ PDF directory does not exist yet: $pdfPath" -ForegroundColor Red
    Write-Host "      (Will be created automatically when first PDF is uploaded)" -ForegroundColor Gray
}

if (Test-Path $audioPath) {
    Write-Host "   ✅ Audio directory exists: $audioPath" -ForegroundColor Green
    $audioFiles = Get-ChildItem $audioPath -Filter "*.wav" -ErrorAction SilentlyContinue
    Write-Host "      🎵 Audio files: $($audioFiles.Count)" -ForegroundColor White
} else {
    Write-Host "   ❌ Audio directory does not exist yet: $audioPath" -ForegroundColor Red
    Write-Host "      (Will be created automatically when first audio is generated)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "💡 Example file paths after upload:" -ForegroundColor Cyan
Write-Host "   PDF: $pdfPath\myDocument_20250819_123456.pdf" -ForegroundColor White
Write-Host "   Audio: $audioPath\myDocument_20250819_123456.wav" -ForegroundColor White
Write-Host ""

# Show deployment recommendations
Write-Host "🚀 Deployment Recommendations:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 🏠 Run from Development Directory:" -ForegroundColor Yellow
Write-Host "   cd C:\Users\Admin\pdf-to-audio-api" -ForegroundColor Gray
Write-Host "   java -jar target\pdf-to-audio-api-1.0.0.jar" -ForegroundColor Gray
Write-Host "   PDF Path: C:\Users\Admin\pdf-to-audio-api\pdf\" -ForegroundColor White
Write-Host ""

Write-Host "2. Run from Dedicated Deployment Directory (Recommended):" -ForegroundColor Yellow
Write-Host "   cd C:\pdf-to-audio-api" -ForegroundColor Gray
Write-Host "   java -jar pdf-to-audio-api-1.0.0.jar" -ForegroundColor Gray
Write-Host "   PDF Path: C:\pdf-to-audio-api\pdf\" -ForegroundColor White
Write-Host ""

Write-Host "3. 🔧 Run deployment script to set up dedicated directory:" -ForegroundColor Yellow
Write-Host "   .\deploy.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host
