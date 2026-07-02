# ExportResult Data Contract

Status: specified
Milestone: 9

## Purpose

`ExportResult` reports export success, failure, and produced artifact metadata.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Result ID. |
| `requestID` | String | Yes | Source request. |
| `status` | String | Yes | success, failed, canceled. |
| `artifactPath` | String? | No | Present on success. |
| `format` | String | Yes | Export format. |
| `userMessage` | String | Yes | Friendly status or error. |
| `technicalDetail` | String? | No | Diagnostics. |
| `generatedAt` | String | Yes | ISO-8601 timestamp. |
| `dirtyStateChanged` | Boolean | Yes | Must be false for export. |

## Validation Rules

- Success requires `artifactPath`.
- Export results must report `dirtyStateChanged` as false.
- Failed results must include a friendly `userMessage`.

## Codable Expectation

Should be Codable for diagnostics.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "export-result-001",
  "requestID": "export-001",
  "status": "success",
  "artifactPath": "/Users/writer/Desktop/script.pdf",
  "format": "pdf",
  "userMessage": "Export complete.",
  "technicalDetail": null,
  "generatedAt": "2026-07-01T12:00:03Z",
  "dirtyStateChanged": false
}
```

## Migration and Versioning Notes

Results are transient and should remain backward-readable if stored in logs.

## Platform Neutrality Concerns

No platform-specific URL or error object should be canonical.

## Privacy/Internal Metadata Concerns

Results should not echo sensitive project contents.
