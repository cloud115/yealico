# T16 Acceptance Checklist (MVP)

## Scope

This checklist validates MVP behavior across:

- rule import
- catalog/detail/content parsing flows
- image reader
- video parsing and playback entry
- explicit out-of-scope boundaries

## Environment

- Platform targets: Android, Web
- Build modes:
  - dev: detailed errors
  - prod: generic user-facing errors

## Acceptance Matrix

### A. Rule Import

1. Import valid GitHub Raw rule
- Steps:
  - Open home page
  - Click `Import Rule (T04)`
  - Input valid raw URL
  - Click `Import Rule`
  - Click `Add To Site List (T07)`
- Expected:
  - No validation failure
  - Site appears in `Imported Sites`

2. Import invalid rule (missing required fields)
- Steps:
  - Import a known invalid sample
- Expected:
  - Validation fails
  - dev mode: detailed issues list shown
  - prod mode: generic error message shown

3. Import non-GitHub-Raw URL
- Steps:
  - Input non-raw URL
- Expected:
  - Import rejected with clear message

### B. Catalog and Detail Parsing

4. Open catalog from imported site
- Steps:
  - From site card click `Open Catalog (T08)`
- Expected:
  - Catalog page loads
  - list/empty/error state behaves correctly

5. Open detail list from catalog item
- Steps:
  - On catalog item click `Open Details (T09)`
- Expected:
  - Detail page loads
  - list/empty/error state behaves correctly

### C. Image Content and Reader

6. Parse image URLs from detail item (comic/gallery)
- Steps:
  - Click `Parse Images (T10)` on detail item
- Expected:
  - Image URL list shown

7. Open image reader
- Steps:
  - Click `Open Reader (T11)`
  - Tap left/right and swipe
- Expected:
  - Page index updates
  - left/right navigation works
  - swipe navigation works

### D. Video Content and Playback Entry

8. Parse video URL from detail item (video site)
- Steps:
  - Click `Parse Video URL (T12)`
- Expected:
  - Parsed video URL shown

9. Open video player
- Steps:
  - Click `Play Video (T13)`
- Expected:
  - Player page opens
  - basic play/pause and seek controls visible

### E. Error Policy

10. Dev mode error visibility
- Steps:
  - Trigger known error (invalid import URL)
- Expected:
  - Detailed message shown

11. Prod mode error visibility
- Steps:
  - Run with `main_prod.dart`
  - Trigger same error
- Expected:
  - Generic fallback message shown

### F. Explicit Out-of-Scope Verification

12. Novel/text-reader support
- Expected:
  - Not provided in MVP flow

13. Browser JS execution dependency
- Expected:
  - Unsupported sites fail parsing (no JS fallback runtime)

14. WebView/original-page fallback on parsing failure
- Expected:
  - Not used; show error message only

15. Built-in rule marketplace
- Expected:
  - Not present

## Pass Criteria

- All mandatory in-scope items (A-D, E) pass.
- Out-of-scope items (F) are confirmed as intentionally absent.
