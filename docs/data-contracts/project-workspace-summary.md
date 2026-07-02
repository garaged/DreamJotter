# ProjectWorkspaceSummary Data Contract

Status: specified
Milestone: 8

## Purpose

`ProjectWorkspaceSummary` provides dashboard-ready counts and status derived from canonical project data and rebuildable analysis.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `projectTitle` | String | Yes | Current project title. |
| `logline` | String? | No | Current logline. |
| `synopsis` | String? | No | Current synopsis. |
| `sceneCount` | Int | Yes | Derived from screenplay parse. |
| `characterProfileCount` | Int | Yes | Active or total profile count according to UI filter. |
| `unresolvedDetectedCharacterCount` | Int | Yes | Derived cleanup count. |
| `locationProfileCount` | Int | Yes | Active or total profile count according to UI filter. |
| `unresolvedDetectedLocationCount` | Int | Yes | Derived cleanup count. |
| `openNotesCount` | Int | Yes | Manual open notes count. |
| `todoCount` | Int | Yes | Parsed TODO count. |
| `isDirty` | Boolean | Yes | Current document dirty state. |
| `lastSavedAt` | String? | No | ISO-8601 timestamp when known. |

## Validation Rules

- Counts must be zero or positive.
- Missing optional text fields must not block summary creation.
- `lastSavedAt` is absent for unsaved projects.

## Codable Expectation

May be Codable for testing and diagnostics, but dashboard summary is rebuildable and should not be canonical storage.

## Equatable Expectation

Should be Equatable for executable specs.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "projectTitle": "The Audition",
  "logline": "A pianist risks the truth to win one final audition.",
  "synopsis": "Elena prepares for a concert while avoiding her sister.",
  "sceneCount": 8,
  "characterProfileCount": 3,
  "unresolvedDetectedCharacterCount": 1,
  "locationProfileCount": 2,
  "unresolvedDetectedLocationCount": 1,
  "openNotesCount": 4,
  "todoCount": 2,
  "isDirty": true,
  "lastSavedAt": "2026-07-01T10:25:00Z"
}
```

## Migration and Versioning Notes

Future dashboard sections should add optional counts. Summary records should always be rebuildable from canonical project data.

## Platform Neutrality Concerns

No SwiftUI view state, SwiftData cache dependency, or platform-specific date type in serialized examples.
