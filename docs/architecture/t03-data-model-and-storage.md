# T03 Data Model and Local Storage Design

## Goal

Define stable core entities and storage interfaces for:

- site and rule persistence
- parse result transfer objects
- reading history persistence

This step only freezes contracts. It does not pick or implement a concrete database engine.

## Core Entities

### `ContentType`

- Enum: `comic`, `gallery`, `video`
- Matches `rule-schema-v1` `meta.contentType`

### `RuleSnapshot`

- `version`
- `sourceUrl`
- `rawJson`
- `importedAt`

### `SiteRecord`

- `siteId` (stable identity)
- `siteName`
- `baseUrl`
- `contentType`
- `rule` (`RuleSnapshot`)
- `createdAt`
- `updatedAt`
- `isEnabled`

### Parse Result DTOs

- `CatalogEntry`: index/list result
- `DetailEntry`: chapter/album/episode item
- `ContentPayload`: final playable/readable payload
  - image URL list for `comic/gallery`
  - video URL for `video`

### `ReadingHistoryEntry`

- `siteId`
- `itemId`
- `itemTitle`
- `detailUrl`
- `progressIndex`
- `lastContentUrl`
- `updatedAt`

## Storage Interfaces

- `SiteStore`
  - list/get/upsert/remove site records
- `RuleStore`
  - get/save/remove site rule snapshots
- `ReadingHistoryStore`
  - list/get/upsert/remove reading history entries
- `AppStorage`
  - aggregate access point: `sites`, `rules`, `history`

## Design Decisions

- Keep model serialization in plain `Map<String, Object?>` for now.
- Keep storage layer DB-agnostic in `T03`.
- Delay concrete DB selection (`Isar` vs `Drift`) to implementation task where persistence engine is introduced.

## Non-Goals in T03

- No database package dependency.
- No migration scripts.
- No repository implementation.
- No parser/network/business workflow implementation.
