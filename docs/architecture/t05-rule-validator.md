# T05 Rule Validator

## Goal

Validate imported rule JSON against `rule-schema-v1` and MVP restrictions, and return clear structured errors.

## Implemented

- `RuleValidator`:
  - required root field checks
  - field type checks
  - supported enum/value checks
  - extractor checks (`text/html/attr`, `param` required for `attr`)
  - `GET`-only request method check
  - `direct`-only detail URL mode check
  - content branch checks by `meta.contentType`
  - second-level nesting constraint
- `RuleValidationIssue`:
  - `code`
  - `path`
  - `message`
- `RuleValidationResult`:
  - issues list
  - `isValid` convenience getter
- `RuleImportService` integration:
  - throws `RuleValidationException` with issue list when validation fails
- `RuleImportPage` integration:
  - displays validation errors for quick diagnosis

## Boundaries

- No DB persistence.
- No parser/runtime execution.
- No UI workflow beyond import page diagnostics.
