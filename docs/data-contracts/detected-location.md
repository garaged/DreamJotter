# DetectedLocation Data Contract

Status: specified
Milestone: 8

## Purpose

`DetectedLocation` represents a rebuildable location found in screenplay scene headings and its resolution state against location profiles.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable enough for current parse revision; may derive from normalized location. |
| `name` | String | Yes | Location display text from scene heading. |
| `normalizedName` | String | Yes | Matching key for duplicate collapse. |
| `firstSceneID` | String? | No | Parsed scene where first detected. |
| `sceneCount` | Int | Yes | Number of scenes using this location. |
| `resolutionStatus` | String | Yes | `unresolved`, `converted`, `ignored`, or `matchedProfile`. |
| `matchedLocationID` | String? | No | Present when matched or converted. |

## Validation Rules

- `name` and `normalizedName` must be non-empty.
- `sceneCount` must be at least 1.
- Time-of-day values must not be stored as detected locations.
- `matchedLocationID` is required when `resolutionStatus` is `matchedProfile` or `converted`.

## Codable Expectation

Can be Codable for caches or diagnostics. Rebuildable detections are not required as canonical package data.

## Equatable Expectation

Should be Equatable for executable specs.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "detected-location-coffee-shop",
  "name": "COFFEE SHOP",
  "normalizedName": "COFFEE SHOP",
  "firstSceneID": "scene-1",
  "sceneCount": 2,
  "resolutionStatus": "unresolved",
  "matchedLocationID": null
}
```

## Migration and Versioning Notes

Detection identity may evolve when scene identity becomes stronger. Ignore metadata should not rely on transient parse IDs alone.

## Platform Neutrality Concerns

Derived from portable screenplay parse data only.
