# T17 GitHub Release Process

## Goal

Define a repeatable release delivery process for MVP.

## Release Inputs

- Source branch: `main`
- Version:
  - app version (`build-name`, must match the PRD version)
  - build number (`build-number`)
- Changelog notes

## Build Artifacts

- Android APK:
  - `build/app/outputs/flutter-apk/app-release.apk`
- Web bundle:
  - `build/web/`

Build script:

- `scripts/release/build_release_artifacts.ps1`

## Release Steps

1. Ensure workspace clean and tests pass
- `flutter test`

2. Build release artifacts
- `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName <x.y.z> -BuildNumber <n>`

3. Prepare release notes
- Use template:
  - `docs/release/t17-release-notes-template.md`

4. Create Git tag
- `git tag v<x.y.z>`
- `git push origin v<x.y.z>`

5. Create GitHub Release
- Title: `v<x.y.z>`
- Attach:
  - APK
  - (optional) zip of `build/web`
- Paste release notes

6. Post-release verification
- Download APK from release page and install check
- Open web bundle in static hosting and smoke test

## Rollback Guidance

- If release is invalid:
  - mark release as pre-release or draft
  - publish hotfix from next patch version (`x.y.z+1`)
