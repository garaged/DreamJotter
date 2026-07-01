# Core Domain Model Data Contract

## Purpose

This contract defines the canonical portable core models for DreamJotter before implementation. These models describe screenplay and project data that must be serializable into a local-first `.dreamjotter` package and usable without Apple UI frameworks or SwiftData.

## Global Rules

- Do not store screenplay only as attributed text.
- Do not require SwiftUI, AppKit, UIKit, TextKit, SwiftData, or CloudKit types.
- Do not require SwiftData annotations.
- Use portable string IDs.
- Serialized dates use ISO-8601 strings with timezone, such as `2026-06-30T18:25:43Z`.
- Text must preserve Unicode, including Spanish punctuation and accents.
- All models are expected to be `Codable` unless explicitly marked derived-only.
- All value models are expected to be `Equatable` where practical.
- Models should be `Sendable` where practical by using value types and avoiding framework references.

## Shared Scalar Types

| Alias | Serialized Type | Notes |
| --- | --- | --- |
| `PortableID` | string | Stable unique ID, recommended prefix by model, e.g. `project-...`. |
| `ISO8601Date` | string | UTC or offset-aware ISO-8601 timestamp. |
| `LocalizedText` | string | UTF-8 string, no ASCII-only assumptions. |
| `VersionString` | string | Semantic or monotonic schema version, e.g. `1.0.0`. |
| `URIString` | string | Relative package path or portable URI string; not platform URL type. |

## Project

Purpose: Root canonical project record for a `.dreamjotter` package.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable project ID. |
| `schemaVersion` | `VersionString` | Yes | Project schema version. |
| `title` | `LocalizedText` | Yes | User-visible title. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `updatedAt` | `ISO8601Date` | Yes | Last canonical project update. |
| `primaryScreenplayId` | `PortableID` | Yes | References `Screenplay.id`. |
| `screenplays` | `[Screenplay]` | Yes | At least primary screenplay. |
| `characters` | `[Character]` | No | Empty array if none. |
| `locations` | `[Location]` | No | Empty array if none. |
| `notes` | `[Note]` | No | Project notes. |
| `tags` | `[Tag]` | No | Shared tags. |
| `draftVersions` | `[DraftVersion]` | No | Draft metadata. |
| `snapshots` | `[Snapshot]` | No | Snapshot metadata. |
| `storySetup` | `StorySetup` | No | Guided setup fields for title intent, protagonist, goal, obstacle, audience, and notes. |
| `logline` | `Logline` | No | Manual or accepted-suggestion logline record. |
| `synopsis` | `Synopsis` | No | Manual or accepted-suggestion synopsis record. |
| `beatSheets` | `[BeatSheet]` | No | Optional story-planning beats linked to scenes where available. |
| `aiSuggestions` | `[AISuggestion]` | No | Suggestion lifecycle records; pending/rejected suggestions do not mutate screenplay text. |
| `productionBreakdown` | `[ProductionBreakdown]` | No | Optional Pro data. |
| `customFieldDefinitions` | `[CustomFieldDefinition]` | No | Optional Pro schema. |
| `customFieldValues` | `[CustomFieldValue]` | No | Optional Pro values. |
| `routines` | `[Routine]` | No | Optional Pro routines. |
| `commandHistory` | `[CommandHistoryEntry]` | No | Optional command audit/history. |

Validation rules:

- `id`, `schemaVersion`, `title`, `createdAt`, `updatedAt`, and `primaryScreenplayId` must be present.
- `primaryScreenplayId` must reference an existing screenplay.
- `updatedAt` must not be earlier than `createdAt`.
- Unknown future sections must not make the project unreadable if required core fields are valid.

Codable expectation: Required.

Equatable expectation: Required for value comparison and tests.

Sendable expectation: Practical if implemented as immutable/value data.

JSON example:

```json
{
  "id": "project-001",
  "schemaVersion": "1.0.0",
  "title": "La Noche Larga",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:30:00Z",
  "primaryScreenplayId": "screenplay-001",
  "screenplays": [],
  "characters": [],
  "locations": [],
  "notes": [],
  "tags": [],
  "draftVersions": [],
  "snapshots": [],
  "storySetup": null,
  "logline": null,
  "synopsis": null,
  "beatSheets": [],
  "aiSuggestions": [],
  "productionBreakdown": [],
  "customFieldDefinitions": [],
  "customFieldValues": [],
  "routines": [],
  "commandHistory": []
}
```

Migration/versioning notes: Project schema migrations must be explicit and preserve unknown compatible data where possible.

Platform neutrality concerns: No platform bookmark, URL, SwiftData object ID, or UI color type belongs in this root model.

## Screenplay

Purpose: Semantic screenplay document within a project.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable screenplay ID. |
| `title` | `LocalizedText` | Yes | Screenplay title. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `updatedAt` | `ISO8601Date` | Yes | Last screenplay update. |
| `elements` | `[ScriptElement]` | Yes | Ordered semantic elements. |
| `metadata` | `[String: String]` | No | Portable string metadata for early versions. |

Validation rules:

- Elements must have unique IDs within the screenplay.
- Element order is array order.
- Empty `elements` is valid for a blank screenplay.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "screenplay-001",
  "title": "La Noche Larga",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:30:00Z",
  "elements": [
    {
      "id": "element-001",
      "kind": "sceneHeading",
      "text": "EXT. ZOCALO - NOCHE",
      "createdAt": "2026-06-30T18:26:00Z",
      "updatedAt": "2026-06-30T18:26:00Z"
    }
  ],
  "metadata": {
    "language": "es-MX"
  }
}
```

Migration/versioning notes: Element arrays should migrate without changing IDs unless a migration explicitly records ID remapping.

Platform neutrality concerns: This is not `NSAttributedString`, `AttributedString`, a TextKit buffer, or a SwiftUI model.

## ScriptElement

Purpose: Atomic ordered semantic screenplay element.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable element ID. |
| `kind` | `ScriptElementKind` | Yes | Semantic type. |
| `text` | `LocalizedText` | Yes | Original user text. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `updatedAt` | `ISO8601Date` | Yes | Last update timestamp. |
| `sceneId` | `PortableID` | No | Owning scene reference if derived/stored. |
| `characterId` | `PortableID` | No | Character reference for dialogue/cue where known. |
| `revisionMetadata` | `RevisionMetadata` | No | Optional Pro revision data. |
| `tags` | `[PortableID]` | No | Tag references. |
| `diagnostics` | `[String]` | No | Portable diagnostic codes or messages. |

Validation rules:

- `text` may be empty only for placeholder kinds explicitly allowed later.
- `kind` must be known or `unknown`.
- References must point to existing records when validation context is available.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "element-002",
  "kind": "dialogue",
  "text": "¿Dónde está José?",
  "createdAt": "2026-06-30T18:27:00Z",
  "updatedAt": "2026-06-30T18:27:00Z",
  "characterId": "character-001",
  "tags": ["tag-urgent"],
  "diagnostics": []
}
```

Migration/versioning notes: New element fields must default safely; unknown kinds should preserve text.

Platform neutrality concerns: Formatting is derived from `kind`; do not store only rich-text styling.

## ScriptElementKind

Purpose: Enumeration of supported screenplay element semantics.

| Case | Serialized Type | Required | Notes |
| --- | --- | --- | --- |
| `titlePage` | string | No | Title page or title metadata element. |
| `sceneHeading` | string | No | Scene heading such as `INT. KITCHEN - DAY`. |
| `action` | string | No | Action/description. |
| `characterCue` | string | No | Character cue before dialogue. |
| `parenthetical` | string | No | Parenthetical direction. |
| `dialogue` | string | No | Dialogue content. |
| `transition` | string | No | Transition such as `CUT TO:` or `CORTE A:`. |
| `section` | string | No | Fountain-style organizational section. |
| `synopsis` | string | No | Synopsis/planning element. |
| `noteReference` | string | No | Reference to note; note body belongs in `Note`. |
| `unknown` | string | No | Preserved unsupported or malformed text. |

Validation rules:

- Unknown serialized values must be preserved or mapped to `unknown` with diagnostics.
- `kind` must not be inferred from styling alone.

Codable expectation: Required as string enum.

Equatable expectation: Required.

Sendable expectation: Required/practical.

JSON example:

```json
"sceneHeading"
```

Migration/versioning notes: Adding cases is non-breaking only if older readers preserve unknown text.

Platform neutrality concerns: Cases must not encode Apple UI or TextKit concepts.

## Scene

Purpose: Scene summary derived from or linked to scene heading elements.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable scene ID. |
| `headingElementId` | `PortableID` | No | Source scene heading element. |
| `title` | `LocalizedText` | Yes | Display heading/title. |
| `summary` | `LocalizedText` | No | Scene card summary. |
| `locationId` | `PortableID` | No | Linked location. |
| `status` | string | No | Portable status value. |
| `tagIds` | `[PortableID]` | No | Tags. |
| `customFieldValueIds` | `[PortableID]` | No | Pro custom values. |

Validation rules:

- `headingElementId`, if present, must reference a scene heading element.
- Scene records without heading are allowed for planned scenes.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "scene-001",
  "headingElementId": "element-001",
  "title": "EXT. ZOCALO - NOCHE",
  "summary": "Lucía encuentra una pista bajo la lluvia.",
  "locationId": "location-001",
  "status": "draft",
  "tagIds": ["tag-opening"]
}
```

Migration/versioning notes: Planned scene records may later gain outline metadata.

Platform neutrality concerns: Do not store collection-view order or Apple UI state.

## Character

Purpose: Character record derived from cues or added manually.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable character ID. |
| `displayName` | `LocalizedText` | Yes | Name shown to user. |
| `normalizedName` | string | Yes | Search/dedupe key. |
| `aliases` | `[LocalizedText]` | No | Optional aliases. |
| `noteIds` | `[PortableID]` | No | Linked notes. |
| `sourceElementIds` | `[PortableID]` | No | Cue references. |
| `customFieldValueIds` | `[PortableID]` | No | Pro custom values. |

Validation rules:

- `displayName` must not be empty.
- `normalizedName` must be stable across save/load for same normalization rules.
- Alias conflicts are warnings, not automatic merges.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "character-001",
  "displayName": "NIÑA",
  "normalizedName": "niña",
  "aliases": ["La niña"],
  "noteIds": ["note-001"],
  "sourceElementIds": ["element-010"]
}
```

Migration/versioning notes: Normalization rule changes require migration diagnostics.

Platform neutrality concerns: Do not link to Apple Contacts or platform identity APIs.

## Location

Purpose: Reusable location record derived from scene headings or added manually.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable location ID. |
| `displayName` | `LocalizedText` | Yes | User-visible location. |
| `normalizedName` | string | Yes | Search/dedupe key. |
| `sourceSceneIds` | `[PortableID]` | No | Scene references. |
| `noteIds` | `[PortableID]` | No | Linked notes. |
| `customFieldValueIds` | `[PortableID]` | No | Pro custom values. |

Validation rules:

- `displayName` must not be empty.
- Source scenes must exist when validation context is available.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "location-001",
  "displayName": "ZOCALO",
  "normalizedName": "zocalo",
  "sourceSceneIds": ["scene-001"],
  "noteIds": []
}
```

Migration/versioning notes: Later production addresses should be additive fields or linked records.

Platform neutrality concerns: Do not require MapKit, CoreLocation, or platform place IDs.

## Note

Purpose: User-authored note linked to project entities or kept as loose material.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable note ID. |
| `body` | `LocalizedText` | Yes | Note content. |
| `title` | `LocalizedText` | No | Optional title. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `updatedAt` | `ISO8601Date` | Yes | Last update. |
| `links` | `[NoteLink]` | No | Target references encoded as portable dictionaries. |
| `tagIds` | `[PortableID]` | No | Tags. |
| `state` | string | No | e.g. `active`, `archived`, `resolved`. |

Validation rules:

- `body` may be empty only for placeholder notes if later allowed.
- Links to missing targets produce diagnostics, not deletion.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "note-001",
  "title": "Opening image",
  "body": "TODO: hacer que la lluvia vuelva al final.",
  "createdAt": "2026-06-30T18:35:00Z",
  "updatedAt": "2026-06-30T18:35:00Z",
  "links": [
    { "targetType": "scene", "targetId": "scene-001" }
  ],
  "tagIds": ["tag-todo"],
  "state": "active"
}
```

Migration/versioning notes: `NoteLink` should become a named contract if link complexity grows.

Platform neutrality concerns: Do not store notes only as attributed strings or Apple Notes links.

## Tag

Purpose: Reusable label for organizing project records.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable tag ID. |
| `name` | `LocalizedText` | Yes | User-visible label. |
| `color` | string | No | Portable color token or hex string. |

Validation rules:

- `name` must not be empty.
- `color`, if present, must be a portable token or validated color string.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "tag-todo",
  "name": "TODO",
  "color": "#FFD700"
}
```

Migration/versioning notes: Tag color semantics may later align with design tokens.

Platform neutrality concerns: Do not store platform color objects.

## DraftVersion

Purpose: Named major state of a screenplay/project.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable draft ID. |
| `name` | `LocalizedText` | Yes | Draft name. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `snapshotId` | `PortableID` | No | Source snapshot. |
| `notes` | `LocalizedText` | No | Draft notes. |

Validation rules:

- `name` must not be empty.
- `snapshotId`, if present, must reference a snapshot.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "draft-002",
  "name": "Draft 2",
  "createdAt": "2026-06-30T19:00:00Z",
  "snapshotId": "snapshot-002",
  "notes": "Versión con nuevo final."
}
```

Migration/versioning notes: Draft content storage strategy may evolve through snapshot/package contracts.

Platform neutrality concerns: No file-system bookmark or platform document version object.

## Snapshot

Purpose: Recoverable project state captured at a point in time.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable snapshot ID. |
| `name` | `LocalizedText` | Yes | User-visible name. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `schemaVersion` | `VersionString` | Yes | Schema at capture time. |
| `reason` | string | No | e.g. `manual`, `beforeAIRewrite`, `beforeDestructiveRoutine`. |
| `packagePath` | `URIString` | No | Relative path to snapshot content. |

Validation rules:

- `name` must not be empty.
- `packagePath`, if present, must stay within `.dreamjotter` package.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "snapshot-002",
  "name": "Before AI rewrite",
  "createdAt": "2026-06-30T19:05:00Z",
  "schemaVersion": "1.0.0",
  "reason": "beforeAIRewrite",
  "packagePath": "snapshots/snapshot-002/"
}
```

Migration/versioning notes: Older snapshots may require migration or read-only restore diagnostics.

Platform neutrality concerns: Snapshot metadata must not rely on APFS snapshots or macOS-only file versions.

## RevisionMetadata

Purpose: Pro metadata describing revision color and revision set assignment.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `revisionSetId` | `PortableID` | Yes | Revision set reference. |
| `color` | string | Yes | `blue`, `pink`, `yellow`, `green`, `goldenrod`, `cherry`, or `custom`. |
| `customColor` | string | No | Hex or portable token when `color` is `custom`. |
| `label` | `LocalizedText` | No | Display label. |
| `createdAt` | `ISO8601Date` | Yes | Assignment timestamp. |

Validation rules:

- `color` must be allowed.
- `customColor` is required when `color` is `custom`.
- Metadata must not be stored only as styled text.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "revisionSetId": "revision-001",
  "color": "goldenrod",
  "label": "Producer notes",
  "createdAt": "2026-06-30T19:10:00Z"
}
```

Migration/versioning notes: Color token changes require compatibility mapping.

Platform neutrality concerns: Do not use platform color types.

## ProductionBreakdown

Purpose: Optional Pro scene-level production item.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable breakdown ID. |
| `sceneId` | `PortableID` | Yes | Linked scene. |
| `category` | string | Yes | Supported production category. |
| `title` | `LocalizedText` | Yes | Item name. |
| `notes` | `LocalizedText` | No | Optional detail. |
| `quantity` | number | No | Optional count. |
| `customFieldValueIds` | `[PortableID]` | No | Pro metadata. |

Validation rules:

- `category` must be one of cast, extras, props, costumes, vehicles, animals, VFX, SFX, locations, makeup, stunts, music, special equipment.
- `sceneId` must reference a scene when validation context is available.
- `title` must not be empty.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "breakdown-001",
  "sceneId": "scene-001",
  "category": "props",
  "title": "Linterna roja",
  "notes": "Debe verse en primer plano.",
  "quantity": 1
}
```

Migration/versioning notes: New categories require compatibility rules.

Platform neutrality concerns: No scheduling or budgeting app dependencies.

## CustomFieldDefinition

Purpose: Pro schema definition for typed custom metadata.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable field definition ID. |
| `name` | `LocalizedText` | Yes | Display name. |
| `fieldType` | string | Yes | text, number, boolean, date, singleSelect, multiSelect. |
| `targetTypes` | `[String]` | Yes | e.g. project, scene, character, note, breakdown. |
| `options` | `[String]` | No | Required for select types. |
| `required` | boolean | No | Default false. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |

Validation rules:

- `name` must not be empty.
- `fieldType` must be supported.
- Select types require non-empty `options`.
- `targetTypes` must not be empty.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "field-001",
  "name": "Estado de escena",
  "fieldType": "singleSelect",
  "targetTypes": ["scene"],
  "options": ["Borrador", "Revisar", "Lista"],
  "required": false,
  "createdAt": "2026-06-30T19:20:00Z"
}
```

Migration/versioning notes: Type changes require migration or diagnostics for existing values.

Platform neutrality concerns: No dynamic Swift types, reflection-only schemas, or UI widgets in definitions.

## CustomFieldValue

Purpose: Typed value assigned to a target for a custom field definition.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable value ID. |
| `definitionId` | `PortableID` | Yes | Custom field definition. |
| `targetType` | string | Yes | Target model type. |
| `targetId` | `PortableID` | Yes | Target record ID. |
| `value` | string/number/boolean/array | Yes | JSON value matching definition. |
| `updatedAt` | `ISO8601Date` | Yes | Last value update. |

Validation rules:

- Value type must match definition.
- Select values must be in definition options.
- Target type must be allowed by definition.

Codable expectation: Required using an explicit JSON-value representation.

Equatable expectation: Required.

Sendable expectation: Practical if JSON value wrapper is Sendable.

JSON example:

```json
{
  "id": "field-value-001",
  "definitionId": "field-001",
  "targetType": "scene",
  "targetId": "scene-001",
  "value": "Revisar",
  "updatedAt": "2026-06-30T19:22:00Z"
}
```

Migration/versioning notes: Field definition migrations must validate existing values.

Platform neutrality concerns: Avoid `Any` storage in implementation; use a portable JSON value enum.

## Routine

Purpose: No-code automation definition that orchestrates commands.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable routine ID. |
| `title` | `LocalizedText` | Yes | User-visible title. |
| `enabled` | boolean | Yes | Whether routine can run. |
| `trigger` | `RoutineTrigger` | Yes | Supported trigger. |
| `conditions` | `[RoutineCondition]` | No | All must pass unless later policy changes. |
| `actions` | `[RoutineAction]` | Yes | Ordered command-backed actions. |
| `createdAt` | `ISO8601Date` | Yes | Creation timestamp. |
| `updatedAt` | `ISO8601Date` | Yes | Last update. |

Validation rules:

- `title` must not be empty.
- `actions` must not be empty.
- Disabled routines remain valid but do not run.
- Actions must be supported and command-backed.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "routine-001",
  "title": "Preparar exportación",
  "enabled": true,
  "trigger": { "kind": "beforeExport" },
  "conditions": [
    { "kind": "proModeEnabled", "parameters": {} }
  ],
  "actions": [
    { "kind": "createSnapshot", "parameters": { "name": "Antes de exportar" } },
    { "kind": "runAnalysis", "parameters": { "analysis": "scriptHealth" } }
  ],
  "createdAt": "2026-06-30T19:30:00Z",
  "updatedAt": "2026-06-30T19:30:00Z"
}
```

Migration/versioning notes: Unknown routine actions must fail validation safely.

Platform neutrality concerns: No scripting language, closures, selectors, or plugin code.

## RoutineTrigger

Purpose: Structured trigger for routine execution.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `kind` | string | Yes | manual, sceneStatusChanged, beforeExport, afterExport, beforeAIRewrite. |
| `parameters` | `[String: JSONValue]` | No | Trigger-specific parameters. |

Validation rules:

- `kind` must be supported.
- Parameters must be JSON-serializable.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{ "kind": "sceneStatusChanged", "parameters": { "sceneId": "scene-001" } }
```

Migration/versioning notes: Unknown trigger kinds are invalid for execution but should be preserved if possible.

Platform neutrality concerns: No notification-center or OS event type references.

## RoutineCondition

Purpose: Predicate that gates routine execution.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `kind` | string | Yes | sceneStatusEquals, projectHasOpenTODOs, proModeEnabled. |
| `parameters` | `[String: JSONValue]` | No | Condition-specific values. |

Validation rules:

- `kind` must be supported.
- Parameters must match condition requirements.
- Conditions are read-only.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{ "kind": "sceneStatusEquals", "parameters": { "status": "Revisar" } }
```

Migration/versioning notes: Unknown conditions fail closed and do not run routine actions.

Platform neutrality concerns: No UI state dependency except portable mode/capability values.

## RoutineAction

Purpose: Command-backed action in a routine.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `kind` | string | Yes | createSnapshot, addNote, runAnalysis, updateSceneStatus, exportProject. |
| `parameters` | `[String: JSONValue]` | No | Action-specific values. |
| `safetyLevel` | string | No | readOnly, normal, destructive. |

Validation rules:

- `kind` must be supported.
- Mutation actions must map to CommandEngine commands.
- Destructive actions require snapshot policy.

Codable expectation: Required.

Equatable expectation: Required.

Sendable expectation: Practical.

JSON example:

```json
{ "kind": "addNote", "parameters": { "body": "Revisar continuidad de José." }, "safetyLevel": "normal" }
```

Migration/versioning notes: Unsupported action kinds must not execute.

Platform neutrality concerns: No arbitrary code, scripts, selectors, shell commands, or plugin calls.

## CommandHistoryEntry

Purpose: Optional audit/history entry for command execution.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | `PortableID` | Yes | Stable entry ID. |
| `commandKind` | string | Yes | Command identifier. |
| `targetIds` | `[PortableID]` | No | Affected records. |
| `createdAt` | `ISO8601Date` | Yes | Execution timestamp. |
| `status` | string | Yes | succeeded, failed, skipped, cancelled. |
| `snapshotId` | `PortableID` | No | Snapshot used for safety. |
| `diagnostics` | `[String]` | No | Portable diagnostic codes/messages. |

Validation rules:

- `commandKind` and `status` must be non-empty.
- `snapshotId`, if present, must reference a snapshot.
- History entries are append-oriented unless future retention policy says otherwise.

Codable expectation: Required if stored.

Equatable expectation: Required for tests.

Sendable expectation: Practical.

JSON example:

```json
{
  "id": "command-history-001",
  "commandKind": "updateSceneStatus",
  "targetIds": ["scene-001"],
  "createdAt": "2026-06-30T19:40:00Z",
  "status": "succeeded",
  "snapshotId": "snapshot-002",
  "diagnostics": []
}
```

Migration/versioning notes: History retention and compaction require later policy.

Platform neutrality concerns: Do not store thread IDs, process IDs, undo manager objects, or platform-specific command objects.

## Unresolved Schema Decisions

- Whether `Scene` is fully stored, fully derived from `ScriptElement`, or hybrid stored metadata plus derived list.
- Exact JSON representation for generic `JSONValue` in Swift.
- Whether command history is canonical audit data or bounded diagnostic data.
- Snapshot content layout inside `.dreamjotter` package.
- Final package file split between one project JSON and multiple section JSON files.
- Whether `metadata` maps remain string-only or move to typed records in a later schema.
