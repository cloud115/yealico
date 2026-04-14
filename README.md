# Yealico

Rule-driven Flutter reader MVP for Android, with Web support for debugging.

## Current Stage

- `T01` completed: Flutter project shell, dev/prod entrypoints, Android+Web targets.
- `T02` completed: rule schema v1 document and sample JSON files.
- `T03` completed: core data models and storage contracts.
- `T04` completed: GitHub Raw rule import flow (download + preprocess + import request).
- `T05` completed: schema validator with structured errors and import-time validation.
- `T06` completed: runtime HTML request/parse/extraction engine.

## Rule Docs

- Schema: `docs/rules/rule-schema-v1.md`
- Samples: `docs/rules/samples/`
- Import flow: `docs/architecture/t04-rule-import-flow.md`
- Validator: `docs/architecture/t05-rule-validator.md`
- Runtime engine: `docs/architecture/t06-rule-runtime-engine.md`

## Run

- Dev entry: `flutter run -t lib/main_dev.dart`
- Prod entry: `flutter run -t lib/main_prod.dart`
