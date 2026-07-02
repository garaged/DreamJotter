# RestoreResult Data Contract

Status: specified
Milestone: 9

## Purpose

`RestoreResult` reports validation and restore outcomes.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Result ID. |
| `backupID` | String? | No | Present if backup manifest was readable. |
| `status` | String | Yes | restored, failed, canceled, confirmationRequired. |
| `restoredProjectID` | String? | No | Present on success. |
| `userMessage` | String | Yes | Friendly result. |
| `technicalDetail` | String? | No | Diagnostics. |
| `requiresDirtyProtection` | Boolean | Yes | True when current project is dirty. |
| `completedAt` | String | Yes | ISO-8601 timestamp. |

## Validation Rules

- Successful restore requires `restoredProjectID`.
- Dirty current projects must not be replaced without explicit confirmation or save-first flow.
- Failed restore preserves current project state.

## Codable Expectation

Should be Codable for diagnostics.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "restore-result-001",
  "backupID": "backup-001",
  "status": "confirmationRequired",
  "restoredProjectID": null,
  "userMessage": "Save or discard current changes before restoring this backup.",
  "technicalDetail": null,
  "requiresDirtyProtection": true,
  "completedAt": "2026-07-01T12:04:00Z"
}
```

## Migration and Versioning Notes

Future restore modes may add conflict details.

## Platform Neutrality Concerns

No platform-specific alert or error objects.

## Privacy/Internal Metadata Concerns

Restore errors should not expose private screenplay text.
