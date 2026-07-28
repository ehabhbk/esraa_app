Write-Host "=================================" -ForegroundColor Cyan
Write-Host "  تجهيز مشروع Esraa App" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if Flutter is installed
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCheck) {
    Write-Host "❌ Flutter غير مثبت. ينبغي تثبيته أولاً:" -ForegroundColor Red
    Write-Host "1. اذهبي إلى: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    Write-Host "2. نزّلي Flutter SDK وقومي بتثبيته" -ForegroundColor Yellow
    Write-Host "3. شغّلي: flutter doctor" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "أو بدلي على هذا الموقع المباشر:" -ForegroundColor Yellow
    Write-Host "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.0-stable.zip" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter موجود: $(flutter --version | Select-Object -First 1)" -ForegroundColor Green

# Get packages
Write-Host "`n📦 تحميل الحزم..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ فشل في تحميل الحزم" -ForegroundColor Red
    exit 1
}
Write-Host "✅ تم تحميل الحزم بنجاح" -ForegroundColor Green

# Create assets placeholder
Write-Host "`n📁 تجهيز المجلدات..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "assets\images" -Force | Out-Null
New-Item -ItemType Directory -Path "assets\fonts" -Force | Out-Null
New-Item -ItemType Directory -Path "assets\sounds" -Force | Out-Null

Write-Host "✅ تم تجهيز كل شيء" -ForegroundColor Green
Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "  ✅ تم تجهيز المشروع!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "لتشغيل التطبيق:" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor Yellow
Write-Host ""
Write-Host "لإنشاء ملف APK:" -ForegroundColor White
Write-Host "  flutter build apk" -ForegroundColor Yellow
