# Release v<version>

Version note: `<version>` should match the active PRD version.

## Highlights

- Rule import from GitHub Raw URL
- Rule validation with dev/prod error policy
- Catalog/detail/content parsing flows
- Image reader experience
- Video URL parse and basic playback entry

## Included Scope

- T01-T17 planned MVP tasks (implementation + QA + release process)

## Build Artifacts

- Android APK: `app-release.apk`
- Web bundle: `build/web` (optional attachment as zip)

## Validation

- Automated tests: `flutter test` passed
- Manual checklist: `docs/qa/t16-acceptance-checklist.md`

## Known Limitations

- Browser JS-dependent sites are unsupported
- No fallback to original webpage/WebView
- Novel/text reader is out of MVP scope

## Upgrade Notes

- Fresh install recommended for MVP baseline
- Rule files must conform to `rule-schema-v1`
