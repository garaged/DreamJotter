# ReviewFinding Data Contract

Status: specified
Milestone: 9

## Purpose

`ReviewFinding` represents one structured review, health, formatting, TODO, unresolved-object, or storage finding.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable finding ID for a report run. |
| `severity` | String | Yes | info, warning, issue. |
| `title` | String | Yes | Short label. |
| `message` | String | Yes | Friendly explanation. |
| `source` | String | Yes | healthReport, formatting, unresolvedCharacter, unresolvedLocation, todo, storage. |
| `linkedEntityType` | String? | No | scene, character, location, note, scriptElement. |
| `linkedEntityID` | String? | No | Entity ID or heading if no stable ID exists. |
| `scriptRange` | Object? | No | Location/length if known. |
| `suggestedAction` | String? | No | Friendly next step. |
| `generatedAt` | String | Yes | ISO-8601 timestamp. |

## Validation Rules

- Severity and source must be known values.
- Linked entity ID requires linked entity type.
- Findings must not mutate project data.

## Codable Expectation

Should be Codable for report export and tests.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "finding-unresolved-character-sofia",
  "severity": "warning",
  "title": "Unresolved character",
  "message": "SOFIA appears in the script but has no character profile.",
  "source": "unresolvedCharacter",
  "linkedEntityType": "character",
  "linkedEntityID": "SOFIA",
  "scriptRange": null,
  "suggestedAction": "Convert SOFIA to a character profile.",
  "generatedAt": "2026-07-01T12:00:00Z"
}
```

## Migration and Versioning Notes

Future findings may add dismiss state as separate project metadata.

## Platform Neutrality Concerns

Script ranges should use portable integer offsets, not AppKit selection types.

## Privacy/Internal Metadata Concerns

Findings may reference internal metadata and should be excluded from reader-facing exports by default.
