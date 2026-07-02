# ProjectNote Data Contract

Status: specified
Milestone: 8

## Purpose

`ProjectNote` stores manual project notes and represents derived script TODO notes in a common workflow.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable identifier for manual notes; derived TODO IDs may be parse-derived. |
| `text` | String | Yes | User-visible note text. |
| `status` | String | Yes | `open`, `resolved`, or `archived`. |
| `linkedEntityType` | String | Yes | `project`, `scene`, `character`, `location`, or `scriptElement`. |
| `linkedEntityID` | String? | No | Required for non-project links when known. |
| `source` | String | Yes | `manual`, `parsedScriptTodo`, `imported`, or `routine`. |
| `createdAt` | String | Yes | ISO-8601 timestamp for manual notes; derived notes may use parse time or source timestamp. |
| `updatedAt` | String | Yes | ISO-8601 timestamp. |

## Validation Rules

- `text` must be non-empty after trimming for manual notes.
- `status` must be one of the allowed values.
- `source` must be one of the allowed values.
- Missing linked entities must be represented safely without deleting note content.

## Codable Expectation

Manual notes must be Codable. Derived TODO notes may be Codable when cached, but are rebuildable from screenplay text.

## Equatable Expectation

Should be Equatable for tests and dirty-state comparisons.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "note-1",
  "text": "Rewrite this scene after Elena's reveal.",
  "status": "open",
  "linkedEntityType": "scene",
  "linkedEntityID": "scene-1",
  "source": "manual",
  "createdAt": "2026-07-01T10:00:00Z",
  "updatedAt": "2026-07-01T10:00:00Z"
}
```

## Migration and Versioning Notes

Future tags, priorities, and owners should be optional additions. Derived TODO behavior should remain distinguishable from manual notes.

## Platform Neutrality Concerns

No UI selection, attributed text, SwiftData object IDs, or CloudKit identifiers.
