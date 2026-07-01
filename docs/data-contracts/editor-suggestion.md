# Editor Suggestion Data Contract

Status: specified
Milestone: M7
Registry IDs: EDITOR-SCENE-HEADING-SUGGESTIONS, EDITOR-CHARACTER-AUTOCOMPLETE, EDITOR-LOCATION-AUTOCOMPLETE, EDITOR-ELEMENT-KIND-CYCLING

## Purpose

`EditorSuggestion` represents a non-destructive editor suggestion that may be shown and optionally accepted by the user.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | string | yes | Stable suggestion ID for the current suggestion batch. |
| `type` | enum string | yes | `character`, `location`, `sceneHeading`, `timeOfDay`, or `elementKind`. |
| `displayText` | string | yes | Text shown to the user. |
| `replacementText` | string | yes | Text inserted if accepted. |
| `textRange` | object | yes | Range to replace if accepted. |
| `priority` | number | no | Deterministic ranking or confidence value. |
| `source` | enum string | yes | `projectCharacters`, `parsedLocations`, `screenplaySyntax`, or `recentUsage`. |

## Invariants

- Suggestions do not mutate text until accepted.
- Ignored suggestions leave text unchanged.
- Replacement text preserves canonical spelling and Unicode.
- Suggestions are adapter-neutral and can be shown by TextKit or fallback UI.

## Example

```json
{
  "id": "suggestion-character-elena",
  "type": "character",
  "displayText": "ELENA",
  "replacementText": "ELENA",
  "textRange": { "location": 42, "length": 3 },
  "priority": 0.95,
  "source": "projectCharacters"
}
```
