# ExportUIState Data Contract

Status: specified
Milestone: 9.5

## Purpose

`ExportUIState` represents the visible export picker state without becoming canonical project storage.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `selectedPresetID` | String | Yes | Current export preset ID. |
| `selectedFormat` | String | Yes | Current format: fountain, pdf, markdown, plainText, jsonBackup. |
| `availableFormats` | Array<String> | Yes | Formats compatible with selected preset. |
| `disabledFormats` | Array<DisabledExportFormat> | Yes | Unsupported formats and user-facing reasons. |
| `destinationPath` | String? | No | Chosen output path. |
| `isExporting` | Boolean | Yes | True while export is running. |
| `lastSuccessFeedbackID` | String? | No | Last success feedback reference. |
| `lastErrorFeedbackID` | String? | No | Last error feedback reference. |
| `lastFeedback` | ExportFeedback? | No | Most recent feedback if retained in state. |
| `sourceContext` | String | Yes | workspace, reviewMode, backup. |
| `isCanceled` | Boolean | Yes | True when the last operation was canceled. |

### DisabledExportFormat

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `format` | String | Yes | Disabled format. |
| `reason` | String | Yes | Friendly explanation. |

## Validation Rules

- Selected format must be available for selected preset or have a disabled reason.
- Destination path may be nil before export and after cancel.
- `sourceContext` must be one of workspace, reviewMode, or backup.
- `isExporting` must be false after success, error, or cancel feedback.

## Codable Expectation

Should be Codable for app-support tests and possible app-state restoration.

## Equatable Expectation

Should be Equatable for view-model tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "selectedPresetID": "reader-copy",
  "selectedFormat": "pdf",
  "availableFormats": ["fountain", "pdf", "markdown"],
  "disabledFormats": [
    {
      "format": "jsonBackup",
      "reason": "Use Writer Backup when you want a restorable project backup."
    }
  ],
  "destinationPath": "/Users/writer/Desktop/My Script.pdf",
  "isExporting": false,
  "lastSuccessFeedbackID": "feedback-001",
  "lastErrorFeedbackID": null,
  "lastFeedback": null,
  "sourceContext": "workspace",
  "isCanceled": false
}
```

## Migration and Versioning Notes

This is app UI state and should not require project migration.

## Platform Neutrality Concerns

Paths are strings. Platform adapters interpret and display them.

## Privacy/Internal Metadata Concerns

State should expose disabled reasons and privacy warnings without leaking internal project data into reader-facing exports.
