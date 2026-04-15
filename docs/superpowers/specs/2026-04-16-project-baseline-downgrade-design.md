# Project Baseline Downgrade Design

## Summary

This design downgrades the repository's official Flutter and Dart development baseline so the project can be developed and validated on macOS 12 Intel hardware without upgrading the operating system.

The chosen target baseline is:

- Flutter `3.27.4`
- Dart `3.6.2`
- Android Gradle stack aligned near the Flutter `3.27.4` template:
  - Android Gradle Plugin `8.1.0`
  - Kotlin Gradle Plugin `1.8.22`
  - Gradle wrapper `8.3`

The minimum success criteria for this work are:

- `flutter pub get`
- `flutter analyze`
- `flutter build web`
- `flutter build apk`

## Context

The repository currently declares Dart `^3.11.4` in `pubspec.yaml`, while the available Flutter SDK that runs on this machine is Flutter `3.27.4` with Dart `3.6.2`.

An attempt to move the local environment to Flutter `3.41.6` failed because the SDK initialization reported a minimum host requirement of macOS 14, while the current machine is macOS `12.7.6` on `x86_64`.

This means the host operating system is the hard blocker. Since the system will not be upgraded, the repository baseline must move downward instead.

## Goals

- Make the repository's official baseline compatible with macOS 12 Intel development.
- Preserve existing product behavior as much as possible.
- Limit changes to baseline declarations, Android build configuration, dependency compatibility, and project documentation.
- Prove the downgraded baseline by running the four agreed validation commands.

## Non-Goals

- Refactor application architecture or business logic.
- Upgrade unrelated dependencies.
- Preserve compatibility with the previous higher Flutter/Dart baseline.
- Add iOS or macOS native targets.
- Change release scope beyond what is required to restore buildability on the downgraded baseline.

## Root Cause

The blocking issue is not network access, local proxy setup, or missing project files.

The root cause is baseline incompatibility across three layers:

1. The repository requires a Dart SDK newer than the newest Dart SDK available from the locally runnable Flutter SDK.
2. The Flutter SDK version that satisfies the repository's Dart constraint does not run on macOS 12.
3. The Android build configuration in the repository is newer than the Android template stack shipped with Flutter `3.27.4`.

Because of this, simply installing more tooling is insufficient. The repository configuration must be brought back into a version range consistent with Flutter `3.27.4`.

## Proposed Approach

### 1. Downgrade the public SDK baseline

Update project declarations and docs so the repository officially targets Flutter `3.27.4` and Dart `3.6.2`.

Primary changes:

- Lower the Dart SDK constraint in `pubspec.yaml` to a range compatible with Dart `3.6.2`.
- Update repo documentation that currently implies or depends on the higher baseline.

### 2. Realign Android build configuration

Bring the Android Gradle stack back near the Flutter `3.27.4` official template so the repo stops depending on newer Android tooling than the chosen Flutter version expects.

Primary changes:

- In `android/settings.gradle.kts`, downgrade:
  - `com.android.application` from `8.11.1` to `8.1.0`
  - `org.jetbrains.kotlin.android` from `2.2.20` to `1.8.22`
- In `android/gradle/wrapper/gradle-wrapper.properties`, downgrade Gradle from `8.14` to `8.3`
- In `android/app/build.gradle.kts`, change source and target compatibility from Java `17` to Java `1.8`
- In `android/app/build.gradle.kts`, change Kotlin `jvmTarget` from `17` to `1.8`

This is intentionally close to the Flutter `3.27.4` generated Android project shape, which reduces the chance of version skew between the Flutter tooling and the repository build files.

### 3. Minimize dependency churn

Do not proactively downgrade all pub dependencies.

Instead:

- First test whether the repo resolves once the Dart SDK constraint is lowered.
- Only if dependency resolution fails, apply the smallest possible package changes.
- Prioritize compatibility fixes in:
  - `flutter_lints`
  - platform plugins such as `video_player`
- Avoid changing runtime behavior unless resolution or compilation requires it.

### 4. Keep business code stable unless evidence requires edits

Current source review shows no obvious dependency on Dart `3.11` language features. The code primarily uses features already available in older Dart 3 releases, so application code should remain unchanged unless validation proves otherwise.

If code edits become necessary, they must be:

- directly tied to analyzer or compiler errors
- minimal and local
- free of opportunistic refactors

## Files Expected To Change

The first implementation pass is expected to modify:

- `pubspec.yaml`
- `pubspec.lock`
- `android/settings.gradle.kts`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/app/build.gradle.kts`
- `README.md`
- any release or environment documentation that defines the official baseline

Project-local environment files such as `android/local.properties` are not part of the repository baseline and should not be committed.

## Validation Sequence

Validation will run in this order:

1. Confirm the chosen SDK:
   - `flutter --version`
2. Resolve dependencies:
   - `flutter pub get`
3. Run static analysis:
   - `flutter analyze`
4. Verify web build path:
   - `flutter build web`
5. Verify Android build path after Android tooling is ready:
   - `flutter build apk`

This order isolates failures efficiently:

- if `pub get` fails, the problem is baseline or package resolution
- if `analyze` fails after `pub get`, the problem is source compatibility
- if `build web` fails after `analyze`, the problem is build-time web compatibility
- if only `build apk` fails, the problem is isolated to Android tooling or Android-specific dependencies

## Tooling Expectations

For the downgraded baseline, the repository should assume:

- Flutter SDK: `3.27.4`
- Dart SDK: `3.6.2`
- JDK: prefer Java `17` for the Android build host even if source compatibility is set to `1.8`
- Android SDK: required for `flutter build apk`
- Proxy:
  - repository Gradle downloads already route through `127.0.0.1:7890`
  - shell HTTP and HTTPS proxy variables may remain in use for network access

## Risks

### 1. Package compatibility drift

Some currently resolved package versions may have been selected under a newer Dart SDK and may not remain compatible once the SDK constraint is lowered.

Mitigation:

- re-resolve with the downgraded SDK range
- only downgrade packages that actually block resolution or compilation

### 2. Android plugin stack mismatch

Some plugin packages may assume a newer Android plugin or Java target than the downgraded Android configuration.

Mitigation:

- align the repo first with the official Flutter `3.27.4` Android template
- only widen Android changes if a plugin build proves it necessary

### 3. Documentation drift

Past release reports show successful web and Android builds under a newer environment. Downgrading the repo baseline without updating docs could leave contributors following outdated setup assumptions.

Mitigation:

- update all baseline-facing docs in the same change set
- clearly state the new official minimum environment

## Rollback Strategy

Rollback should happen in layers, not all at once:

1. If `flutter pub get` still fails, only revisit Dart constraints and pub dependencies.
2. If `flutter analyze` fails, only patch code proven incompatible with the downgraded SDK.
3. If `flutter build web` succeeds but `flutter build apk` fails, treat the remaining problem as Android-only.
4. If the full validation chain still cannot be closed after minimal fixes, start a second design round before pushing the baseline lower than Flutter `3.27.4`.

## Recommendation

Proceed with a repo-wide baseline downgrade to Flutter `3.27.4` and Dart `3.6.2`, keeping source changes minimal and using validation evidence to decide whether any dependency or code changes are actually required.

This is the lowest-risk path that matches the constraint of staying on macOS 12 Intel while keeping the repository buildable for web and Android.
