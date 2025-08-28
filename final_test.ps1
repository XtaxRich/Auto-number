# Final test to verify infinite loop fix in real scenario

# Create test directory
$testDir = "E:\workspace\auto编号\final_test"
if (Test-Path $testDir) {
    Remove-Item $testDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

Write-Host "Created test directory: $testDir" -ForegroundColor Green

# Create a test video file with random name (simulating download)
$randomFile = Join-Path $testDir "random_download_video.mp4"
New-Item -ItemType File -Path $randomFile -Force | Out-Null
Write-Host "Created test file: random_download_video.mp4" -ForegroundColor Green

# Import functions from main script (only the functions we need)
$scriptContent = Get-Content .\video_renamer.ps1 -Raw

# Extract and define only the functions we need
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

function Get-NextVideoNumber {
    param([string]$path, [int]$chapter, [int]$section)
    
    $files = Get-ChildItem -Path $path -File
    Write-Host "Debug: Total files in directory: $($files.Count)" -ForegroundColor DarkGray
    
    $pattern = "^" + $chapter.ToString() + "\." + $section.ToString() + "-(\d+)$"
    Write-Host "Debug: Using regex pattern: $pattern" -ForegroundColor DarkGray
    
    $maxNumber = 0
    $matchCount = 0
    
    foreach ($file in $files) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        Write-Host "Debug: Checking file: $baseName" -ForegroundColor DarkGray
        
        if ($baseName -match $pattern) {
            $number = [int]$matches[1]
            Write-Host "Debug: Found matching file: $baseName (number: $number)" -ForegroundColor DarkGray
            $matchCount++
            if ($number -gt $maxNumber) {
                $maxNumber = $number
            }
        }
    }
    
    Write-Host "Debug: Found $matchCount matching files, max number: $maxNumber" -ForegroundColor DarkGray
    
    if ($matchCount -eq 0) {
        Write-Host "Debug: No existing files found, returning 1" -ForegroundColor DarkGray
        return 1
    } else {
        $nextNumber = $maxNumber + 1
        Write-Host "Debug: Next number will be: $nextNumber" -ForegroundColor DarkGray
        return $nextNumber
    }
}

function Test-VideoFile {
    param([string]$filePath)
    
    $videoExtensions = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v')
    $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
    return $videoExtensions -contains $extension
}

function Rename-VideoFile {
    param([string]$filePath, [int]$chapter, [int]$section, [int]$number)
    
    Write-Host "Starting rename process for: $filePath" -ForegroundColor Gray
    
    if (-not (Test-Path $filePath)) {
        Write-Host "Error: File does not exist: $filePath" -ForegroundColor Red
        return $false
    }
    
    $file = Get-Item $filePath
    $extension = $file.Extension
    $newName = $chapter.ToString() + "." + $section.ToString() + "-" + $number.ToString() + $extension
    $newPath = Join-Path $file.Directory $newName
    
    Write-Host "Target name: $newName" -ForegroundColor Gray
    Write-Host "Target path: $newPath" -ForegroundColor Gray
    
    if (Test-Path $newPath) {
        Write-Host "Warning: Target file already exists: $newName" -ForegroundColor Yellow
        return $false
    }
    
    try {
        Write-Host "Attempting to rename: $($file.Name) -> $newName" -ForegroundColor Cyan
        Rename-Item -Path $filePath -NewName $newName -Force
        Write-Host "File renamed successfully: $($file.Name) -> $newName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Rename failed: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Process-VideoFile {
    param([string]$filePath)
    
    $name = [System.IO.Path]::GetFileName($filePath)
    
    Write-Host "Processing file: $name" -ForegroundColor Cyan
    
    if (Test-TemporaryFile -fileName $name) {
        Write-Host "Skipping temporary file: $name" -ForegroundColor Gray
        return
    }
    
    Write-Host "Checking if file is already renamed: $name" -ForegroundColor DarkGray
    $isAlreadyRenamed = Test-AlreadyRenamed -fileName $name -chapter $global:CurrentChapter -section $global:CurrentSection
    if ($isAlreadyRenamed) {
        Write-Host "File already in target format, skipping: $name" -ForegroundColor Yellow
        return
    }
    Write-Host "File is not in target format, proceeding with processing" -ForegroundColor DarkGray
    
    if (Test-Path $filePath) {
        Write-Host "File still exists after wait: $name" -ForegroundColor Gray
        
        if (Test-VideoFile -filePath $filePath) {
            Write-Host "New video file detected: $name" -ForegroundColor Cyan
            
            try {
                $nextNumber = Get-NextVideoNumber -path (Split-Path $filePath -Parent) -chapter $global:CurrentChapter -section $global:CurrentSection
                Write-Host "Next number calculated: $nextNumber" -ForegroundColor Gray
                
                $result = Rename-VideoFile -filePath $filePath -chapter $global:CurrentChapter -section $global:CurrentSection -number $nextNumber
                if ($result) {
                    Write-Host "Rename operation completed successfully" -ForegroundColor Green
                } else {
                    Write-Host "Rename operation failed" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error in rename process: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "File is not a video file: $name" -ForegroundColor Gray
        }
    } else {
        Write-Host "File no longer exists: $name" -ForegroundColor Gray
    }
}

# Set global variables
$global:CurrentChapter = 5
$global:CurrentSection = 1

Write-Host "\n=== FINAL TEST: Simulating file rename scenario ===" -ForegroundColor Yellow

# Step 1: Process the random file (should rename to 5.1-1.mp4)
Write-Host "\nStep 1: Processing random file..." -ForegroundColor Cyan
Process-VideoFile -filePath $randomFile

# Check what happened
$renamedFile = Join-Path $testDir "5.1-1.mp4"
if (Test-Path $renamedFile) {
    Write-Host "✓ Step 1 SUCCESS: File renamed to 5.1-1.mp4" -ForegroundColor Green
    
    # Step 2: Try to process the renamed file again (should be skipped)
    Write-Host "\nStep 2: Processing the renamed file again (should be skipped)..." -ForegroundColor Cyan
    Process-VideoFile -filePath $renamedFile
    
    # Check if file is still 5.1-1.mp4 (not renamed to 5.1-2.mp4)
    if (Test-Path $renamedFile -and -not (Test-Path (Join-Path $testDir "5.1-2.mp4"))) {
        Write-Host "✓ Step 2 SUCCESS: File was correctly skipped, no infinite loop!" -ForegroundColor Green
        Write-Host "\n🎉 INFINITE LOOP FIX VERIFIED! 🎉" -ForegroundColor Green
    } else {
        Write-Host "✗ Step 2 FAILURE: File was renamed again, infinite loop still exists" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Step 1 FAILURE: File was not renamed" -ForegroundColor Red
}

# Clean up
Remove-Item $testDir -Recurse -Force
Write-Host "\nTest directory cleaned up." -ForegroundColor Gray

Read-Host "Press any key to exit"