# ExportRequest Data Contract

Status: specified
Milestone: 9

## Purpose

`ExportRequest` captures a single export operation without mutating the project.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable request ID. |
| `projectID` | String | Yes | Source project. |
| `presetID` | String | Yes | Selected preset. |
| `format` | String | Yes | Fountain, plainText, markdown, jsonBackup, pdf. |
| `destinationPath` | String | Yes | User-selected output path. |
| `includeNotes` | Boolean | Yes | Effective inclusion after preset validation. |
| `includeMetadata` | Boolean | Yes | Effective metadata inclusion. |
| `createdAt` | String | Yes | ISO-8601 timestamp. |

## Validation Rules

- Format must be supported by preset.
- Destination path must be present.
- Reader-facing presets must not force internal metadata.

## Codable Expectation

Should be Codable for logs/tests, but not canonical project data.

## Equatable Expectation

Should be Equatable for executable specs.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "export-001",
  "projectID": "project-123",
  "presetID": "contest-submission",
  "format": "pdf",
  "destinationPath": "/Users/writer/Desktop/script.pdf",
  "includeNotes": false,
  "includeMetadata": false,
  "createdAt": "2026-07-01T12:00:00Z"
}
```

## Migration and Versioning Notes

Requests are transient and should not require migration.

## Platform Neutrality Concerns

Paths must be serialized as strings and interpreted by platform adapters.

## Privacy/Internal Metadata Concerns

Effective metadata flags should be visible before export.
