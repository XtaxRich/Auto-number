# Test script to verify infinite loop fix - Independent version

# Define only the necessary functions for testing
function Test-TemporaryFile {
    param([string]$fileName)
    
    $tempExtensions = @('.tmp', '.crdownload', '.part', '.download')
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    
    if ($tempExtensions -contains $extension) {
        return $true
    }
    
    if ($fileName -match '\.tmp$|\.crdownload$|\.part$|\.download$') {
        return $true
    }
    
    return $false
}

function Test-AlreadyRenamed {
    param([string]$fileName, [int]$chapter, [int]$section)
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $pattern = "^" + $chapter.ToString() + "\." + $section.ToString() + "-(\d+)$"
    
    Write-Host "Debug: Testing if file is already renamed: $baseName" -ForegroundColor DarkGray
    Write-Host "Debug: Using pattern: $pattern" -ForegroundColor DarkGray
    
    $isMatch = $baseName -match $pattern
    Write-Host "Debug: Match result: $isMatch" -ForegroundColor DarkGray
    
    return $isMatch
}

function Process-VideoFile {
    param([string]$filePath)
    
    $name = [System.IO.Path]::GetFileName($filePath)
    
    Write-Host "Processing file: $name" -ForegroundColor Cyan
    
    # Skip if it's a temporary file
    if (Test-TemporaryFile -fileName $name) {
        Write-Host "Skipping temporary file: $name" -ForegroundColor Gray
        return
    }
    
    # Skip if file is already in target format
    Write-Host "Checking if file is already renamed: $name" -ForegroundColor DarkGray
    $isAlreadyRenamed = Test-AlreadyRenamed -fileName $name -chapter $global:CurrentChapter -section $global:CurrentSection
    if ($isAlreadyRenamed) {
        Write-Host "File already in target format, skipping: $name" -ForegroundColor Yellow
        return
    }
    Write-Host "File is not in target format, proceeding with processing" -ForegroundColor DarkGray
    
    Write-Host "Would normally process video file here..." -ForegroundColor Green
}

# Create a test directory
$testDir = "E:\workspace\auto编号\test_loop"
if (Test-Path $testDir) {
    Remove-Item $testDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

Write-Host "Created test directory: $testDir" -ForegroundColor Green

# Create a test video file that's already in target format
$testFile = Join-Path $testDir "5.1-1.mp4"
New-Item -ItemType File -Path $testFile -Force | Out-Null
Write-Host "Created test file: 5.1-1.mp4" -ForegroundColor Green

# Set global variables
$global:CurrentChapter = 5
$global:CurrentSection = 1

Write-Host "\nTesting Process-VideoFile function with already renamed file..." -ForegroundColor Yellow

# Test Process-VideoFile with the already renamed file
Process-VideoFile -filePath $testFile

Write-Host "\nTest completed. Check if the file was processed or skipped." -ForegroundColor Yellow

# Check if file still exists and hasn't been renamed
if (Test-Path $testFile) {
    Write-Host "✓ SUCCESS: File still exists as 5.1-1.mp4 (not renamed)" -ForegroundColor Green
} else {
    Write-Host "✗ FAILURE: File was renamed or deleted" -ForegroundColor Red
}

# Clean up
Remove-Item $testDir -Recurse -Force
Write-Host "\nTest directory cleaned up." -ForegroundColor Gray

Read-Host "Press any key to exit"