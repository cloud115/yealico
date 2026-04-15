# Project Baseline Downgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Downgrade the repository baseline to Flutter `3.27.4` and Dart `3.6.2`, then revalidate `flutter pub get`, `flutter analyze`, `flutter build web`, and `flutter build apk` on macOS 12 Intel.

**Architecture:** Keep runtime code stable unless validation proves source incompatibility. Move the minimum viable surface first: package SDK constraints, Android Gradle versions, developer and release documentation, then local Java and Android SDK setup, and finally full repo validation with captured evidence.

**Tech Stack:** Flutter `3.27.4`, Dart `3.6.2`, Android Gradle Plugin `8.1.0`, Kotlin Gradle Plugin `1.8.22`, Gradle `8.3`, JDK `17`, Android SDK API `35`, Homebrew

---

## File Map

- Modify: `pubspec.yaml`
  - Lower the Dart SDK constraint to a range supported by Dart `3.6.2`
  - Downgrade `flutter_lints` to a version compatible with the downgraded Flutter baseline
- Modify: `pubspec.lock`
  - Re-resolve packages against the downgraded SDK baseline
- Modify: `android/settings.gradle.kts`
  - Downgrade AGP and Kotlin plugin versions to match the Flutter `3.27.4` template family
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
  - Downgrade the Gradle wrapper to `8.3`
- Modify: `android/app/build.gradle.kts`
  - Change Java and Kotlin compile targets from `17` to `1.8`
- Modify: `README.md`
  - Publish the new official developer baseline and required Android toolchain packages
- Modify: `docs/README.md`
  - Add repository-wide build baseline details
- Modify: `docs/release/t17-github-release-process.md`
  - Add build-environment prerequisites for release builds
- Modify: `docs/release/t17-release-checklist.md`
  - Add Flutter, JDK, Android SDK, and proxy preflight checks
- Create: `android/local.properties` (local only, do not commit)
  - Point Gradle at the local Flutter `3.27.4` SDK and Android SDK root
- Create: `docs/progress/2026-04-16-environment-baseline-downgrade.md`
  - Record validation evidence after the downgraded baseline passes

## Implementation Notes

- Use `/Users/Jerry/flutter/bin/flutter` indirectly by exporting `/Users/Jerry/flutter/bin` onto `PATH` before every Flutter command in this plan.
- `android/local.properties` is already ignored by `android/.gitignore`; create it locally and never stage it.
- No application source files are planned for modification. If validation disproves that assumption, stop and write a focused follow-up plan for the exact failing source file instead of freelancing broad refactors.

### Task 1: Downgrade the Dart baseline and re-resolve packages

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

- [ ] **Step 1: Reproduce the current package-resolution failure**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
flutter --version
flutter pub get
```

Expected:

- `flutter --version` prints Flutter `3.27.4` and Dart `3.6.2`
- `flutter pub get` fails with a message equivalent to `requires SDK version ^3.11.4`

- [ ] **Step 2: Edit `pubspec.yaml` to the downgraded baseline**

Update the SDK and lint sections to exactly this shape:

```yaml
environment:
  sdk: '>=3.6.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  html: ^0.15.6
  video_player: ^2.9.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

Keep the rest of `pubspec.yaml` unchanged.

- [ ] **Step 3: Regenerate `pubspec.lock`**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
flutter pub get
```

Expected:

- Command exits successfully
- `pubspec.lock` is rewritten for the downgraded SDK range

- [ ] **Step 4: Verify only the intended package-baseline files changed**

Run:

```bash
git diff -- pubspec.yaml pubspec.lock
```

Expected:

- `pubspec.yaml` shows the lowered Dart range and `flutter_lints: ^5.0.0`
- `pubspec.lock` shows a fresh package resolution

- [ ] **Step 5: Commit**

Run:

```bash
git add pubspec.yaml pubspec.lock
git commit -m "build: downgrade dart baseline"
```

### Task 2: Realign the Android Gradle stack with Flutter 3.27.4

**Files:**
- Modify: `android/settings.gradle.kts`
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Capture the current Android toolchain mismatch**

Run:

```bash
rg -n "8.11.1|2.2.20|gradle-8.14|VERSION_17" \
  android/settings.gradle.kts \
  android/gradle/wrapper/gradle-wrapper.properties \
  android/app/build.gradle.kts
```

Expected:

- `android/settings.gradle.kts` reports `8.11.1` and `2.2.20`
- `android/gradle/wrapper/gradle-wrapper.properties` reports `gradle-8.14`
- `android/app/build.gradle.kts` reports `VERSION_17`

- [ ] **Step 2: Edit the Android Gradle files**

Update `android/settings.gradle.kts` so the plugin block becomes:

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}
```

Update `android/gradle/wrapper/gradle-wrapper.properties` so it contains:

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
```

Update the compile options in `android/app/build.gradle.kts` to:

```kotlin
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
```

Keep every other line in those files unchanged.

- [ ] **Step 3: Verify the downgraded Android versions are in place**

Run:

```bash
rg -n "8.1.0|1.8.22|gradle-8.3|VERSION_1_8" \
  android/settings.gradle.kts \
  android/gradle/wrapper/gradle-wrapper.properties \
  android/app/build.gradle.kts
```

Expected:

- All four downgraded values are present
- No old `8.11.1`, `2.2.20`, `gradle-8.14`, or `VERSION_17` values remain in those files

- [ ] **Step 4: Commit**

Run:

```bash
git add android/settings.gradle.kts \
  android/gradle/wrapper/gradle-wrapper.properties \
  android/app/build.gradle.kts
git commit -m "build: align android stack with flutter 3.27.4"
```

### Task 3: Publish the downgraded baseline in repository docs

**Files:**
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `docs/release/t17-github-release-process.md`
- Modify: `docs/release/t17-release-checklist.md`

- [ ] **Step 1: Add the developer baseline to `README.md`**

Insert this section after `## Version Baseline`:

```md
## Development Baseline

- Flutter SDK: `3.27.4`
- Dart SDK: `3.6.2`
- Android build JDK: `17`
- Android SDK packages:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- Proxy for restricted networks:
  - shell `HTTP_PROXY` and `HTTPS_PROXY`: `http://127.0.0.1:7890`
  - Gradle proxy is already configured in `android/gradle.properties`
```

- [ ] **Step 2: Add the repository-wide toolchain baseline to `docs/README.md`**

Insert this section after `## Current Baseline`:

```md
## Development Toolchain Baseline

- Flutter SDK: `3.27.4`
- Dart SDK: `3.6.2`
- Android build JDK: `17`
- Android SDK target: API `35`
- Required Android SDK packages:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
```

- [ ] **Step 3: Add build prerequisites to the release process docs**

Insert this section after `## Release Inputs` in `docs/release/t17-github-release-process.md`:

```md
## Build Environment

- Flutter SDK: `3.27.4`
- Dart SDK: `3.6.2`
- JDK: `17`
- Android SDK packages:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- If the current network requires a proxy, export `HTTP_PROXY` and `HTTPS_PROXY` to `http://127.0.0.1:7890` before running release builds.
```

Insert these preflight items under `## Pre-Release` in `docs/release/t17-release-checklist.md`:

```md
- [ ] `flutter --version` reports Flutter `3.27.4`
- [ ] `dart --version` reports Dart `3.6.2`
- [ ] `java -version` reports JDK `17`
- [ ] Android SDK contains:
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- [ ] If current network is restricted, `HTTP_PROXY` and `HTTPS_PROXY` are set to `http://127.0.0.1:7890`
```

- [ ] **Step 4: Verify the docs advertise the downgraded baseline**

Run:

```bash
rg -n "3.27.4|3.6.2|JDK|platforms;android-35|ndk;26.1.10909125|127.0.0.1:7890" \
  README.md \
  docs/README.md \
  docs/release/t17-github-release-process.md \
  docs/release/t17-release-checklist.md
```

Expected:

- Every new baseline value appears in the four documentation files

- [ ] **Step 5: Commit**

Run:

```bash
git add README.md \
  docs/README.md \
  docs/release/t17-github-release-process.md \
  docs/release/t17-release-checklist.md
git commit -m "docs: publish downgraded toolchain baseline"
```

### Task 4: Provision the local Java and Android SDK toolchain

**Files:**
- Create: `android/local.properties` (local only, do not commit)

- [ ] **Step 1: Install JDK 17 and Android command-line tools**

Run:

```bash
brew install --cask temurin@17
brew install --cask android-commandlinetools
```

Expected:

- Homebrew installs both casks successfully

- [ ] **Step 2: Export the local Java and Android SDK environment**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
java -version
sdkmanager --version
```

Expected:

- `java -version` reports Java `17`
- `sdkmanager --version` prints a version number

- [ ] **Step 3: Accept Android SDK licenses and install the required packages**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" --licenses
sdkmanager --sdk_root="$ANDROID_SDK_ROOT" \
  "platform-tools" \
  "platforms;android-35" \
  "build-tools;35.0.0" \
  "ndk;26.1.10909125"
```

Expected:

- All requested packages install under `/usr/local/share/android-commandlinetools`

- [ ] **Step 4: Point Flutter and Gradle at the local toolchain**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
flutter config --jdk-dir "$JAVA_HOME"
flutter config --android-sdk "$ANDROID_SDK_ROOT"
```

Create `android/local.properties` with exactly this content:

```properties
sdk.dir=/usr/local/share/android-commandlinetools
flutter.sdk=/Users/Jerry/flutter
```

- [ ] **Step 5: Verify Flutter sees the Android toolchain**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
flutter doctor -v
```

Expected:

- Android toolchain passes
- Xcode and CocoaPods may still be reported as missing; that is acceptable for this repository

### Task 5: Run full validation and capture the results

**Files:**
- Create: `docs/progress/2026-04-16-environment-baseline-downgrade.md`

- [ ] **Step 1: Run analyzer validation**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
flutter analyze
```

Expected:

- Command exits successfully
- Output ends with `No issues found!`

- [ ] **Step 2: Run web build validation**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
flutter build web --release --dart-define=APP_FLAVOR=prod
test -f build/web/index.html
```

Expected:

- `flutter build web` exits successfully
- `build/web/index.html` exists

- [ ] **Step 3: Run Android APK build validation**

Run:

```bash
export PATH="/Users/Jerry/flutter/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export ANDROID_SDK_ROOT=/usr/local/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
flutter build apk --release --build-name=1.0.0 --build-number=1
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

Expected:

- `flutter build apk` exits successfully
- `build/app/outputs/flutter-apk/app-release.apk` exists

- [ ] **Step 4: Record the validation evidence**

Create `docs/progress/2026-04-16-environment-baseline-downgrade.md` with exactly this content:

```md
# Progress - 2026-04-16 (Environment Baseline Downgrade)

## Completed

- Lowered the repository baseline to Flutter `3.27.4` and Dart `3.6.2`
- Realigned the Android Gradle stack to AGP `8.1.0`, Kotlin `1.8.22`, and Gradle `8.3`
- Updated developer and release documentation for the downgraded toolchain
- Configured local Java `17` and Android SDK tooling for macOS 12 Intel

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
- Android build JDK: `17`
- Android SDK root: `/usr/local/share/android-commandlinetools`
```

- [ ] **Step 5: Commit**

Run:

```bash
git add docs/progress/2026-04-16-environment-baseline-downgrade.md
git commit -m "docs: record downgraded baseline validation"
```

## Self-Review

- Spec coverage:
  - downgrade Flutter/Dart baseline: Task 1
  - realign Android build configuration: Task 2
  - update official baseline docs: Task 3
  - provision local Android toolchain: Task 4
  - prove `pub get`, `analyze`, `build web`, and `build apk`: Tasks 1 and 5
- Placeholder scan:
  - no deferred implementation markers remain
  - every repo file change names the exact file and shows concrete content
- Type and naming consistency:
  - one baseline only: Flutter `3.27.4`, Dart `3.6.2`, AGP `8.1.0`, Kotlin `1.8.22`, Gradle `8.3`, JDK `17`
