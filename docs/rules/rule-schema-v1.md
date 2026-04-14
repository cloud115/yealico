# Rule Schema v1 (MVP Freeze)

This document freezes the JSON rule contract used by the Yealico Flutter MVP.

## Scope

- Format: JSON only.
- One rule file maps to one site.
- Only sites that do not require browser-side JavaScript are in MVP scope.
- DRM content is out of scope.
- Fallback to original webpage/WebView is out of scope.

## Root Object

Required root fields:

- `version`
- `meta`
- `request`
- `routes`
- `indexRule`
- `detailRule`
- `contentRule`

### `version`

- Type: `string`
- Fixed value for this document: `"1.0"`

### `meta`

- Type: `object`
- Required fields:
  - `siteId` (`string`, unique identifier)
  - `siteName` (`string`)
  - `baseUrl` (`string`, absolute URL)
  - `contentType` (`string`, one of `comic`, `gallery`, `video`)

### `request`

- Type: `object`
- Required fields:
  - `method` (`string`, fixed to `GET` in MVP)
- Optional fields:
  - `charset` (`string`)
  - `timeoutMs` (`integer`, > 0)
  - `headers` (`object`, key/value string pairs)

### `routes`

- Type: `object`
- Required fields:
  - `indexUrl` (`string`, absolute URL)
  - `detailUrlMode` (`string`, fixed to `direct` in MVP)

## Extractor Object

Any extractor field uses the same object structure:

- `selector` (`string`, CSS selector) required
- `function` (`string`, one of `text`, `html`, `attr`) required
- `param` (`string`, required when `function` is `attr`)
- `regex` (`string`, optional)
- `replacement` (`string`, optional; only used with `regex`)
- `trim` (`boolean`, optional)
- `absoluteUrl` (`boolean`, optional)

## `indexRule`

- Type: `object`
- Required fields:
  - `item.selector` (`string`)
  - `fields.title` (`extractor`)
  - `fields.detailUrl` (`extractor`)
- Optional fields:
  - `fields.id` (`extractor`)
  - `fields.cover` (`extractor`)

## `detailRule`

- Type: `object`
- Required fields:
  - `item.selector` (`string`)
  - `fields.title` (`extractor`)
  - `fields.url` (`extractor`)
- Optional fields:
  - `title` (`extractor`)

## `contentRule`

`contentRule` depends on `meta.contentType`:

- If `comic` or `gallery`:
  - `images.item.selector` (`string`) required
  - `images.fields.url` (`extractor`) required
- If `video`:
  - `video.url` (`extractor`) required

Optional for all types:

- `secondLevel` (`object`)
  - Allows one additional page request at most.
  - Must not define nested second-level chains.

## MVP Validation Rules

- Reject if `request.method != "GET"`.
- Reject if `routes.detailUrlMode != "direct"`.
- Reject if required fields are missing.
- Reject if extractor `function = "attr"` and `param` is missing.
- Reject if `contentRule` branch does not match `meta.contentType`.

## Non-Goals (Explicit)

- JavaScript execution in browser context
- Cookie/login sync and browser session continuity
- Built-in rule marketplace
- Multi-site merge in one rule file
- Full backward compatibility with complex Yealico rule formats

## Sample Files

Samples are in `docs/rules/samples/`:

- `valid-comic-rule.json`
- `valid-video-rule.json`
- `invalid-missing-required-field.json`
- `invalid-unsupported-method.json`
- `invalid-unsupported-detail-url-mode.json`
