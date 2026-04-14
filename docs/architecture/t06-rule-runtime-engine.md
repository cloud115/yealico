# T06 HTML Runtime Engine

## Goal

Implement MVP runtime execution for:

- unified HTTP request from rule config
- HTML parsing
- selector-based extraction
- URL normalization

## Implemented Components

- `HtmlPageFetcher`
  - GET request execution
  - optional headers/timeout/charset handling
  - normalized response body output
- `ExtractorEngine`
  - supports extractor fields:
    - `selector`
    - `function` (`text`/`html`/`attr`)
    - `param`
    - `regex` + `replacement`
    - `trim`
    - `absoluteUrl`
- `RuleRuntimeEngine`
  - `parseIndex`
  - `parseDetail`
  - `parseContent` for `comic/gallery/video`
- `RuleRuntimeService`
  - loads pages with request config
  - delegates parsing to runtime engine

## Boundaries

- No second-level request chain execution yet.
- No UI list/detail/reader integration yet.
- No persistence integration yet.
