# Test script for video renaming functionality
param(
    [string]$TestFolder = "D:\test",
    [int]$Chapter = 5,
    [int]$Section = 1
)

# Create test folder if it doesn't exist
if (-not (Test-Path $TestFolder)) {
    New-Item -ItemType Directory -Path $TestFolder -Force
    Write-Host "Created test folder: $TestFolder" -ForegroundColor Green
}

# Create a test video file
$testFileName = "test_video_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".mp4"
$testFilePath = Join-Path $TestFolder $testFileName

# Create empty test file
New-Item -ItemType File -Path $testFilePath -Force
Write-Host "Created test file: $testFileName" -ForegroundColor Cyan

# Wait a moment
Start-Sleep -Seconds 1

# Check if file exists
if (Test-Path $testFilePath) {
    Write-Host "Test file created successfully at: $testFilePath" -ForegroundColor Green
    Write-Host "File size: $((Get-Item $testFilePath).Length) bytes" -ForegroundColor Gray
} else {
    Write-Host "Failed to create test file" -ForegroundColor Red
}

Write-Host "\nNow run the main video_renamer.ps1 script to test the renaming functionality." -ForegroundColor Yellow
Write-Host "The test file should be renamed to: $Chapter.$Section-1.mp4" -ForegroundColor Yellow