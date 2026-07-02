# ScriptHealthReport Data Contract

Status: specified
Milestone: 9

## Purpose

`ScriptHealthReport` summarizes screenplay and project health signals.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Report ID. |
| `projectID` | String | Yes | Source project. |
| `generatedAt` | String | Yes | ISO-8601 timestamp. |
| `sceneCount` | Int | Yes | Derived from screenplay. |
| `elementCount` | Int | Yes | Derived from screenplay. |
| `characterProfileCount` | Int | Yes | Project profiles. |
| `unresolvedCharacterCount` | Int | Yes | Detected unresolved characters. |
| `locationProfileCount` | Int | Yes | Project profiles. |
| `unresolvedLocationCount` | Int | Yes | Detected unresolved locations. |
| `openNotesCount` | Int | Yes | Manual open notes. |
| `todoCount` | Int | Yes | Parsed TODOs. |
| `dialogueActionRatio` | Number? | No | Omitted if denominator is zero. |
| `longestSceneIDs` | [String] | Yes | Scene IDs or headings. |
| `scenesWithoutDialogue` | [String] | Yes | Scene IDs or headings. |
| `findings` | [ReviewFinding] | Yes | Structured findings. |
| `lastSavedAt` | String? | No | From document state if known. |

## Validation Rules

- Counts must be zero or positive.
- Running report must not mutate project data.
- Missing optional saved status must not fail report generation.

## Codable Expectation

Should be Codable for diagnostics and future report export.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "health-001",
  "projectID": "project-123",
  "generatedAt": "2026-07-01T12:00:00Z",
  "sceneCount": 12,
  "elementCount": 140,
  "characterProfileCount": 4,
  "unresolvedCharacterCount": 1,
  "locationProfileCount": 3,
  "unresolvedLocationCount": 2,
  "openNotesCount": 5,
  "todoCount": 2,
  "dialogueActionRatio": 0.65,
  "longestSceneIDs": ["scene-8"],
  "scenesWithoutDialogue": ["scene-3"],
  "findings": [],
  "lastSavedAt": "2026-07-01T11:55:00Z"
}
```

## Migration and Versioning Notes

Future metrics should be optional and rebuildable.

## Platform Neutrality Concerns

No UI colors, views, or platform-specific ranges.

## Privacy/Internal Metadata Concerns

Reports remain local unless explicitly exported.
