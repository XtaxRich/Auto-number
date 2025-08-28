# Test script to create a test video file for renaming
param(
    [string]$TestPath = "D:\test",
    [string]$FileName = "test_video.mp4"
)

# Create test directory if it doesn't exist
if (-not (Test-Path $TestPath)) {
    New-Item -ItemType Directory -Path $TestPath -Force
    Write-Host "Created test directory: $TestPath" -ForegroundColor Green
}

# Create a test video file
$testFilePath = Join-Path $TestPath $FileName

# Create an empty file to simulate a video file
New-Item -ItemType File -Path $testFilePath -Force
Write-Host "Created test video file: $testFilePath" -ForegroundColor Green

Write-Host "Test file created successfully. You can now test the video renamer script." -ForegroundColor Yellow
Write-Host "The file should be renamed to 5.1-1.mp4 (or next available number)" -ForegroundColor Yellow