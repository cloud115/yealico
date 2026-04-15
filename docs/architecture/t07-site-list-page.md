# T07 Site List Page

## Goal

Display imported sites and their basic metadata on the home page.

## Implemented

- Home page is now stateful and maintains an in-session site list.
- Import page now returns the validated `RuleImportRequest` when user confirms.
- Added `RuleImportMapper` to map import request data to `SiteRecord`.
- Home page list card shows:
  - `siteName`
  - `siteId`
  - `contentType`
  - `baseUrl`
  - `ruleVersion`
- Re-import with same `siteId` updates existing item.

## Boundaries

- This step stores list state in memory only.
- No persistent storage implementation is introduced here.
- No index/detail/content browsing flow is introduced here.
