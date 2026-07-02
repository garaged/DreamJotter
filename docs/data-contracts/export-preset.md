# ExportPreset Data Contract

Status: specified
Milestone: 9

## Purpose

`ExportPreset` describes a user-facing export goal and its safe defaults.

## Fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | String | Yes | Stable preset ID. |
| `displayName` | String | Yes | User-facing name. |
| `goal` | String | Yes | Plain-language purpose. |
| `allowedFormats` | [String] | Yes | Fountain, plainText, markdown, jsonBackup, pdf. |
| `defaultFormat` | String | Yes | Must be in allowed formats. |
| `includesNotes` | Boolean | Yes | Whether manual notes are included. |
| `includesSceneMetadata` | Boolean | Yes | Whether scene card metadata is included. |
| `includesCharacterLocationMetadata` | Boolean | Yes | Whether profiles are included. |
| `includesUnresolvedDetectedItems` | Boolean | Yes | Whether unresolved detections are included. |
| `includesInternalIDs` | Boolean | Yes | Whether stable internal IDs are included. |
| `includesAppVersion` | Boolean | Yes | Whether app/package version is included. |
| `filenameSuggestion` | String | Yes | Suggested filename stem. |
| `privacyWarning` | String? | No | Required when internal metadata may be included. |

## Validation Rules

- `defaultFormat` must be listed in `allowedFormats`.
- Reader-facing presets must default all internal metadata flags to false.
- Backup presets should include app/package version.

## Codable Expectation

Should be Codable for built-in catalog fixtures and future custom presets.

## Equatable Expectation

Should be Equatable for tests.

## Sendable Expectation

Should be Sendable where practical.

## JSON Example

```json
{
  "id": "reader-copy",
  "displayName": "Reader Copy",
  "goal": "Share a clean script with a reader.",
  "allowedFormats": ["fountain", "pdf", "markdown"],
  "defaultFormat": "pdf",
  "includesNotes": false,
  "includesSceneMetadata": false,
  "includesCharacterLocationMetadata": false,
  "includesUnresolvedDetectedItems": false,
  "includesInternalIDs": false,
  "includesAppVersion": false,
  "filenameSuggestion": "The Audition Reader Copy",
  "privacyWarning": null
}
```

## Migration and Versioning Notes

Future custom presets should carry a schema version.

## Platform Neutrality Concerns

Preset metadata must not depend on SwiftUI, AppKit, PDFKit, or SwiftData.

## Privacy/Internal Metadata Concerns

Presets that include notes, internal IDs, or unresolved detections must show a warning before export.
