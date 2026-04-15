# Progress - 2026-04-16 (Environment Baseline Downgrade)

## Completed

- Lowered the repository baseline to Flutter `3.27.4` and Dart `3.6.2`
- Realigned the Android Gradle stack to AGP `8.1.0`, Kotlin `1.8.22`, and Gradle `8.3`
- Updated developer and release documentation for the downgraded toolchain
- Configured local Java `17` and Android SDK tooling for macOS 12 Intel
- Patched callback parameter names and one deprecated color API so the downgraded baseline passes analysis and web compilation

## Validation

- `flutter pub get`: passed
- `flutter analyze`: passed
- `flutter build web --release --dart-define=APP_FLAVOR=prod`: passed
- `flutter build apk --release --build-name=1.0.0 --build-number=1`: passed

## Environment

- Host OS: macOS `12.7.6`
- CPU architecture: `x86_64`
- Flutter SDK: `3.27.4`
- Dart SDK: `3.6.2`
- Android build JDK: `17.0.18`
- Android SDK root: `/Users/Jerry/Library/Android/sdk`
