$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectName = "esraa_app"

Write-Host "============================================" -ForegroundColor Magenta
Write-Host "     Esraa App Builder - For Dr. Esraa" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

# 1. Check Flutter
Write-Host "[1/6] Checking Flutter..." -ForegroundColor Cyan
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host "ERROR: Flutter not found. Please install Flutter first." -ForegroundColor Red
    Write-Host "https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Read-Host "Press Enter after installing Flutter"
    $flutter = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutter) {
        Write-Host "Flutter still not found. Exiting." -ForegroundColor Red
        exit 1
    }
}
Write-Host "OK: Flutter is available" -ForegroundColor Green

# 2. Create platform files
Write-Host "[2/6] Creating platform files..." -ForegroundColor Cyan
$hasAndroid = Test-Path "$scriptPath\android\build.gradle"
if (-not $hasAndroid) {
    Write-Host "Generating platform files in temp folder..." -ForegroundColor Yellow
    $tmpDir = "$env:TEMP\esraa_platform_gen"
    if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
    Push-Location $tmpDir
    flutter create --project-name $projectName --platforms android . 2>&1 | Out-Null
    Pop-Location
    if (Test-Path "$tmpDir\android") {
        Copy-Item -Recurse -Force "$tmpDir\android" "$scriptPath\android"
        Write-Host "OK: Android platform files copied" -ForegroundColor Green
        $hasAndroid = $true
    }
    if (Test-Path "$tmpDir\ios") {
        Copy-Item -Recurse -Force "$tmpDir\ios" "$scriptPath\ios"
        Write-Host "OK: iOS platform files copied" -ForegroundColor Green
    }
    if (Test-Path "$tmpDir\web") {
        Copy-Item -Recurse -Force "$tmpDir\web" "$scriptPath\web"
    }
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
} else {
    Write-Host "OK: Platform files already exist" -ForegroundColor Green
}

# 3. Create assets directories
Write-Host "[3/6] Setting up assets..." -ForegroundColor Cyan
$dirs = @("assets\images", "assets\fonts", "assets\sounds")
foreach ($d in $dirs) {
    $fullPath = "$scriptPath\$d"
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}
Write-Host "OK: Asset directories ready" -ForegroundColor Green

# 4. Get packages
Write-Host "[4/6] Installing packages..." -ForegroundColor Cyan
Push-Location $scriptPath
flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: Packages installed" -ForegroundColor Green
} else {
    Write-Host "Warning: Some packages may have issues" -ForegroundColor Yellow
}
Pop-Location

# 5. Analyze code
Write-Host "[5/6] Analyzing code..." -ForegroundColor Cyan
Push-Location $scriptPath
$analysisFile = "$env:TEMP\flutter_analyze_output.txt"
flutter analyze > $analysisFile 2>&1
$analyzeExit = $LASTEXITCODE
Get-Content $analysisFile
if ($analyzeExit -eq 0) {
    Write-Host "OK: No issues found" -ForegroundColor Green
} else {
    Write-Host "NOTE: $analyzeExit issues found (build can still proceed)" -ForegroundColor Yellow
}
Pop-Location

# 6. Build
Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "      BUILD OPTIONS" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  [1] APK (Debug)     - Quick test build" -ForegroundColor Cyan
Write-Host "  [2] APK (Release)   - Production APK" -ForegroundColor Cyan
Write-Host "  [3] App Bundle      - Google Play Store" -ForegroundColor Cyan
Write-Host "  [4] Run on device   - Test on connected phone" -ForegroundColor Cyan
Write-Host "  [5] Exit" -ForegroundColor Cyan
Write-Host ""
$choice = Read-Host "Choose (1-5)"

switch ($choice) {
    "1" {
        Write-Host "Building APK Debug..." -ForegroundColor Cyan
        Push-Location $scriptPath
        flutter build apk --debug
        Pop-Location
        $apkPath = "$scriptPath\build\app\outputs\flutter-apk\app-debug.apk"
        if (Test-Path $apkPath) {
            Write-Host "============================================" -ForegroundColor Green
            Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
            Write-Host "  APK: $apkPath" -ForegroundColor Green
            Write-Host "============================================" -ForegroundColor Green
        }
    }
    "2" {
        Write-Host "Building APK Release..." -ForegroundColor Cyan
        Push-Location $scriptPath
        flutter build apk --release
        Pop-Location
        $apkPath = "$scriptPath\build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkPath) {
            Write-Host "============================================" -ForegroundColor Green
            Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
            Write-Host "  APK: $apkPath" -ForegroundColor Green
            Write-Host "============================================" -ForegroundColor Green
        }
    }
    "3" {
        Write-Host "Building App Bundle..." -ForegroundColor Cyan
        Push-Location $scriptPath
        flutter build appbundle
        Pop-Location
    }
    "4" {
        Write-Host "Connecting to device..." -ForegroundColor Cyan
        Push-Location $scriptPath
        flutter run
        Pop-Location
    }
    default {
        Write-Host "Exiting. Bye!" -ForegroundColor Magenta
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  For Dr. Esraa Modawi - May Allah bless you" -ForegroundColor Magenta
Write-Host "  For Ibrahim Modawi - Rahimahu Allah" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Read-Host "Press Enter to exit"
