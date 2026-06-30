# Serialization Rules

## Purpose

This contract defines serialization rules for portable DreamJotter core data. These rules apply to `.dreamjotter` canonical project content and future executable specs.

## File Format Direction

Canonical project data must be serializable as JSON-compatible UTF-8 data inside a `.dreamjotter` package. The final package layout may split data across multiple files, but each file must follow these serialization rules unless a later contract explicitly extends them.

## Encoding Rules

- Use UTF-8.
- Preserve Unicode text exactly where practical.
- Do not use ASCII-only normalization for canonical text.
- Use ISO-8601 strings for dates, for example `2026-06-30T18:25:43Z`.
- Use string IDs, not memory addresses or database object IDs.
- Use explicit enum strings.
- Use arrays for ordered data.
- Use objects for keyed records.
- Avoid implicit ordering in dictionaries.
- Omit optional fields only when absence has a documented default.
- Unknown compatible fields should be preserved where practical.

## Forbidden Canonical Dependencies

Canonical serialized data must not require:

- SwiftUI.
- AppKit.
- UIKit.
- TextKit.
- SwiftData.
- CloudKit.
- Core Data object IDs.
- `NSAttributedString` archives.
- `AttributedString` archives.
- Platform color objects.
- Platform URL bookmark blobs as core IDs.

## ID Rules

IDs are portable strings. Recommended prefix examples:

| Model | Prefix Example |
| --- | --- |
| Project | `project-` |
| Screenplay | `screenplay-` |
| ScriptElement | `element-` |
| Scene | `scene-` |
| Character | `character-` |
| Location | `location-` |
| Note | `note-` |
| Tag | `tag-` |
| DraftVersion | `draft-` |
| Snapshot | `snapshot-` |
| ProductionBreakdown | `breakdown-` |
| CustomFieldDefinition | `field-` |
| CustomFieldValue | `field-value-` |
| Routine | `routine-` |
| CommandHistoryEntry | `command-history-` |

ID generation strategy is unresolved, but generated IDs must be stable after save/load and portable across platforms.

## Date Rules

Dates serialize as ISO-8601 strings with timezone:

```json
{
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:30:00Z"
}
```

Readers should reject invalid dates with diagnostics rather than inventing timestamps, except where a migration explicitly repairs legacy data.

## Enum Rules

Enums serialize as lower camel case strings unless an existing public term requires another spelling. Examples:

```json
{
  "kind": "sceneHeading",
  "fieldType": "singleSelect",
  "trigger": { "kind": "beforeExport" }
}
```

Unknown enum values must not crash readers. Unknown values should be preserved when possible and produce diagnostics.

## Text Rules

Canonical text is plain Unicode string data. Semantic meaning is stored through model fields, not through text styling.

Spanish/Unicode example:

```json
{
  "id": "element-001",
  "kind": "dialogue",
  "text": "¿Dónde está José? La niña volvió al Zócalo.",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:25:43Z"
}
```

## JSON Value Rule

Where a field needs flexible values, use a constrained `JSONValue` concept with these allowed serialized forms:

- string
- number
- boolean
- null
- array of JSONValue
- object with string keys and JSONValue values

Do not use arbitrary Swift `Any` as an implementation shortcut without a typed wrapper.

## Ordering Rules

- `Screenplay.elements` order is canonical screenplay order.
- Routine action order is execution order.
- Tags, notes, and metadata arrays may be displayed in stored order unless a later sort rule applies.
- Dictionary order is never meaningful.

## Missing Data Rules

- Missing required fields are validation errors.
- Missing optional fields use documented defaults.
- Missing referenced records produce diagnostics and preserve referring records where possible.
- Invalid package sections must not cause silent data invention.

## Migration Rules

Every canonical file or root record must include schema version context directly or through package manifest. Migrations must:

- Preserve user text.
- Preserve portable IDs where possible.
- Record diagnostics for repaired or skipped data.
- Avoid deleting unknown future data unless a user-approved repair operation requires it.
- Never migrate canonical data into SwiftData as the source of truth.

## Codable Expectation

Future Swift implementations should use `Codable` or a similarly explicit serialization layer. Custom decoding is expected for unknown enum preservation, schema migration, and diagnostics.

## Equatable Expectation

Core data models should be `Equatable` where practical to support executable specs, parser tests, import/export tests, snapshot tests, and semantic comparison.

## Sendable Expectation

Core data models should be `Sendable` where practical by using immutable value types and avoiding framework object references.

## Platform Neutrality

Serialized data must be understandable on macOS, iPadOS, iOS, and future Linux, Windows, and Android implementations. Apple-specific conveniences may cache derived data outside canonical storage, but canonical `.dreamjotter` content must remain portable.
