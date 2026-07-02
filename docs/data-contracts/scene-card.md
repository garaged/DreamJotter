# SceneCard Data Contract

Status: specified
Milestone: 8

## Purpose

`SceneCard` combines derived screenplay scene information with user-authored planning metadata.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable scene-card metadata identifier. |
| `sceneID` | String? | No | Parsed scene reference when known. |
| `heading` | String | Yes | Derived heading display text. |
| `location` | String? | No | Derived location if parsed. |
| `timeOfDay` | String? | No | Derived time of day if parsed. |
| `characters` | Array<String> | Yes | Derived character names in scene. |
| `notes` | Array<String> | Yes | Linked note IDs. |
| `plotlineTags` | Array<String> | Yes | User-authored tags. |
| `status` | String | Yes | `idea`, `outlined`, `drafted`, `needsRewrite`, `reviewed`, `locked`, or `ready`. |
| `summary` | String? | No | User-authored scene summary. |
| `userMetadata` | Object | Yes | Future-safe user-authored metadata map. |
| `derivedMetadata` | Object | Yes | Rebuildable parse-derived metadata map. |

## Validation Rules

- `id` must be non-empty.
- `heading` must be non-empty for parsed scenes; placeholder text may be used for unresolved cards.
- `status` must be one of the allowed status values.
- User metadata and derived metadata must stay separate.

## Codable Expectation

Must be Codable for persisted user-authored metadata. Derived metadata may be omitted and rebuilt where practical.

## Equatable Expectation

Should be Equatable for tests and metadata preservation checks.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "scene-card-1",
  "sceneID": "scene-1",
  "heading": "INT. COFFEE SHOP - DAY",
  "location": "COFFEE SHOP",
  "timeOfDay": "DAY",
  "characters": ["ELENA"],
  "notes": ["note-1"],
  "plotlineTags": ["audition"],
  "status": "drafted",
  "summary": "Elena avoids a call from her sister.",
  "userMetadata": {
    "color": "blue"
  },
  "derivedMetadata": {
    "screenplayOrder": 1
  }
}
```

## Migration and Versioning Notes

Future status values require migration defaults. User metadata should be namespaced if extended by future routines or plugins.

## Platform Neutrality Concerns

No attributed strings, UI colors, AppKit selection ranges, or SwiftUI view state as canonical data.
