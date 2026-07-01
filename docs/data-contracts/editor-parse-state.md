# Editor Parse State Data Contract

Status: specified
Milestone: M7
Registry ID: EDITOR-DEBOUNCED-PARSING

## Purpose

`EditorParseState` tracks controlled screenplay parsing for editor responsiveness and downstream derived data updates.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `currentTextRevision` | integer | yes | Monotonic revision incremented on text edits. |
| `lastParsedTextRevision` | integer | no | Last text revision successfully parsed. |
| `isParsing` | boolean | yes | True while a parse refresh is in progress. |
| `lastParseDate` | ISO-8601 string | no | Last completed parse time. |
| `parseWarnings` | array | yes | Nonfatal parse warnings. |
| `parseErrors` | array | yes | Fatal or blocking parse errors if any. |
| `sceneCount` | integer | yes | Scene count from the last parse result. |
| `elementCount` | integer | yes | Element count from the last parse result. |

## Invariants

- `currentTextRevision` must be greater than or equal to `lastParsedTextRevision`.
- Save may force parse catch-up before writing package data.
- Parse errors must not make the editor unusable.
- Parse state is derived and not canonical storage.

## Example

```json
{
  "currentTextRevision": 8,
  "lastParsedTextRevision": 7,
  "isParsing": false,
  "lastParseDate": "2026-07-01T18:30:00Z",
  "parseWarnings": ["Ambiguous uppercase action line"],
  "parseErrors": [],
  "sceneCount": 3,
  "elementCount": 28
}
```
