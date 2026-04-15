# T08 Catalog Parse and Display

## Goal

For each imported site, fetch index page HTML and display parsed catalog entries.

## Implemented

- Added `CatalogLoader` abstraction and `RuntimeCatalogLoader`.
- Added `SiteCatalogPage`:
  - async catalog loading
  - loading/error/empty/list states
  - basic item metadata rendering (`id`, `title`, `detailUrl`, optional `cover`)
- Home page site cards now include `Open Catalog (T08)` entry.

## Boundaries

- This step only covers index/catalog list.
- No detail page parsing UI in this step (`T09`).
- No image/video content page UI in this step (`T10+`).
