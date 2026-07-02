# DetectedCharacter Data Contract

Status: specified
Milestone: 8

## Purpose

`DetectedCharacter` represents a rebuildable character cue found in screenplay text and its resolution state against user-authored character profiles.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable enough for current parse revision; may be derived from normalized name and first occurrence. |
| `name` | String | Yes | Display text from script cue. |
| `normalizedName` | String | Yes | Matching key for duplicate collapse and profile lookup. |
| `firstElementID` | String? | No | Parsed screenplay element where first detected. |
| `occurrenceCount` | Int | Yes | Number of cue appearances in current parse. |
| `isGenericRole` | Boolean | Yes | True for names such as `MAN`, `COP`, or `VOICE`. |
| `resolutionStatus` | String | Yes | `unresolved`, `converted`, `ignored`, or `matchedProfile`. |
| `matchedCharacterID` | String? | No | Present when matched or converted. |

## Validation Rules

- `name` and `normalizedName` must be non-empty.
- `occurrenceCount` must be at least 1.
- `matchedCharacterID` is required when `resolutionStatus` is `matchedProfile` or `converted`.
- Ignored detections must not appear as unresolved.

## Codable Expectation

Can be Codable for caches or diagnostics, but rebuildable detected records are not required as canonical package data.

## Equatable Expectation

Should be Equatable for executable specs.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "detected-character-sofia",
  "name": "SOFIA",
  "normalizedName": "SOFIA",
  "firstElementID": "element-42",
  "occurrenceCount": 3,
  "isGenericRole": false,
  "resolutionStatus": "unresolved",
  "matchedCharacterID": null
}
```

## Migration and Versioning Notes

Resolution status may become a typed enum in code. Detection IDs may change if the identity strategy changes; user-authored ignore metadata should key by normalized name or explicit stable policy.

## Platform Neutrality Concerns

Derived from portable screenplay parse data only; no Apple framework types.
