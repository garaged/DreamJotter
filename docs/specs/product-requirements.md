# Product Requirements Specification

## Product Summary

DreamJotter is a screenplay app for non-programmers, with optional professional customization. The product helps writers create semantic screenplay projects, organize story material, revise drafts, export useful formats, and prepare for more advanced production workflows without requiring programming knowledge.

The product scope through Milestone 4 covers product definition, semantic project requirements, core editing behavior, native Apple app foundations, exports, routines, and advanced workflow specs. It does not include production app implementation in this document.

## Target Users

| User | Primary Goal | Product Implication |
| --- | --- | --- |
| Beginner screenwriter | Start writing a properly structured screenplay without learning formatting rules first. | Simple Mode must present guided defaults and hide advanced configuration. |
| Casual storyteller | Capture scenes, ideas, characters, and story beats without committing to production detail. | Notes, idea inbox, guided setup, and scene cards must be approachable. |
| Professional writer | Control formatting, revisions, drafts, exports, and screenplay structure precisely. | Pro Mode must expose specialized controls without changing the semantic core model. |
| Indie filmmaker | Move from script to practical planning while preserving writer-friendly workflows. | Scene lists, production-minded metadata, breakdowns, and exports must derive from screenplay data. |
| Production-minded user | Track elements that matter for future production decisions. | Production breakdowns and custom fields should remain optional and structured. |
| Advanced/customization user | Customize repeatable workflows without needing arbitrary plugin code. | Commands and routines must precede plugin APIs. |

## Platform Priority

1. macOS first.
2. iPadOS and iOS second.
3. Linux, Windows, and Android later.

Apple UI may be native and platform-specific, but portable product behavior must remain in specs and future core layers. Android, Windows, and Linux are future compatibility targets, not Milestone 4 native app deliverables.

## Progressive Complexity Model

### Simple Mode

Simple Mode is the default experience for beginners and casual storytellers. It should provide common screenplay writing workflows with minimal visible configuration, guided choices, readable defaults, and recovery from common mistakes.

### Pro Mode

Pro Mode exposes specialized controls for professional writers, indie filmmakers, production-minded users, and advanced customization users. Pro Mode may add formatting controls, revision tools, export presets, custom fields, production breakdowns, draft comparison, and routines. Pro Mode must not fork the `.dreamjotter` format or require plugins.

## Core Feature Requirements

| Traceability ID | Feature Category | User Goal | Beginner Behavior | Pro Behavior | Acceptance Criteria | Edge Cases | Implementation Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PRD-EDITOR-001 | Screenplay editor | Write and revise a screenplay as structured script content. | User can create and edit scenes, action, character cues, dialogue, parentheticals, and transitions using simple controls. | User can inspect and adjust element types, structure, and advanced screenplay metadata. | Given a project is open, when the user adds script content, then each paragraph is stored as a semantic screenplay element. | Empty documents; pasted plain text; invalid element transitions; accidental deletion; very long scenes. | Editor specs must distinguish semantic model behavior from text rendering. |
| PRD-FORMAT-001 | Smart formatting | Keep screenplay layout correct without manual formatting work. | App infers common element changes and applies standard screenplay presentation defaults. | User can override or tune formatting rules where specs allow. | Given a user enters a character cue followed by text, when dialogue is added, then dialogue is represented as dialogue and rendered appropriately. | Ambiguous uppercase text; names that look like transitions; pasted Fountain; mixed language scripts. | Formatting is derived from semantic elements, not the canonical source of truth. |
| PRD-DASHBOARD-001 | Project dashboard | See current projects and project status quickly. | User sees recent local projects and can create/open a `.dreamjotter` package. | User may see metadata such as draft state, revision status, export presets, or custom fields. | Given local projects exist, when the dashboard opens, then recent projects are discoverable without scanning the filesystem manually. | Missing files; moved packages; corrupt metadata cache; no recent projects. | Dashboard metadata may be cached, but must be rebuildable from project packages. |
| PRD-SCENELIST-001 | Scene list | Navigate screenplay structure by scene. | User can view scenes in script order and jump to a selected scene. | User can filter, reorder where allowed, and inspect scene-level metadata. | Given a screenplay has scene headings, when the scene list opens, then every valid scene appears in document order. | Scene-less drafts; duplicate headings; malformed headings; hidden outline-only scenes. | Scene list is generated from semantic scene elements. |
| PRD-SCENECARDS-001 | Scene cards | Organize story flow visually. | User can view scene summaries as cards and reorder planned scenes where supported. | User can add metadata such as purpose, status, location, characters, beats, and production notes. | Given scene cards are shown, when a scene card is selected, then the corresponding script scene can be located. | Unwritten planned scenes; merged scenes; deleted scenes; card order conflicts with script order. | Must define whether cards are script-derived, outline-derived, or both before implementation. |
| PRD-CHARACTER-001 | Character management | Track characters consistently across the script. | User can see characters detected from character cues. | User can manage aliases, notes, metadata, and consistency checks. | Given character cues exist, when character management opens, then detected character names are listed. | Same name with spelling variants; non-speaking characters; dual dialogue; aliases. | Character records should link to semantic cues and optional project metadata. |
| PRD-NOTES-001 | Notes and idea inbox | Capture ideas without disrupting writing. | User can save loose notes and attach notes to scenes or project areas. | User can categorize, search, convert, or link notes to elements and routines. | Given the user creates a note, when it is saved, then it remains available from the project and can be found later. | Orphaned notes; duplicate notes; notes attached to deleted elements; private versus exportable notes. | Notes are project data inside `.dreamjotter`, not only app-local cache. |
| PRD-SEARCH-001 | Search | Find script text, notes, scenes, and metadata. | User can search visible screenplay text and notes. | User can scope search by element type, character, scene, metadata, or custom field. | Given a query matches script content, when search runs, then matching locations are listed and navigable. | Empty queries; diacritics; case sensitivity; deleted snapshot content; large projects. | Search indexes may be derived; source of truth remains project data. |
| PRD-STORAGE-001 | Local-first project package | Own and move screenplay projects as local files. | User creates, opens, saves, copies, and backs up `.dreamjotter` packages. | User may inspect package contents where practical and use advanced project metadata. | Given a `.dreamjotter` package exists, when opened on a supported app version, then canonical screenplay data loads without SwiftData. | Partial writes; package corruption; version mismatch; file permissions; concurrent edits by external tools. | `.dreamjotter` is canonical. SwiftData is never canonical storage. |
| PRD-VERSIONING-001 | Snapshots/versioning | Preserve recoverable draft states. | User can create named snapshots and restore a previous snapshot with clear confirmation. | User can compare or annotate snapshots and manage retention. | Given a snapshot exists, when the user restores it, then the project returns to that saved screenplay state after confirmation. | Huge projects; snapshots across schema versions; restoring deleted metadata; storage pressure. | Snapshot format must be specified before implementation. |
| PRD-FOUNTAIN-001 | Fountain import/export | Exchange scripts with plain-text screenplay workflows. | User can import common Fountain and export readable Fountain. | User can tune export choices for notes, title page, sections, synopses, and metadata. | Given valid Fountain input, when imported, then supported screenplay elements become semantic elements. | Non-standard Fountain; unsupported markup; ambiguous elements; round-trip loss. | Fountain support is practical interoperability, not the canonical format. |
| PRD-PDF-001 | PDF export abstraction | Export scripts as PDFs without coupling core logic to one renderer. | User can export a standard readable screenplay PDF. | User can select presets and advanced PDF options where supported. | Given a screenplay project, when PDF export runs, then an output PDF is produced from semantic content using a documented export pipeline. | Missing fonts; pagination differences; export cancellation; unsupported metadata. | Core should define export intent; platform adapters may perform rendering. |
| PRD-HEALTH-001 | Script health report | Surface script issues and useful story metrics. | User sees understandable warnings such as missing title, empty scenes, or inconsistent character names. | User can inspect detailed metrics, filters, and rule categories. | Given detectable issues exist, when the report runs, then warnings link to relevant script locations or project data. | False positives; intentionally unconventional scripts; incomplete drafts; hidden notes. | Health report must be advisory and should not block writing. |
| PRD-STORYSETUP-001 | Guided story setup | Help users start with a coherent project structure. | User can create a project through prompts for title, format, logline, and basic story shape. | User can choose templates, metadata fields, and advanced defaults. | Given the user completes setup, when the project is created, then the project contains the selected metadata and starter structure. | User skips fields; changes template later; imports instead of starts new. | Setup creates semantic project data, not a separate wizard-only state. |
| PRD-LOGLINE-001 | Logline builder | Help define a concise story premise. | User can draft and revise a logline with guided fields. | User can maintain multiple logline variants and link them to drafts or exports. | Given logline fields are entered, when saved, then a project logline is stored and visible in project metadata. | Empty logline; multiple languages; spoilers; long prose instead of logline. | Logline is project metadata and may be exportable by preset. |
| PRD-BEATS-001 | Beat sheets | Plan story beats alongside the script. | User can create a simple beat sheet and connect beats to scenes. | User can use advanced beat structures, statuses, and custom labels. | Given beats are linked to scenes, when viewing a scene, then associated beats are discoverable. | Beats without scenes; scenes with multiple beats; deleted linked scenes; reordered story. | Beat models must remain optional and not replace screenplay structure. |
| PRD-AI-001 | AI abstraction | Prepare product boundaries for future AI assistance. | User-facing AI features are not required through Milestone 4. | Pro specs may define where AI assistance could plug into commands, exports, analysis, or routines. | Given AI is referenced in specs, then behavior is described through provider-neutral abstractions and no real provider integration is required. | Privacy concerns; external service dependency; hallucinated script edits; offline use. | Do not call external AI services through Milestone 4. Define abstractions only. |
| PRD-CONTINUITY-001 | Continuity warnings | Warn about likely inconsistencies. | User sees simple warnings for obvious continuity issues when detectable. | User can configure warning categories and inspect evidence. | Given a detectable inconsistency exists, when continuity checks run, then the warning identifies the issue and relevant script locations. | Intentional inconsistencies; unreliable metadata; aliases; incomplete drafts. | Warnings are advisory and should be traceable to semantic data. |
| PRD-READALOUD-001 | Table-read/read-aloud support | Hear dialogue and script flow. | User can read aloud script content in document order using system capabilities where available. | User can assign voices or roles where supported by platform capability. | Given a script has dialogue, when read-aloud starts, then screenplay elements are read in a predictable order. | Missing voices; stage directions; dual dialogue; interruptions; platform differences. | Use platform adapters for speech. Core defines read order and role metadata. |
| PRD-REVISIONS-001 | Revision colors | Track screenplay revisions visibly. | User can see revision markings when revisions are enabled. | User can manage revision colors, labels, and revision sets. | Given revision mode is enabled, when content changes, then changes can be associated with the active revision set. | Edits across snapshots; conflicting revision labels; imported revisions; disabling revisions. | Revision metadata must be semantic and export-aware. |
| PRD-COMPARE-001 | Draft comparison | Understand differences between drafts. | User can compare current draft with a selected snapshot or draft. | User can filter by element type, scene, character, revision set, or metadata. | Given two drafts exist, when comparison runs, then additions, removals, and changes are reported. | Moved scenes; renamed characters; formatting-only changes; schema migrations. | Compare should operate on semantic elements, not just line text. |
| PRD-BREAKDOWN-001 | Production breakdown | Extract production-minded information from script data. | User can see simple scene details such as location, time of day, and speaking characters. | User can track props, wardrobe, vehicles, extras, VFX, and custom categories. | Given scene metadata exists, when breakdown opens, then production categories are grouped by scene. | Missing metadata; ambiguous scene headings; non-production drafts; custom categories. | Breakdown remains optional and must not burden Simple Mode. |
| PRD-EXPORTPRESETS-001 | Export presets | Reuse export settings for different audiences. | User can choose common presets such as draft PDF or Fountain export. | User can create, rename, duplicate, and tune presets. | Given an export preset exists, when selected, then export uses its documented settings. | Missing preset; obsolete settings; unsupported platform renderer; invalid filename. | Presets should be project or app metadata as specified later; export behavior remains deterministic. |
| PRD-CUSTOMFIELDS-001 | Custom fields | Store user-defined structured metadata. | Simple Mode hides custom fields unless already relevant to a workflow. | User can define fields for projects, scenes, characters, notes, or production categories. | Given a custom field is defined, when data is entered, then it is saved in the project and available to search/export rules where supported. | Field rename; type changes; deleted fields; invalid values; import/export mapping. | Custom fields must be typed and schema-versioned. |
| PRD-ROUTINES-001 | Routines v1 | Automate repeatable workflows without plugins. | Beginner-facing routines are built-in and safe, such as creating a weekly snapshot or preparing a draft export. | User can compose or configure routines from approved commands. | Given a routine is run, when all commands succeed, then the routine reports completion and any generated artifacts. | Partial failure; undo boundaries; destructive commands; missing inputs; long-running export. | Routines depend on command semantics. No arbitrary code execution. |

## Explicit Non-Goals Through Milestone 4

- Full plugin marketplace.
- Arbitrary code execution plugins.
- Real-time collaboration.
- Android full editor.
- Windows/Linux native app.
- Cloud sync.
- SwiftData as canonical storage.
- Real AI provider integration.
- Full FDX support.

## Product Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Rich-text editor assumptions replace semantic screenplay data. | Export, analysis, routines, and portability become fragile. | Specify semantic element model before editor implementation. |
| Pro features overwhelm beginners. | First-run experience becomes intimidating. | Keep Simple Mode default and hide advanced controls until needed. |
| `.dreamjotter` package is under-specified. | Future implementation creates incompatible storage decisions. | Define package contract, versioning, validation, and fixtures before app code. |
| Plugins influence MVP architecture too early. | Security and compatibility concerns slow core delivery. | Keep plugin APIs deferred; use commands and routines first. |
| PDF and Fountain expectations imply complete industry compatibility too soon. | Milestone scope expands beyond validation capacity. | Define supported subsets and known limitations in export specs. |
| AI expectations imply external service integration. | Privacy, cost, and reliability concerns appear before product boundaries are ready. | Define provider-neutral abstractions only through Milestone 4. |

## MVP Quality Bar

The MVP quality bar through Milestone 4 is not feature quantity. It is confidence that the core screenplay project can be represented, edited, validated, saved, restored, exported, and reasoned about from semantic data.

Minimum quality expectations:

- A beginner can create and understand a basic screenplay project without technical setup.
- A professional path exists through Pro Mode without corrupting beginner workflows.
- `.dreamjotter` remains the canonical project artifact.
- Core behavior is specified without UI-framework coupling.
- Exports and reports derive from semantic data.
- Routines use explicit commands and do not execute arbitrary plugin code.

## Acceptance Strategy

Acceptance will be tracked through stable PRD IDs, milestone ownership, and observable criteria. Later specs should expand each PRD ID into detailed Given/When/Then examples, executable fixtures, validation scripts, or tests as implementation begins.

Acceptance sources:

- Product requirements in this document.
- Architecture decisions in `docs/adr`.
- Future data contracts for `.dreamjotter`, screenplay elements, snapshots, exports, and routines.
- Future executable specs and fixtures.

A feature requirement is ready for implementation only when its acceptance criteria, edge cases, data model implications, platform implications, and traceability are current.
