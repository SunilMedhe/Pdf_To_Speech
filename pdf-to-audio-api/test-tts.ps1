# Test Windows SAPI Text-to-Speech
# This script demonstrates the human-like speech capability

Write-Host "Testing Windows SAPI Text-to-Speech..." -ForegroundColor Green
Write-Host ""

# Load System.Speech assembly
Add-Type -AssemblyName System.Speech

# Create speech synthesizer
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Set speech properties
$synth.Rate = 0    # Normal speed (-10 to +10)
$synth.Volume = 80 # Volume (0-100)

# Test text (sample summary)
$testText = "Hello! This is a test of the improved PDF to Audio API. The system now uses Windows Speech API to generate human-like speech instead of weird beeping sounds. The text summarization has extracted the key points from your PDF document, and now you can hear it spoken by a natural-sounding voice."

Write-Host "Sample text to be spoken:"
Write-Host $testText -ForegroundColor Cyan
Write-Host ""

# Test different voices
Write-Host "Available voices on this system:" -ForegroundColor Yellow
$synth.GetInstalledVoices() | ForEach-Object { 
    Write-Host "- $($_.VoiceInfo.Name) ($($_.VoiceInfo.Gender), $($_.VoiceInfo.Culture))"
}
Write-Host ""

# Test female voice
Write-Host "Testing with Female voice..." -ForegroundColor Magenta
$synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Female)
$synth.Speak("This is the female voice speaking your PDF summary.")

Start-Sleep -Seconds 1

# Test male voice
Write-Host "Testing with Male voice..." -ForegroundColor Blue
$synth.SelectVoiceByHints([System.Speech.Synthesis.VoiceGender]::Male)
$synth.Speak("This is the male voice speaking your PDF summary.")

Start-Sleep -Seconds 1

# Test saving to file
Write-Host "Creating sample audio file..." -ForegroundColor Green
$outputPath = "audio-files\sample-test.wav"

# Create audio-files directory if it doesn't exist
if (!(Test-Path "audio-files")) {
    New-Item -ItemType Directory -Path "audio-files"
}

# Set output to WAV file
$synth.SetOutputToWaveFile($outputPath)
$synth.Speak($testText)
$synth.SetOutputToDefaultAudioDevice()

if (Test-Path $outputPath) {
    $fileSize = (Get-Item $outputPath).Length
    Write-Host "SUCCESS: Audio file created at $outputPath" -ForegroundColor Green
    Write-Host "File size: $fileSize bytes" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "You can now play this file to hear human-like speech!" -ForegroundColor Yellow
    Write-Host "The API will generate similar audio files for your PDF summaries." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: Failed to create audio file" -ForegroundColor Red
}

# Cleanup
$synth.Dispose()

Write-Host ""
Write-Host "Test completed! Your PDF to Audio API is now ready with human-like speech." -ForegroundColor Green
