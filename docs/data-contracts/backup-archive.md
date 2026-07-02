# BackupArchive Data Contract

Status: specified
Milestone: 9

## Purpose

`BackupArchive` describes a restorable project backup artifact.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Backup ID. |
| `formatVersion` | String | Yes | Backup schema version. |
| `projectID` | String | Yes | Source project. |
| `projectTitle` | String | Yes | Display name. |
| `packageSchemaVersion` | String | Yes | `.dreamjotter` schema version. |
| `createdAt` | String | Yes | ISO-8601 timestamp. |
| `containsScreenplay` | Boolean | Yes | Must be true for restorable backups. |
| `containsCharacters` | Boolean | Yes | M8 metadata. |
| `containsLocations` | Boolean | Yes | M8 metadata. |
| `containsNotes` | Boolean | Yes | M8 metadata. |
| `containsSceneMetadata` | Boolean | Yes | M8 metadata. |
| `containsRoutines` | Boolean | Yes | If supported by package. |
| `payloadPath` | String | Yes | Path inside artifact or package root. |

## Validation Rules

- Restorable backup must contain project and screenplay data.
- Backup must not depend on SwiftData.
- Schema version must be readable before restore.

## Codable Expectation

Should be Codable as backup manifest metadata.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "backup-001",
  "formatVersion": "1.0",
  "projectID": "project-123",
  "projectTitle": "The Audition",
  "packageSchemaVersion": "1.0",
  "createdAt": "2026-07-01T12:00:00Z",
  "containsScreenplay": true,
  "containsCharacters": true,
  "containsLocations": true,
  "containsNotes": true,
  "containsSceneMetadata": true,
  "containsRoutines": true,
  "payloadPath": "payload/"
}
```

## Migration and Versioning Notes

Restore should reject unsupported backup versions with a friendly error.

## Platform Neutrality Concerns

Backup payload must be readable without Apple frameworks.

## Privacy/Internal Metadata Concerns

Backups may include private notes and internal IDs; UI must label them as private project archives.
