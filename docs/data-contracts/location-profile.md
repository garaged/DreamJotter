# LocationProfile Data Contract

Status: specified
Milestone: 8

## Purpose

`LocationProfile` stores user-authored location information as canonical project metadata.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable project-local identifier. |
| `name` | String | Yes | Display and canonical autocomplete name. |
| `aliases` | Array<String> | Yes | Empty array when unused. |
| `description` | String? | No | Freeform location description. |
| `notes` | String? | No | Lightweight notes. |
| `createdAt` | String | Yes | ISO-8601 timestamp. |
| `updatedAt` | String | Yes | ISO-8601 timestamp. |
| `archived` | Boolean | Yes | Archived locations are hidden from primary suggestions by default. |

## Validation Rules

- `id` must be non-empty and stable.
- `name` must be non-empty after trimming.
- `aliases` must not contain normalized duplicates.
- `createdAt` is immutable after creation.
- `updatedAt` changes when user-authored fields change.

## Codable Expectation

Must be Codable with stable JSON keys.

## Equatable Expectation

Should be Equatable for tests and dirty-state comparisons.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "location-coffee-shop",
  "name": "COFFEE SHOP",
  "aliases": ["CAFE"],
  "description": "A narrow neighborhood cafe near the train station.",
  "notes": "Use as recurring safe place.",
  "createdAt": "2026-07-01T10:00:00Z",
  "updatedAt": "2026-07-01T10:20:00Z",
  "archived": false
}
```

## Migration and Versioning Notes

Future production details should be additive and optional.

## Platform Neutrality Concerns

No map, geocoding, SwiftData, CloudKit, or platform URL types.
