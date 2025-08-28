# Test script to verify the fixed rename functionality
# This script creates multiple test video files to verify sequential numbering

param(
    [string]$TestPath = "D:\test",
    [int]$Chapter = 5,
    [int]$Section = 1
)

Write-Host "Testing fixed rename functionality" -ForegroundColor Yellow
Write-Host "Test path: $TestPath" -ForegroundColor Gray
Write-Host "Chapter: $Chapter, Section: $Section" -ForegroundColor Gray
Write-Host ""

# Ensure test directory exists
if (-not (Test-Path $TestPath)) {
    New-Item -ItemType Directory -Path $TestPath -Force
    Write-Host "Created test directory: $TestPath" -ForegroundColor Green
}

# Function to create a test video file
function Create-TestVideoFile {
    param([string]$path, [string]$fileName)
    
    $fullPath = Join-Path $path $fileName
    
    # Create a small test file with some content
    $content = "This is a test video file created at $(Get-Date)"
    Set-Content -Path $fullPath -Value $content
    
    Write-Host "Created test file: $fileName" -ForegroundColor Cyan
    return $fullPath
}

# Create multiple test files to verify sequential numbering
Write-Host "Creating test video files..." -ForegroundColor Yellow

$testFiles = @(
    "test_video_1_$(Get-Random).mp4",
    "test_video_2_$(Get-Random).mp4",
    "test_video_3_$(Get-Random).mp4"
)

foreach ($fileName in $testFiles) {
    Create-TestVideoFile -path $TestPath -fileName $fileName
    Start-Sleep -Seconds 1  # Small delay between file creations
}

Write-Host ""
Write-Host "Test files created. The video renamer should process these files and rename them to:" -ForegroundColor Green
Write-Host "- $Chapter.$Section-1.mp4" -ForegroundColor Green
Write-Host "- $Chapter.$Section-2.mp4" -ForegroundColor Green
Write-Host "- $Chapter.$Section-3.mp4" -ForegroundColor Green
Write-Host ""
Write-Host "Monitor the video renamer output to verify correct sequential numbering." -ForegroundColor Yellow
Write-Host "Press any key to exit..." -ForegroundColor Gray
Read-Host