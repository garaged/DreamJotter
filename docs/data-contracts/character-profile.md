# CharacterProfile Data Contract

Status: specified
Milestone: 8

## Purpose

`CharacterProfile` stores user-authored character information as canonical project metadata. It is separate from parsed character cues and editor suggestions.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable project-local identifier. |
| `name` | String | Yes | Display and canonical autocomplete name. |
| `aliases` | Array<String> | Yes | Empty array when unused. |
| `role` | String? | No | Beginner-friendly role label. |
| `description` | String? | No | Freeform description. |
| `motivation` | String? | No | What drives the character. |
| `want` | String? | No | External goal. |
| `need` | String? | No | Internal need. |
| `backstory` | String? | No | Freeform history. |
| `notes` | String? | No | Lightweight profile notes. |
| `createdAt` | String | Yes | ISO-8601 timestamp. |
| `updatedAt` | String | Yes | ISO-8601 timestamp. |
| `archived` | Boolean | Yes | Archived profiles are hidden from primary suggestions by default. |

## Validation Rules

- `id` must be non-empty and stable after creation.
- `name` must be non-empty after trimming whitespace.
- `aliases` must not contain exact duplicates after normalization.
- `createdAt` must not change after creation.
- `updatedAt` changes when user-authored fields change.

## Codable Expectation

Must be Codable with stable JSON keys.

## Equatable Expectation

Should be Equatable for tests, diffing, and dirty-state comparisons.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "character-elena",
  "name": "ELENA",
  "aliases": ["LENA"],
  "role": "Protagonist",
  "description": "A pianist avoiding a difficult family truth.",
  "motivation": "Keep the concert on track.",
  "want": "Win the audition.",
  "need": "Tell the truth to her sister.",
  "backstory": "Left home at seventeen.",
  "notes": "Keep dialogue clipped in act one.",
  "createdAt": "2026-07-01T10:00:00Z",
  "updatedAt": "2026-07-01T10:15:00Z",
  "archived": false
}
```

## Migration and Versioning Notes

Future fields should be optional or given defaults. Archived status may later become a richer enum, but Boolean is sufficient for Milestone 8.

## Platform Neutrality Concerns

No SwiftUI, AppKit, UIKit, SwiftData, CloudKit, `NSAttributedString`, or platform URL types.
