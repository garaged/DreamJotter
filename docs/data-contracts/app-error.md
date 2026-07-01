# App Error Data Contract

Status: specified
Milestone: M6
Registry ID: APP-ERROR-HANDLING

## Purpose

`AppError` is the app-facing error record used to present document lifecycle failures in human-readable language while preserving optional technical detail for diagnostics.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | string | yes | Stable unique error ID. |
| `category` | enum string | yes | Error category. |
| `userMessage` | string | yes | Primary message shown to non-programmer users. |
| `technicalDetail` | string | no | Optional lower-level detail for logs or diagnostics. |
| `recoverySuggestion` | string | no | Suggested next action, if known. |
| `sourceOperation` | enum string | yes | `open`, `save`, `saveAs`, `export`, `recentProjectOpen`, `close`, or `unknown`. |
| `timestamp` | ISO-8601 string | yes | Time the error was created. |

## Categories

- `openFailed`
- `saveFailed`
- `saveAsCanceled`
- `saveAsFailed`
- `exportFailed`
- `invalidPackage`
- `unsupportedPackageVersion`
- `missingProjectFile`
- `permissionDenied`
- `unknown`

## Invariants

- `userMessage` must be safe to show directly in the UI.
- Raw stack traces must not be the primary `userMessage`.
- Unknown errors map to `category: "unknown"` with a generic message.
- Error presentation must not mutate or corrupt the current project state.

## Example

```json
{
  "id": "error-2026-07-01T18:10:00Z",
  "category": "invalidPackage",
  "userMessage": "DreamJotter could not open this project package.",
  "technicalDetail": "manifest.json was missing",
  "recoverySuggestion": "Choose another .dreamjotter package or restore this project from a backup.",
  "sourceOperation": "open",
  "timestamp": "2026-07-01T18:10:00Z"
}
```
