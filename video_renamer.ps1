# Video File Auto Renamer Script
param(
    [string]$TargetPath = "C:\Users\Austin\Downloads",
    [int]$Chapter = 5,
    [int]$Section = 1
)

# Check if target path exists
if (-not (Test-Path $TargetPath)) {
    Write-Host "Error: Target path does not exist: $TargetPath" -ForegroundColor Red
    Read-Host "Press any key to exit"
    exit 1
}

# Supported video file extensions
$videoExtensions = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v')

# Get next video number
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

# Rename video file
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
    
    # Check if target file already exists
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
        Write-Host "Error details: $($_.Exception.GetType().Name)" -ForegroundColor Red
        return $false
    }
}

# Check if file is a video file
function Test-VideoFile {
    param([string]$filePath)
    
    $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
    return $videoExtensions -contains $extension
}

Write-Host "Starting folder monitoring: $TargetPath" -ForegroundColor Yellow
Write-Host "Chapter setting: Chapter $Chapter Section $Section" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host ""

# Create file system watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $TargetPath
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

# Store variables for use in event handler
$global:CurrentChapter = $Chapter
$global:CurrentSection = $Section

# Function to check if file is a temporary file
function Test-TemporaryFile {
    param([string]$fileName)
    
    $tempExtensions = @('.tmp', '.crdownload', '.part', '.download')
    $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
    
    # Check for temporary extensions
    if ($tempExtensions -contains $extension) {
        return $true
    }
    
    # Check for browser temporary file patterns
    if ($fileName -match '\.tmp$|\.crdownload$|\.part$|\.download$') {
        return $true
    }
    
    return $false
}

# Function to check if file is already in target format
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

# Function to process video file
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
    
    # Wait a bit to ensure file is fully written
    Start-Sleep -Seconds 3
    
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

# Event handler for Created events
$createdAction = {
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    
    Write-Host "File created: $name" -ForegroundColor Gray
    Process-VideoFile -filePath $path
}

# Event handler for Renamed events (for browser downloads)
$renamedAction = {
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    $oldPath = $Event.SourceEventArgs.OldFullPath
    $oldName = $Event.SourceEventArgs.OldName
    
    Write-Host "File renamed: $oldName -> $name" -ForegroundColor Gray
    
    # Skip if file is already in target format (avoid reprocessing our own renames)
    if (Test-AlreadyRenamed -fileName $name -chapter $global:CurrentChapter -section $global:CurrentSection) {
        Write-Host "Renamed file is already in target format, skipping: $name" -ForegroundColor Gray
        return
    }
    
    # Skip if old file was also in target format (avoid processing renames between target formats)
    if (Test-AlreadyRenamed -fileName $oldName -chapter $global:CurrentChapter -section $global:CurrentSection) {
        Write-Host "Old file was already in target format, skipping rename event: $oldName -> $name" -ForegroundColor Gray
        return
    }
    
    # Only process if the new file is a video file
    if (Test-VideoFile -filePath $path) {
        Write-Host "Video file created from rename: $name" -ForegroundColor Cyan
        Process-VideoFile -filePath $path
    }
}

# Register event handlers
$createdJob = Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $createdAction
$renamedJob = Register-ObjectEvent -InputObject $watcher -EventName "Renamed" -Action $renamedAction

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    # Clean up event handlers
    Unregister-Event -SourceIdentifier $createdJob.Name
    Unregister-Event -SourceIdentifier $renamedJob.Name
    $watcher.Dispose()
    Write-Host "Monitoring stopped" -ForegroundColor Yellow
}