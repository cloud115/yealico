# T17 Release Checklist

## Pre-Release

- [ ] Working tree is clean
- [ ] Version is confirmed (`build-name` must follow the PRD version)
- [ ] `flutter --version` reports Flutter `3.27.4`
- [ ] `dart --version` reports Dart `3.6.2`
- [ ] `java -version` reports JDK `17`
- [ ] Android SDK contains:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- [ ] If current network is restricted, `HTTP_PROXY` and `HTTPS_PROXY` are set to `http://127.0.0.1:7890`
- [ ] `flutter test` passes
- [ ] Manual acceptance checklist reviewed (`docs/qa/t16-acceptance-checklist.md`)

## Build

- [ ] Run:
  - `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName <x.y.z> -BuildNumber <n>`
- [ ] Verify artifact exists:
  - `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Verify artifact exists:
  - `build/web/`

## GitHub Release

- [ ] Create tag `v<x.y.z>`
- [ ] Push tag
- [ ] Create release with title `v<x.y.z>`
- [ ] Attach APK
- [ ] Attach web bundle zip (optional)
- [ ] Fill notes using template `docs/release/t17-release-notes-template.md`

## Post-Release

- [ ] Smoke install APK
- [ ] Smoke run web bundle
- [ ] Confirm release visibility and downloadable assets

## Build Network Requirement

- [ ] Gradle dependency download path is reachable from current network
