param(
  [string]$BuildName = "1.0.0",
  [string]$BuildNumber = "1"
)

$ErrorActionPreference = "Stop"

Write-Host "[T17] Building release artifacts..."

Write-Host "[1/3] Flutter pub get"
flutter pub get

Write-Host "[2/3] Build Android APK (release)"
flutter build apk --release --build-name=$BuildName --build-number=$BuildNumber

Write-Host "[3/3] Build Web bundle (release)"
flutter build web --release --dart-define=APP_FLAVOR=prod

Write-Host ""
Write-Host "Artifacts:"
Write-Host "  APK: build/app/outputs/flutter-apk/app-release.apk"
Write-Host "  Web: build/web/"
Write-Host ""
Write-Host "Done."
