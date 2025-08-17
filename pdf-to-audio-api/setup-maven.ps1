# Download and setup Maven manually
Write-Host "Downloading Apache Maven..." -ForegroundColor Green

$mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.zip"
$downloadPath = "$env:TEMP\apache-maven-3.9.5-bin.zip"
$extractPath = "C:\apache-maven-3.9.5"

# Download Maven
try {
    Write-Host "Downloading Maven from $mavenUrl"
    Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Failed to download Maven: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Extract Maven
try {
    Write-Host "Extracting Maven to $extractPath"
    
    # Create directory if it doesn't exist
    if (!(Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath -Force
    }
    
    # Extract using .NET classes
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, "C:\")
    
    Write-Host "Maven extracted successfully!" -ForegroundColor Green
    
    # Clean up download file
    Remove-Item $downloadPath -Force
    
} catch {
    Write-Host "Failed to extract Maven: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Set environment variables for current session
$env:MAVEN_HOME = $extractPath
$env:PATH = "$extractPath\bin;$env:PATH"

Write-Host ""
Write-Host "Maven setup completed!" -ForegroundColor Green
Write-Host "Maven Home: $extractPath" -ForegroundColor Yellow
Write-Host ""

# Test Maven
Write-Host "Testing Maven installation..."
try {
    $mavenVersion = & "$extractPath\bin\mvn.cmd" -version 2>&1
    Write-Host $mavenVersion -ForegroundColor Cyan
    Write-Host ""
    Write-Host "SUCCESS: Maven is working!" -ForegroundColor Green
    
    # Now try to build the project
    Write-Host ""
    Write-Host "Building PDF to Audio API project..." -ForegroundColor Green
    
    Set-Location "C:\Users\Admin\pdf-to-audio-api"
    & "$extractPath\bin\mvn.cmd" clean compile
    
} catch {
    Write-Host "Maven test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "To use Maven permanently, add this to your system PATH:" -ForegroundColor Yellow
Write-Host "$extractPath\bin" -ForegroundColor White
