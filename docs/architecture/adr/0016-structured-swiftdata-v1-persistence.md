# ADR 0016: Flat SwiftData V1 Persistence

## Status

Accepted

## Context

Cujana 1.0.0 locks the first local data model as SwiftData schema V1. The model is expected to evolve through explicit SwiftData schema versions and migrations, and a later expansion should be compatible with CloudKit.

Storing domain aggregates as large `Data` or JSON payloads inside SwiftData would hide schema changes from SwiftData, weaken future migration coverage, and make CloudKit-oriented persistence harder to reason about.

Pollen and weather data come from separate sources and must be refreshable independently. They also need a flat shape for storage and downstream use: one row per entry with the collection timestamp, the entry timestamp, and one column per possible value.

## Decision

SwiftData V1 stores environmental data as flat, source-specific records:

- `PollenEntryRecord` stores one pollen row with `collectedAt`, `entryDate`, coordinate/source metadata, one optional column for every pollen type, and optional allergy-risk columns.
- `WeatherEntryRecord` stores one weather row with `collectedAt`, `entryDate`, coordinate metadata, temperature, condition code, humidity, and wind speed.

Pollen and weather use separate repository methods for latest-entry checks and saves, so they can refresh independently. Saving new data replaces only rows for the same coordinate, entry timestamp, and row kind; unrelated source rows and other timestamps are kept.

The repository adds a SwiftLint custom rule that rejects suspicious `Data` properties in SwiftData `@Model` types when their names indicate JSON/blob storage, such as `payload`, `blob`, `json`, `encoded`, or `serialized`.

## Consequences

- Schema changes remain visible in `CujanaSchemaV1` and future versioned schemas.
- Future migrations must model changed fields and relationships explicitly.
- Legitimate binary assets require deliberate naming and review instead of being introduced as generic JSON payloads.
