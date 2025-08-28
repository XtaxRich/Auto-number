# Test script to simulate browser download behavior
# This script creates a temporary file and then renames it to mp4 to test the enhanced video renamer

param(
    [string]$TestPath = "D:\test",
    [string]$VideoName = "test_video.mp4"
)

# Check if test path exists
if (-not (Test-Path $TestPath)) {
    Write-Host "Creating test directory: $TestPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $TestPath -Force
}

Write-Host "Simulating browser download behavior..." -ForegroundColor Cyan
Write-Host "Test path: $TestPath" -ForegroundColor Gray
Write-Host "Video name: $VideoName" -ForegroundColor Gray
Write-Host ""

# Step 1: Create a temporary file (simulating browser download start)
$tempFileName = [System.Guid]::NewGuid().ToString() + ".tmp"
$tempFilePath = Join-Path $TestPath $tempFileName
$finalFilePath = Join-Path $TestPath $VideoName

Write-Host "Step 1: Creating temporary file: $tempFileName" -ForegroundColor Yellow
"This is a test video file content" | Out-File -FilePath $tempFilePath -Encoding UTF8
Write-Host "Temporary file created successfully" -ForegroundColor Green

# Wait a moment
Start-Sleep -Seconds 2

# Step 2: Rename temporary file to final video file (simulating download completion)
Write-Host "Step 2: Renaming to final video file: $VideoName" -ForegroundColor Yellow
try {
    Rename-Item -Path $tempFilePath -NewName $VideoName
    Write-Host "File renamed successfully to: $VideoName" -ForegroundColor Green
    Write-Host "The video renamer should now detect and rename this file to chapter.section-number format" -ForegroundColor Cyan
}
catch {
    Write-Host "Error renaming file: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test completed. Check if the video renamer detected and renamed the file." -ForegroundColor Cyan
Write-Host "Expected behavior: The file should be renamed to format like 5.1-X.mp4" -ForegroundColor Gray