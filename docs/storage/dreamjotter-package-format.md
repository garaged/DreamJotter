# `.dreamjotter` Package Format

## Purpose

A `.dreamjotter` package is the canonical local-first document package for DreamJotter projects. It stores screenplay content, project metadata, planning material, routines, snapshots, attachments, exports, and rebuildable indexes in a directory package that can be copied, backed up, inspected, migrated, and read by future platforms.

## Why Package Storage Is Canonical

The `.dreamjotter` package is canonical because it keeps the writer's project portable and owned by the user. A project must be recoverable from package contents alone without SwiftData, app caches, Spotlight indexes, recents metadata, cloud services, or Apple-only document state.

Canonical package storage supports:

- Local-first ownership.
- Cross-platform future readers.
- Versioned migration.
- Backups and archive export.
- Semantic screenplay models rather than rich-text-only editor buffers.
- Recovery diagnostics when package sections are damaged.

## Why SwiftData Is Not Canonical Storage

SwiftData may later cache recent projects, search indexes, UI state, app metadata, or derived summaries. SwiftData must never be required to reconstruct project content. If SwiftData data is deleted, the `.dreamjotter` package must still load canonical project data.

## Required Package Layout

```text
MyMovie.dreamjotter/
  manifest.json
  project.json
  screenplay.json
  script.fountain
  characters.json
  locations.json
  notes.json
  routines.json
  custom-fields.json
  snapshots/
  attachments/
  exports/
  indexes/
```

All listed top-level files and directories are reserved names. Early packages may omit optional files if `manifest.json` accurately records absence and loaders apply documented defaults. `manifest.json`, `project.json`, and `screenplay.json` are required for a valid editable package.

## File Responsibilities

| Path | Responsibility | Canonical |
| --- | --- | --- |
| `manifest.json` | Package identity, format version, section list, compatibility, checksums where supported. | Yes |
| `project.json` | Root `Project` record and project-level metadata. | Yes |
| `screenplay.json` | Primary semantic screenplay data and ordered `ScriptElement` records. | Yes |
| `script.fountain` | Fountain interoperability projection of screenplay. | No, unless explicitly imported as source during an operation. |
| `characters.json` | Character records, aliases, notes links, source references. | Yes |
| `locations.json` | Location records, source scene references, notes links. | Yes |
| `notes.json` | Notes, idea inbox items if not split later, note links, tags where specified. | Yes |
| `routines.json` | Routine definitions and optionally bounded routine run logs. | Yes for routines; logs policy unresolved. |
| `custom-fields.json` | Custom field definitions and values. | Yes |
| `snapshots/` | Snapshot manifests and captured project states. | Yes for snapshot metadata/content. |
| `attachments/` | User-added binary or external files copied into package. | Yes for attached assets. |
| `exports/` | Generated export artifacts when user chooses to store them in package. | No, generated output. |
| `indexes/` | Rebuildable search/cache indexes. | No, derived. |

## Manifest Schema

`manifest.json` is required.

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `packageId` | string | Yes | Stable package/project package ID. |
| `formatVersion` | string | Yes | Package format version, e.g. `1.0.0`. |
| `minimumReaderVersion` | string | Yes | Lowest reader version expected to read core content. |
| `createdAt` | ISO-8601 string | Yes | Package creation timestamp. |
| `updatedAt` | ISO-8601 string | Yes | Last package write timestamp. |
| `projectFile` | string | Yes | Relative path to `project.json`. |
| `screenplayFile` | string | Yes | Relative path to `screenplay.json`. |
| `sections` | object | Yes | Map of section names to file paths and required flags. |
| `snapshotsPath` | string | Yes | Relative path to snapshots directory. |
| `attachmentsPath` | string | Yes | Relative path to attachments directory. |
| `exportsPath` | string | Yes | Relative path to exports directory. |
| `indexesPath` | string | Yes | Relative path to indexes directory. |
| `checksumManifest` | object | No | Optional checksums by relative path. |
| `compatibility` | object | No | Unknown section and migration policy hints. |

Example:

```json
{
  "packageId": "package-001",
  "formatVersion": "1.0.0",
  "minimumReaderVersion": "1.0.0",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:30:00Z",
  "projectFile": "project.json",
  "screenplayFile": "screenplay.json",
  "sections": {
    "characters": { "path": "characters.json", "required": false },
    "locations": { "path": "locations.json", "required": false },
    "notes": { "path": "notes.json", "required": false },
    "routines": { "path": "routines.json", "required": false },
    "customFields": { "path": "custom-fields.json", "required": false },
    "fountainProjection": { "path": "script.fountain", "required": false }
  },
  "snapshotsPath": "snapshots/",
  "attachmentsPath": "attachments/",
  "exportsPath": "exports/",
  "indexesPath": "indexes/",
  "compatibility": {
    "preserveUnknownSections": true
  }
}
```

## Format Versioning

- `formatVersion` identifies the package layout and section semantics.
- Major version changes may be incompatible.
- Minor version changes should be backward-compatible when unknown fields can be preserved.
- Patch version changes should be reader-compatible.
- Readers must reject newer unsupported major versions with a clear diagnostic and no mutation.
- Readers may open newer minor versions in read-only or compatibility mode if core required sections are understandable.

## Migration Policy

Migrations must:

- Preserve user text and portable IDs where possible.
- Preserve unknown compatible sections where possible.
- Produce diagnostics for repaired, skipped, or unsupported data.
- Never migrate canonical project content into SwiftData as source of truth.
- Require user confirmation before destructive migration.
- Create a snapshot or backup before major destructive migration.

Migration outputs must update `manifest.json` and relevant section schema versions atomically.

## Atomic Write Expectations

Package writes should avoid partially corrupting canonical data.

Expected write strategy:

1. Validate in-memory model before writing.
2. Write changed files to temporary sibling paths inside the package or safe temporary area.
3. Flush and verify serialized content where practical.
4. Replace target files atomically where filesystem supports it.
5. Update `manifest.json` last after section files are written.
6. If any step fails, preserve the previous valid package state where possible.
7. Emit diagnostics for partial writes and recovery attempts.

A future implementation may use platform-specific atomic file APIs behind a portable storage adapter, but package semantics must stay cross-platform.

## Snapshot Storage

`snapshots/` stores snapshot metadata and captured canonical project data.

Recommended layout:

```text
snapshots/
  snapshot-001/
    snapshot.json
    project.json
    screenplay.json
    characters.json
    locations.json
    notes.json
    routines.json
    custom-fields.json
```

Rules:

- Snapshot metadata records ID, name, reason, created date, schema version, and source command/rewrite/routine where available.
- Restoring a snapshot must not proceed if required snapshot files are missing or invalid.
- Snapshot restore is a major mutation and requires explicit confirmation.
- AI rewrite and destructive routine actions require snapshot creation before mutation.

## Attachment Storage

`attachments/` stores user-added assets copied into the package.

Rules:

- Attachment metadata must live in canonical JSON, not only as loose files.
- Attachment paths must be relative to the package.
- File names should be sanitized for cross-platform filesystems.
- External references are allowed only if a later spec defines them; local copied attachments are preferred for portability.
- Attachments may contain private material and must be included in backup archives unless the user excludes them explicitly.

## Export Storage

`exports/` stores generated artifacts only when the user chooses to keep exports in the package.

Rules:

- Exports are not canonical screenplay data.
- Exports can be regenerated from canonical data where export capabilities exist.
- Export metadata should record source project version, export preset, created date, and artifact path.
- Overwriting an export requires safe write behavior.

## Index Storage

`indexes/` stores rebuildable derived indexes.

Rules:

- Indexes are never canonical.
- Missing indexes must not prevent package loading.
- Invalid indexes should be discarded and rebuilt.
- SwiftData may later cache equivalent derived indexes outside the package, but those indexes are not canonical.

## Error Handling

Storage operations return diagnostics rather than silently inventing state.

Expected error categories are defined in `docs/storage/storage-errors.md` and include:

- Missing required file.
- Invalid JSON.
- Unsupported format version.
- Invalid schema.
- Broken reference.
- Permission denied.
- Partial write.
- Checksum mismatch.
- Snapshot restore failure.

## Corruption Recovery Expectations

Recovery is conservative:

- Never overwrite a damaged package during inspection.
- Load valid sections where safe and mark package as degraded/read-only if required sections are damaged.
- Do not invent missing canonical screenplay content.
- Offer diagnostics that identify failing paths.
- Prefer user-confirmed repair or restore from snapshot.
- Preserve unknown files and sections unless user confirms removal.

## Cross-Platform Compatibility

Package data must be readable on macOS, iPadOS, iOS, and future Linux, Windows, and Android implementations.

Rules:

- Use relative paths with `/` separators in JSON.
- Avoid case-only file name distinctions.
- Avoid reserved device names and unsafe characters in generated file names.
- Use UTF-8 JSON files.
- Avoid Apple-specific aliases, bookmarks, security-scoped URLs, or package metadata as canonical references.
- Use portable IDs instead of platform database IDs.

## Backup And Export Behavior

Backup archive export should package all canonical data and user attachments.

Rules:

- Backup archives include `manifest.json`, canonical JSON files, `snapshots/`, and `attachments/` by default.
- `exports/` may be included by user choice.
- `indexes/` may be excluded because indexes are rebuildable.
- Archive export must not require SwiftData.
- Archive export should preserve Unicode file content and package-relative paths.

## Security And Privacy Assumptions

- `.dreamjotter` packages may contain sensitive story ideas, notes, characters, AI suggestions, and attachments.
- Packages are local-first and not uploaded by default.
- No encryption is specified in this contract; future encryption requires an ADR and compatibility plan.
- Attachments and exports may contain private data and should be handled with the same care as screenplay content.
- External AI providers are not part of storage behavior.

## Example Minimal Package

```text
Minimal.dreamjotter/
  manifest.json
  project.json
  screenplay.json
  snapshots/
  attachments/
  exports/
  indexes/
```

`manifest.json`:

```json
{
  "packageId": "package-minimal-001",
  "formatVersion": "1.0.0",
  "minimumReaderVersion": "1.0.0",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:25:43Z",
  "projectFile": "project.json",
  "screenplayFile": "screenplay.json",
  "sections": {},
  "snapshotsPath": "snapshots/",
  "attachmentsPath": "attachments/",
  "exportsPath": "exports/",
  "indexesPath": "indexes/"
}
```

`screenplay.json` excerpt:

```json
{
  "id": "screenplay-001",
  "title": "La Noche Larga",
  "createdAt": "2026-06-30T18:25:43Z",
  "updatedAt": "2026-06-30T18:25:43Z",
  "elements": []
}
```

## Example Full Package

```text
MyMovie.dreamjotter/
  manifest.json
  project.json
  screenplay.json
  script.fountain
  characters.json
  locations.json
  notes.json
  routines.json
  custom-fields.json
  snapshots/
    snapshot-001/
      snapshot.json
      project.json
      screenplay.json
      characters.json
      locations.json
      notes.json
      routines.json
      custom-fields.json
  attachments/
    attachment-001-red-flashlight.png
  exports/
    draft-pdf-2026-06-30.pdf
    script-2026-06-30.fountain
  indexes/
    search-index.json
```

## Acceptance Criteria

- A new package can be created with required files and directories.
- A package can be saved without SwiftData.
- A package can be loaded from canonical files.
- Missing `project.json` produces a storage diagnostic and does not invent project state.
- Invalid JSON produces a path-specific diagnostic.
- Newer unsupported format versions are rejected or opened read-only according to compatibility policy.
- Unicode text is preserved across save/load.
- Snapshots can be created and restored with validation.
- Fountain export writes `script.fountain` or an export artifact without replacing canonical screenplay JSON.
- Backup archive export includes canonical files and attachments by default.

## Given/When/Then Scenarios

### Create New Package

Given a user creates a blank screenplay project, when the package is created, then `manifest.json`, `project.json`, `screenplay.json`, and required directories exist.

### Save Package

Given a valid in-memory project, when save runs, then canonical JSON files are written and `manifest.json` is updated last.

### Load Package

Given a valid `.dreamjotter` package, when load runs, then project state is reconstructed from package files without SwiftData.

### Load Package With Missing `project.json`

Given `project.json` is missing, when load runs, then loading fails or enters recovery mode with a `missingRequiredFile` diagnostic.

### Load Package With Invalid JSON

Given `screenplay.json` contains invalid JSON, when load runs, then loading reports `invalidJSON` with the failing path and does not invent screenplay elements.

### Load Package With Newer Unsupported Format Version

Given `manifest.json` has unsupported major `formatVersion`, when load runs, then the package is rejected or opened read-only with `unsupportedFormatVersion` and no mutation.

### Preserve Unicode

Given screenplay text contains `¿Dónde está José? La niña volvió al Zócalo.`, when save and load run, then the exact Unicode text is preserved.

### Create Snapshot

Given a project is open, when a snapshot is created, then a snapshot directory with metadata and canonical section files is created under `snapshots/`.

### Restore Snapshot

Given a valid snapshot exists, when restore is confirmed, then project state is restored from snapshot files after validation.

### Export Fountain

Given semantic screenplay data exists, when Fountain export runs, then `script.fountain` or an export artifact is written as an interoperability projection and canonical `screenplay.json` remains source of truth.

### Export Backup Archive

Given a package contains canonical files and attachments, when backup archive export runs, then the archive includes canonical files, snapshots, and attachments, and may exclude rebuildable indexes.

## Related Specs

- `docs/data-contracts/core-domain-model.md`
- `docs/data-contracts/serialization-rules.md`
- `docs/storage/storage-errors.md`
- `docs/adr/0002-local-first-dreamjotter-package.md`
