# Export System Spec

Status: specified
Milestone: M2-M4
Traceability ID: EXPORT-SYSTEM-001

## Purpose

The export system turns canonical DreamJotter project data into shareable output formats. Exports are projections from the `.dreamjotter` package and semantic screenplay model. Export artifacts are not canonical storage and must not be required to recover a project.

## Scope

The export system covers:

- Fountain export.
- Markdown export.
- Plain text export.
- JSON backup export.
- PDF export abstraction.
- Export presets.
- Reader copy.
- Contest submission.
- Print script.
- Production breakdown export.
- Writer backup.
- Plain text archive.
- Unsupported export handling.

## Principles

- Export from semantic screenplay/project data, not from rich text buffers only.
- Preserve Unicode and Spanish text.
- Keep export intent in portable core; platform adapters may perform rendering.
- Treat PDF rendering as an abstraction until platform renderers are specified.
- Do not make SwiftData, indexes, or export artifacts canonical.
- Unsupported exports produce diagnostics instead of corrupt or partial silent output.

## Export Request

An export request is a portable record:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable export request ID. |
| `projectId` | Yes | Project to export. |
| `format` | Yes | `fountain`, `markdown`, `plainText`, `jsonBackup`, `pdf`, or future format. |
| `preset` | No | Named export preset. |
| `scope` | Yes | Full project, screenplay only, selected scenes, notes, or breakdown. |
| `includeNotes` | Yes | Whether writer notes are included. |
| `includeMetadata` | Yes | Whether project metadata is included. |
| `destinationPolicy` | Yes | Save location/overwrite policy abstraction. |
| `requestedAt` | Yes | ISO-8601 timestamp. |

Export requests may later be expressed as `exportProject` commands when persistence or file output is involved.

## Export Result

An export result includes:

| Field | Required | Purpose |
| --- | --- | --- |
| `requestId` | Yes | Original request. |
| `status` | Yes | `succeeded`, `failed`, `unsupported`, or `cancelled`. |
| `artifacts` | No | Export artifact references. |
| `diagnostics` | No | Warnings and errors. |
| `completedAt` | Yes | ISO-8601 timestamp. |

## Fountain Export

Fountain export maps semantic screenplay elements to supported Fountain syntax as defined in `docs/editor/fountain-support-spec.md`.

Acceptance criteria:

- Scene headings, action, characters, dialogue, parentheticals, transitions, notes, sections, and page breaks export in document order where supported.
- Unicode text is preserved.
- Unsupported semantic elements produce diagnostics or conservative text output.
- Fountain export does not become canonical storage.

## Markdown Export

Markdown export produces readable script/story documents for review and lightweight sharing.

Expected behavior:

- Project title and metadata may appear as headings when included.
- Scene headings use Markdown headings or bold labels according to preset.
- Dialogue preserves speaker names and text.
- Notes may be included under separate sections when requested.
- Markdown export is not intended for final screenplay pagination.

## Plain Text Export

Plain text export produces simple UTF-8 text with screenplay structure preserved through spacing and labels.

Expected behavior:

- No Markdown syntax required.
- Unicode text is preserved.
- Useful for plain email, archival review, and external tools.
- Formatting precision is lower than PDF or Fountain.

## JSON Backup Export

JSON backup export produces a portable backup representation of canonical project data.

Rules:

- JSON backup must be UTF-8 and versioned.
- It should include project, screenplay, characters, locations, notes, routines, custom fields, snapshots metadata, and manifest-like metadata where included by policy.
- It must not require SwiftData to restore core project data.
- It may omit large attachments or include references according to future backup policy.

JSON backup is an export artifact, not a replacement for `.dreamjotter` package storage.

## PDF Export Abstraction

PDF export is defined as an export intent and result contract. Actual PDF rendering may be platform-specific later.

Core responsibilities:

- Define export intent, content scope, and preset.
- Provide semantic screenplay data to a renderer.
- Receive artifacts and diagnostics.

Platform adapter responsibilities:

- Page layout.
- Font metrics.
- Pagination.
- PDF file generation.
- Print dialog integration.

## Export Presets

Export presets are reusable export settings.

Required presets through Milestone 4:

| Preset | Purpose | Expected Settings |
| --- | --- | --- |
| `readerCopy` | Shareable script for readers. | Include title, screenplay text, minimal notes off by default. |
| `contestSubmission` | Clean script for contest submission. | Hide notes, hide production metadata, standardized PDF/Fountain options. |
| `printScript` | Print-friendly script. | PDF intent, page layout abstraction, notes off by default. |
| `productionBreakdown` | Export production categories. | Include scene production breakdown data. |
| `writerBackup` | Preserve project data for writer ownership. | JSON backup and optional `.dreamjotter` archive direction. |
| `plainTextArchive` | Durable plain text archival output. | Plain UTF-8 script and selected metadata. |

## Reader Copy

Reader copy exports a readable draft for human feedback. It should avoid exposing private notes, routine logs, internal IDs, AI suggestion metadata, or production-only fields unless explicitly included.

## Contest Submission

Contest submission exports a clean copy. It should omit notes, TODOs, internal diagnostics, and production metadata. Future implementation may add title page controls, anonymity options, and PDF formatting constraints.

## Print Script

Print script exports a PDF intent for physical reading. Exact pagination and industry formatting are adapter-level future work. The core must still provide semantic content in order.

## Production Breakdown

Production breakdown export includes supported categories such as cast, extras, props, costumes, vehicles, animals, VFX, SFX, locations, makeup, stunts, music, and special equipment when those data exist.

Simple Mode should not force production breakdown concepts into normal writing flows.

## Writer Backup

Writer backup prioritizes ownership and recoverability. It should include canonical project data and enough metadata to reconstruct the project without SwiftData. It may include a `.dreamjotter` package archive or JSON backup direction in future implementation.

## Plain Text Archive

Plain text archive produces durable text output suitable for long-term readability. It should preserve screenplay order and Unicode text even if advanced metadata is omitted.

## Unsupported Export Handling

Unsupported or unavailable exports must return diagnostics.

Rules:

- Do not silently produce misleading output.
- Do not mutate project data to satisfy export.
- Do not require network services.
- If PDF rendering is unavailable, return an unsupported renderer diagnostic.
- If a preset includes unsupported options, export the supported subset only when explicitly safe and report warnings.

## Given/When/Then Scenarios

### Fountain Export

Given a project has semantic screenplay elements
When the user exports Fountain
Then supported elements are serialized in document order
And Unicode text is preserved.

### Contest Submission

Given a project contains notes and TODOs
When the user exports using `contestSubmission`
Then notes and TODO diagnostics are excluded from the export artifact
And project data remains unchanged.

### PDF Unsupported Renderer

Given PDF export is requested on a platform without a renderer
When export runs
Then the result is `unsupported`
And the diagnostic explains PDF rendering is unavailable.

### JSON Backup

Given a writer requests `writerBackup`
When JSON backup export succeeds
Then canonical project data is included in a versioned UTF-8 JSON artifact
And SwiftData is not required to restore it.

## Non-Goals

- No production export implementation.
- No PDF renderer implementation.
- No print dialog UI.
- No exact pagination guarantee.
- No FDX export.
- No cloud export or sync.
- No export marketplace or plugin renderer.

## Related Specs

- `docs/editor/fountain-support-spec.md`
- `docs/storage/dreamjotter-package-format.md`
- `docs/data-contracts/core-domain-model.md`
- `docs/milestones/milestone-4-pro-foundations.md`
