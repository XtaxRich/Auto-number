# Simple test script for Get-NextVideoNumber function

# Create test directory
$testDir = "D:\test_number"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force
    Write-Host "Created test directory: $testDir" -ForegroundColor Green
}

# Create some test files to simulate existing renamed files
$testFiles = @(
    "5.1-1.mp4",
    "5.1-3.mp4", 
    "5.1-5.mp4",
    "other_file.mp4",
    "random_video.avi"
)

foreach ($fileName in $testFiles) {
    $filePath = Join-Path $testDir $fileName
    if (-not (Test-Path $filePath)) {
        New-Item -ItemType File -Path $filePath -Force
        Write-Host "Created test file: $fileName" -ForegroundColor Cyan
    }
}

# Define the Get-NextVideoNumber function directly (copy from video_renamer.ps1)
function Get-NextVideoNumber {
    param([string]$path, [int]$chapter, [int]$section)
    
    # Get all files in the directory
    $allFiles = Get-ChildItem -Path $path -File
    Write-Host "Debug: Total files in directory: $($allFiles.Count)" -ForegroundColor Magenta
    
    # Create regex pattern to match target format files
    $regex = "^" + $chapter.ToString() + "\." + $section.ToString() + "-(\d+)$"
    Write-Host "Debug: Using regex pattern: $regex" -ForegroundColor Magenta
    
    $matchingFiles = @()
    $maxNumber = 0
    
    foreach ($file in $allFiles) {
        $baseName = $file.BaseName
        Write-Host "Debug: Checking file: $baseName" -ForegroundColor Magenta
        
        if ($baseName -match $regex) {
            $number = [int]$matches[1]
            $matchingFiles += $file
            Write-Host "Debug: Found matching file: $baseName (number: $number)" -ForegroundColor Magenta
            
            if ($number -gt $maxNumber) {
                $maxNumber = $number
            }
        }
    }
    
    Write-Host "Debug: Found $($matchingFiles.Count) matching files, max number: $maxNumber" -ForegroundColor Magenta
    
    if ($matchingFiles.Count -eq 0) {
        Write-Host "Debug: No existing files found, returning 1" -ForegroundColor Magenta
        return 1
    }
    
    $nextNumber = $maxNumber + 1
    Write-Host "Debug: Next number will be: $nextNumber" -ForegroundColor Magenta
    return $nextNumber
}

Write-Host "`n=== Testing Get-NextVideoNumber Function ===" -ForegroundColor Yellow
Write-Host "Test directory: $testDir" -ForegroundColor Yellow
Write-Host "Chapter: 5, Section: 1" -ForegroundColor Yellow
Write-Host "`nExisting files:" -ForegroundColor Yellow
Get-ChildItem -Path $testDir -File | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }

Write-Host "`n--- Calling Get-NextVideoNumber ---" -ForegroundColor Yellow
$nextNumber = Get-NextVideoNumber -path $testDir -chapter 5 -section 1
Write-Host "`nResult: Next number should be 6 (since we have 5.1-1, 5.1-3, 5.1-5)" -ForegroundColor Yellow
Write-Host "Actual result: $nextNumber" -ForegroundColor $(if ($nextNumber -eq 6) { 'Green' } else { 'Red' })

if ($nextNumber -eq 6) {
    Write-Host "`n✅ Test PASSED: Function correctly identified max number 5 and returned 6" -ForegroundColor Green
} else {
    Write-Host "`n❌ Test FAILED: Expected 6, got $nextNumber" -ForegroundColor Red
}

# Clean up test files
Write-Host "`nCleaning up test files..." -ForegroundColor Gray
Remove-Item -Path $testDir -Recurse -Force
Write-Host "Test completed." -ForegroundColor Green