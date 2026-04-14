# T04 Rule Import Flow

## Goal

Implement the MVP import chain:

1. user inputs GitHub Raw URL
2. app downloads raw text
3. app preprocesses payload
4. app forms `RuleImportRequest`

This step intentionally excludes schema validation and persistence.

## Implemented Components

- `RuleImportRequest` model
  - source URL
  - normalized raw JSON
  - parsed JSON map
  - import timestamp
- `RuleRawFetcher`
  - HTTP downloader abstraction
- `RuleImportService`
  - input checks
  - GitHub Raw host check
  - response status check
  - BOM removal and trim
  - JSON decode and root-object check
- `RuleImportPage`
  - text input
  - import button
  - success/error display

## Boundaries

- No schema field-level validation (`T05`).
- No storage write (`T03` contracts only).
- No site list integration yet (`T07`).
