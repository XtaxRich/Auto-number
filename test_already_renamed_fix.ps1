# Test script to verify Test-AlreadyRenamed function fix

# Define the function directly for testing
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

Write-Host "Testing Test-AlreadyRenamed function fix" -ForegroundColor Yellow
Write-Host "" 

# Test cases
$testCases = @(
    @{FileName = "5.1-1.mp4"; Chapter = 5; Section = 1; Expected = $true; Description = "Should match 5.1-1.mp4"},
    @{FileName = "5.1-2.mp4"; Chapter = 5; Section = 1; Expected = $true; Description = "Should match 5.1-2.mp4"},
    @{FileName = "5.1-10.mp4"; Chapter = 5; Section = 1; Expected = $true; Description = "Should match 5.1-10.mp4"},
    @{FileName = "random_video.mp4"; Chapter = 5; Section = 1; Expected = $false; Description = "Should NOT match random_video.mp4"},
    @{FileName = "5.2-1.mp4"; Chapter = 5; Section = 1; Expected = $false; Description = "Should NOT match different section 5.2-1.mp4"},
    @{FileName = "6.1-1.mp4"; Chapter = 5; Section = 1; Expected = $false; Description = "Should NOT match different chapter 6.1-1.mp4"}
)

$passCount = 0
$totalCount = $testCases.Count

foreach ($test in $testCases) {
    Write-Host "Testing: $($test.Description)" -ForegroundColor Cyan
    
    $result = Test-AlreadyRenamed -fileName $test.FileName -chapter $test.Chapter -section $test.Section
    
    if ($result -eq $test.Expected) {
        Write-Host "✓ PASS" -ForegroundColor Green
        $passCount++
    } else {
        Write-Host "✗ FAIL - Expected: $($test.Expected), Got: $result" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "Test Results: $passCount/$totalCount tests passed" -ForegroundColor $(if ($passCount -eq $totalCount) { 'Green' } else { 'Red' })

if ($passCount -eq $totalCount) {
    Write-Host "All tests passed! Test-AlreadyRenamed function is working correctly." -ForegroundColor Green
} else {
    Write-Host "Some tests failed. The function needs further fixes." -ForegroundColor Red
}

Read-Host "Press any key to exit"