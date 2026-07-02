# ExportFeedback Data Contract

Status: specified
Milestone: 9.5

## Purpose

`ExportFeedback` captures user-facing export, backup, and restore outcomes.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable feedback ID for UI state. |
| `kind` | String | Yes | success, warning, error, canceled. |
| `userMessage` | String | Yes | Primary friendly message. |
| `technicalDetail` | String? | No | Optional diagnostic detail for logs or disclosure. |
| `outputPath` | String? | No | Exported file path when available. |
| `canRevealInFinder` | Boolean | Yes | True when macOS can reveal output path. |
| `sourceOperation` | String | Yes | export, backup, restore, destinationSelection. |
| `timestamp` | String | Yes | ISO-8601 timestamp. |

## Validation Rules

- `userMessage` must not be blank.
- `canRevealInFinder` requires a nonblank `outputPath`.
- Canceled feedback should not be treated as an error.
- Technical detail must not replace the primary user message.

## Codable Expectation

Should be Codable for app-support tests and logging.

## Equatable Expectation

Should be Equatable for view-model tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "feedback-001",
  "kind": "success",
  "userMessage": "Export complete.",
  "technicalDetail": null,
  "outputPath": "/Users/writer/Desktop/My Script.pdf",
  "canRevealInFinder": true,
  "sourceOperation": "export",
  "timestamp": "2026-07-01T12:00:00Z"
}
```

## Migration and Versioning Notes

Feedback is transient app state and should not require project migration.

## Platform Neutrality Concerns

Finder reveal is represented as capability state so other platforms can map it to local equivalents.

## Privacy/Internal Metadata Concerns

Feedback must avoid displaying raw stack traces as primary UI text.
