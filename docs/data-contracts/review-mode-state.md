# ReviewModeState Data Contract

Status: specified
Milestone: 9

## Purpose

`ReviewModeState` describes the read-only review workspace selection/filter/navigation state.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `isReviewModeActive` | Boolean | Yes | Whether review mode is active. |
| `selectedFindingID` | String? | No | Current finding. |
| `selectedSceneID` | String? | No | Current scene selection. |
| `visibleSeverities` | [String] | Yes | info, warning, issue filters. |
| `visibleSources` | [String] | Yes | Finding source filters. |
| `scriptPreviewIsReadOnly` | Boolean | Yes | Must be true in Review Mode. |
| `pendingNavigationTarget` | Object? | No | Scene or script-range target. |
| `lastGeneratedReportID` | String? | No | Current report reference. |

## Validation Rules

- Review mode preview must be read-only.
- Navigation target must not mutate project data.
- Missing finding/scene targets should be handled gracefully.

## Codable Expectation

May be Codable as app/session metadata, not canonical project storage.

## Equatable Expectation

Should be Equatable for view-model tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "isReviewModeActive": true,
  "selectedFindingID": "finding-001",
  "selectedSceneID": "scene-2",
  "visibleSeverities": ["warning", "issue"],
  "visibleSources": ["formatting", "todo"],
  "scriptPreviewIsReadOnly": true,
  "pendingNavigationTarget": {
    "type": "scene",
    "id": "scene-2"
  },
  "lastGeneratedReportID": "health-001"
}
```

## Migration and Versioning Notes

State is rebuildable and can be dropped safely.

## Platform Neutrality Concerns

Do not store SwiftUI selection, AppKit ranges, or view references.

## Privacy/Internal Metadata Concerns

Review state may reveal finding IDs but not screenplay text.
