# Docs Overview

This directory is the documentation baseline for PRD `1.0.0`.

## Current Baseline

- Product baseline: `docs/PRD/1.0.0.md`
- App version baseline: `1.0.0+1`
- Delivery status: PRD `1.0.0` scope is substantially complete
- Release baseline: `v1.0.0`

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

## Versioning Rule

- PRD version is the source of truth for release versioning.
- Flutter `build-name` should follow the PRD version, for example `1.0.0`, `1.0.1`.
- Flutter `build-number` remains an incrementing internal build counter.
- Git tag and release title should match the PRD version, for example `v1.0.0`.

## Directory Guide

- `PRD/`
  Product requirement documents by released/planned version.
- `architecture/`
  Implementation and design notes for completed feature areas.
- `progress/`
  Task-by-task execution records and delivery notes.
- `qa/`
  Acceptance checklist and test reports.
- `release/`
  Release notes, delivery report, checklist, and release process.
- `rules/`
  Rule schema and sample rule files.

## Suggested Start Point For 1.0.1

1. Add the next PRD as `docs/PRD/1.0.1.md`.
2. Keep `pubspec.yaml` `version` aligned with the PRD version.
3. Add new progress notes under `docs/progress/`.
4. Update or append architecture notes only for changed areas.
5. Prepare QA and release notes against the `1.0.1` scope.
