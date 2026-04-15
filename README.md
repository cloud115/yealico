# Yealico

Rule-driven Flutter reader MVP for Android, with Web support for debugging.

## Current Stage

- `T01` completed: Flutter project shell, dev/prod entrypoints, Android+Web targets.
- `T02` completed: rule schema v1 document and sample JSON files.
- `T03` completed: core data models and storage contracts.
- `T04` completed: GitHub Raw rule import flow (download + preprocess + import request).
- `T05` completed: schema validator with structured errors and import-time validation.
- `T06` completed: runtime HTML request/parse/extraction engine.
- `T07` completed: site list page with imported site metadata display.
- `T08` completed: site catalog parsing and catalog list page.
- `T09` completed: detail parsing and detail list page.
- `T10` completed: image content parsing and URL list page.
- `T11` completed: image reader with tap/swipe page turning.
- `T12` completed: video URL parsing and display page.
- `T13` completed: video player integration with basic controls.
- `T14` completed: dev/prod error message split and internal logging policy.
- `T15` completed: runtime cache and baseline performance optimization.
- `T16` completed: acceptance checklist and test report preparation.
- `T17` completed: release process and delivery artifacts (web build verified, apk build network-blocked).

## Rule Docs

- Schema: `docs/rules/rule-schema-v1.md`
- Samples: `docs/rules/samples/`
- Import flow: `docs/architecture/t04-rule-import-flow.md`
- Validator: `docs/architecture/t05-rule-validator.md`
- Runtime engine: `docs/architecture/t06-rule-runtime-engine.md`
- Site list page: `docs/architecture/t07-site-list-page.md`
- Catalog page: `docs/architecture/t08-catalog-page.md`
- Detail page: `docs/architecture/t09-detail-page.md`
- Image content parse: `docs/architecture/t10-image-content-parse.md`
- Image reader: `docs/architecture/t11-image-reader.md`
- Video content parse: `docs/architecture/t12-video-content-parse.md`
- Video player: `docs/architecture/t13-video-player.md`
- Error and logging policy: `docs/architecture/t14-error-and-logging-policy.md`
- Cache and performance: `docs/architecture/t15-cache-and-performance.md`
- Acceptance checklist: `docs/qa/t16-acceptance-checklist.md`
- Test report: `docs/qa/t16-test-report-2026-04-15.md`
- Release process: `docs/release/t17-github-release-process.md`
- Release checklist: `docs/release/t17-release-checklist.md`
- Delivery report: `docs/release/t17-delivery-report-2026-04-15.md`

## Run

- Dev entry: `flutter run -t lib/main_dev.dart`
- Prod entry: `flutter run -t lib/main_prod.dart`
