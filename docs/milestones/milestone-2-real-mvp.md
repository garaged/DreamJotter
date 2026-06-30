# Milestone 2: Real MVP Writer Organization

## Goal

Make DreamJotter useful as a real writing app, not just a screenplay text editor. Milestone 2 expands the Milestone 1 semantic screenplay foundation into local project organization, writer-facing navigation, notes, search, snapshots, starter templates, script health checks, export preset foundations, and Simple Mode boundaries.

Milestone 2 remains documentation-first in this prompt. It does not implement production code, create app UI, create a Swift package, create an Xcode project, or introduce plugins.

## Scope Summary

Milestone 2 includes specifications for:

- Project dashboard.
- Character manager foundation.
- Scene cards.
- Notes system.
- Idea inbox.
- Search.
- Snapshots.
- Local `.dreamjotter` package save/load.
- Script health report.
- Starter templates.
- Export presets foundation.
- Simple Mode.
- Pro Mode hidden/disabled foundation.

## Feature Specifications

### M2-DASHBOARD-001: Project Dashboard

User story: As a writer, I want a home view where I can create, open, and return to local screenplay projects without navigating the filesystem every time.

Beginner behavior: Simple Mode shows blank project creation, starter templates, and recent local projects with minimal metadata.

Pro behavior: Pro Mode may later show draft state, snapshot count, health report status, export preset indicators, and custom fields. In Milestone 2, Pro Mode data may be specified but should remain hidden or disabled by default.

Acceptance criteria:

- Dashboard can represent recent `.dreamjotter` packages from local project metadata or rebuildable app metadata.
- User can start a blank screenplay project from dashboard behavior.
- User can start a project from short film and feature film templates.
- Missing recent files produce a recoverable missing-file state.
- Dashboard metadata is not canonical project storage.

Given/When/Then scenarios:

- Given no recent projects, when the dashboard opens, then blank project and template creation actions are available.
- Given a recent `.dreamjotter` package exists, when the dashboard opens, then the project can be selected for loading.
- Given a recent project was moved or deleted, when the dashboard opens, then the item is marked unavailable and can be removed from recents.

Data model implications: Requires a dashboard project summary containing display title, package URL or bookmark reference, last opened date, modified date if known, and derived status flags.

Storage implications: Dashboard recents may be app metadata or cache. Canonical screenplay and project data remains in `.dreamjotter`.

Edge cases:

- Empty recents.
- Moved package.
- Duplicate project titles.
- Permission denied for a package location.
- Package exists but manifest is invalid.

Future cross-platform notes: Linux, Windows, and Android dashboards should read the same `.dreamjotter` package metadata but can use platform-specific recent-file mechanisms.

### M2-CHARACTER-001: Character Manager Foundation

User story: As a writer, I want to see and manage characters already present in my script so names remain consistent.

Beginner behavior: Simple Mode lists detected speaking characters and allows basic notes for each character.

Pro behavior: Pro Mode may later expose aliases, continuity checks, custom fields, and production metadata. Milestone 2 only reserves the structure.

Acceptance criteria:

- Character manager derives initial characters from semantic character cue elements.
- User can add a character not yet present in the screenplay.
- User can attach basic notes to a character.
- Duplicate detected names collapse to one character record where normalization is clear.
- Character records preserve Unicode names.

Given/When/Then scenarios:

- Given a script contains `MARIA` dialogue, when character manager opens, then `MARIA` appears as a detected character.
- Given a blank project, when the user adds `NIÑA` as a character, then the character record is stored in the project.
- Given repeated `ANA` cues, when characters are derived, then a single `ANA` character summary appears.

Data model implications: Requires character records with stable ID, display name, normalized key, source references, notes, and created/updated timestamps.

Storage implications: Character records are canonical project data inside `.dreamjotter`; derived detections may be rebuildable indexes.

Edge cases:

- Spelling variants.
- Accents and Unicode names.
- Deleted cue after character creation.
- Character created before appearing in script.
- Transition text that looks uppercase.

Future cross-platform notes: Character records should be plain portable data independent of Apple contacts, address books, or platform identity APIs.

### M2-SCENECARDS-001: Scene Cards

User story: As a writer, I want to organize the story visually by scene without losing connection to the screenplay.

Beginner behavior: Simple Mode shows scene cards generated from semantic scenes, with title, summary, and optional note.

Pro behavior: Pro Mode may later expose status, beat links, production metadata, and custom fields. Milestone 2 keeps these hidden or disabled unless already specified in data.

Acceptance criteria:

- Scene cards can be generated from scene headings in script order.
- Each card links to a source scene or planned scene record.
- User can add or edit a short scene summary.
- Empty screenplay shows an empty scene-card state with a create-scene affordance in future UI.
- Scene card order must not silently diverge from screenplay order unless a future reorder command is specified.

Given/When/Then scenarios:

- Given a one-scene screenplay, when scene cards are generated, then one card appears with the scene heading text.
- Given a multi-scene screenplay, when scene cards are generated, then cards appear in document order.
- Given the user adds a summary to a scene card, when the project is saved, then the summary remains linked to that scene.

Data model implications: Requires scene card metadata keyed by scene element ID or planned scene ID, with summary, note, and optional status fields.

Storage implications: Scene card metadata is canonical project data. Derived card lists can be rebuilt from screenplay scenes plus metadata.

Edge cases:

- Scene heading text changes.
- Scene deleted after a card has notes.
- Planned scene has no screenplay text yet.
- Duplicate scene headings.
- Card metadata without a matching source scene.

Future cross-platform notes: Scene cards should be represented as portable records, not Apple collection-view state.

### M2-NOTES-001: Notes System

User story: As a writer, I want to capture notes and attach them to relevant project parts without interrupting writing.

Beginner behavior: Simple Mode supports plain project notes, scene-linked notes, and character-linked notes.

Pro behavior: Pro Mode may later expose note categories, export inclusion flags, custom fields, and routine actions. Milestone 2 reserves these fields only where needed.

Acceptance criteria:

- User can create a project-level note.
- User can link a note to a scene.
- User can link a note to a character.
- Notes can be searched.
- Notes linked to deleted entities remain recoverable as orphaned notes with diagnostics.

Given/When/Then scenarios:

- Given a scene exists, when the user links a note to the scene, then the note appears in scene-linked note queries.
- Given a character exists, when the user links a note to the character, then the note appears in character-linked note queries.
- Given a linked scene is deleted, when notes are loaded, then the note remains available and reports a missing target.

Data model implications: Requires note records with ID, body, created/updated timestamps, links, optional title, and orphan status derived from target validation.

Storage implications: Notes are canonical project data inside `.dreamjotter`, not app-local cache.

Edge cases:

- Empty note body.
- Duplicate notes.
- Links to deleted scenes or characters.
- Large note body.
- Unicode note text.

Future cross-platform notes: Notes should use portable markdown-or-plain-text policy specified later, not platform-specific attributed strings.

### M2-INBOX-001: Idea Inbox

User story: As a writer, I want a fast place to capture ideas before deciding whether they are scenes, notes, characters, or story material.

Beginner behavior: Simple Mode provides an inbox for loose ideas with minimal fields: text, created date, and optional tag.

Pro behavior: Pro Mode may later convert inbox items into commands, scene cards, notes, or routines. Milestone 2 specifies conversion intent but not automation.

Acceptance criteria:

- User can create an inbox item.
- Inbox items persist inside the project.
- Inbox items can be searched.
- Inbox items can be marked resolved or archived.
- Conversion to structured project data is deferred unless a later command spec defines it.

Given/When/Then scenarios:

- Given a project is open, when the user captures an idea, then the idea is stored with created date and text.
- Given an inbox item is archived, when active inbox items are listed, then the archived item is excluded but not deleted.
- Given search text matches an inbox item, when search runs, then the item appears in results.

Data model implications: Requires inbox item records with ID, body, state, created/updated timestamps, and optional tags.

Storage implications: Inbox items are canonical project data inside `.dreamjotter`.

Edge cases:

- Empty idea text.
- Duplicate ideas.
- Very long idea text.
- Archived items appearing in search depending on search scope.

Future cross-platform notes: Inbox state should be portable and independent of platform reminder or notes apps.

### M2-SEARCH-001: Search

User story: As a writer, I want to find text and project material across script, notes, characters, and ideas.

Beginner behavior: Simple Mode provides one search field across screenplay text, notes, characters, scene headings, and inbox items.

Pro behavior: Pro Mode may later expose scoped search filters, element-type filters, custom fields, and snapshot search. Milestone 2 reserves filter concepts but keeps default search simple.

Acceptance criteria:

- Search can query screenplay text.
- Search can query notes.
- Search can query character names and notes.
- Search can query idea inbox items.
- Search results identify type, display text, and navigation target where available.
- Search indexes, if used later, are rebuildable from `.dreamjotter` canonical data.

Given/When/Then scenarios:

- Given script text contains `rain`, when searching `rain`, then matching screenplay elements appear.
- Given a scene note contains `budget`, when searching `budget`, then the linked note appears with scene context.
- Given a character named `MARIA`, when searching `maria`, then the character result appears regardless of case policy specified later.

Data model implications: Requires a unified search result representation with source type, source ID, match preview, and optional navigation target.

Storage implications: Search index is derived data. Canonical searchable content lives in screenplay, notes, character, and inbox records.

Edge cases:

- Empty query.
- Diacritics and Unicode normalization.
- Case sensitivity.
- Archived inbox items.
- Notes linked to missing targets.
- Large projects.

Future cross-platform notes: Search semantics should be specified independently from Apple search APIs so other platforms can reproduce results.

### M2-SNAPSHOTS-001: Snapshots

User story: As a writer, I want to preserve recoverable draft states before major changes.

Beginner behavior: Simple Mode supports creating named snapshots and restoring them with confirmation.

Pro behavior: Pro Mode may later expose snapshot comparison, retention settings, labels, and automation triggers. Milestone 2 only defines snapshot foundations.

Acceptance criteria:

- User can create a snapshot of canonical project content.
- Snapshot records include ID, name, created date, and schema version.
- Snapshot restore requires explicit confirmation.
- Destructive or major automated actions must identify whether a snapshot is required before execution.
- Snapshot restore preserves data according to the snapshot contract to be specified later.

Given/When/Then scenarios:

- Given a project has screenplay and notes, when the user creates a snapshot, then a recoverable project state is recorded.
- Given a snapshot exists, when the user restores it after confirmation, then the project returns to the snapshot state.
- Given a snapshot was created with an older schema version, when loading it, then compatibility diagnostics are produced if migration is needed.

Data model implications: Requires snapshot manifest records and a future snapshot data contract.

Storage implications: Snapshots live inside `.dreamjotter/snapshots/` or an equivalent package area defined by a later storage contract.

Edge cases:

- Large projects.
- Storage pressure.
- Interrupted snapshot write.
- Snapshot restore after schema change.
- Snapshot name collision.

Future cross-platform notes: Snapshot format must be portable and not depend on Apple file coordination or SwiftData.

### M2-STORAGE-001: Local `.dreamjotter` Package Save/Load

User story: As a writer, I want my project saved as a local `.dreamjotter` package I can own, back up, and reopen.

Beginner behavior: Simple Mode saves and loads projects without exposing package internals.

Pro behavior: Pro Mode may later expose package inspection, diagnostics, repair, and export of package sections. Milestone 2 only defines safe load/save behavior.

Acceptance criteria:

- Save writes canonical project data to a `.dreamjotter` package concept.
- Load reconstructs project state from `.dreamjotter` without SwiftData.
- Missing required package files produce readable diagnostics.
- Invalid package files do not silently create false project state.
- Partial or interrupted writes require recovery behavior in later storage contracts.

Given/When/Then scenarios:

- Given a blank screenplay project, when saved, then a `.dreamjotter` package contains project metadata and screenplay data.
- Given a saved `.dreamjotter` package, when loaded, then project metadata, screenplay, characters, notes, inbox items, scene cards, snapshots, and presets load where present.
- Given a package is missing required metadata, when loaded, then loading fails or opens diagnostic recovery according to later contract rules.
- Given invalid JSON or malformed package files, when loaded, then diagnostics identify the failing package area.

Data model implications: Requires project package manifest, project metadata, document records, notes, characters, scene metadata, snapshots, and presets contracts.

Storage implications: `.dreamjotter` is canonical. SwiftData may only cache recents, indexes, or app metadata and must be rebuildable.

Edge cases:

- Missing manifest.
- Missing screenplay document.
- Invalid schema version.
- Permission denied.
- Duplicate internal IDs.
- External modification while open.

Future cross-platform notes: Package structure must be readable by later Linux, Windows, and Android implementations.

### M2-HEALTH-001: Script Health Report

User story: As a writer, I want helpful warnings about obvious script and project issues without the app blocking my writing.

Beginner behavior: Simple Mode shows plain-language advisory warnings such as no title, no scenes, empty scenes, inconsistent character spellings, or notes attached to missing scenes.

Pro behavior: Pro Mode may later expose rule categories, severity controls, custom rules, and exportable reports. Milestone 2 keeps Pro controls hidden or disabled.

Acceptance criteria:

- Health report can run on an empty screenplay.
- Health report can run on one-scene and multi-scene projects.
- Report findings include ID, severity, message, source reference if available, and suggested user action.
- Findings are advisory and do not block writing or saving.
- Findings can cover screenplay, characters, notes, package health, and snapshots where specified.

Given/When/Then scenarios:

- Given a blank project, when health report runs, then it reports no scenes or missing title as advisory findings.
- Given notes link to a deleted scene, when health report runs, then it reports orphaned notes.
- Given character names `JOSE` and `JOSÉ`, when health report runs, then it may report a possible spelling variant according to later rules.

Data model implications: Requires health finding records with stable rule IDs, severity, message, source reference, and optional suggested action.

Storage implications: Health report results are derived data and should not be canonical unless a later spec stores report history.

Edge cases:

- Intentionally unconventional scripts.
- False positives.
- Empty projects.
- Unicode spellings.
- Missing package files.

Future cross-platform notes: Health rules should operate on portable semantic data and avoid Apple-only text analysis dependencies in core.

### M2-TEMPLATES-001: Starter Templates

User story: As a beginner writer, I want starter templates that help me begin a blank screenplay, short film, or feature film without configuration.

Beginner behavior: Simple Mode offers blank screenplay, short film, and feature film templates with clear default project structures.

Pro behavior: Pro Mode may later expose custom templates and metadata defaults. Milestone 2 only reserves this as future work.

Acceptance criteria:

- Blank screenplay template creates valid project metadata and an empty screenplay document.
- Short film template creates valid project metadata and starter structure appropriate for a short screenplay without forcing content.
- Feature film template creates valid project metadata and starter structure appropriate for a feature screenplay without forcing content.
- Template-created projects use the same `.dreamjotter` storage contracts as other projects.

Given/When/Then scenarios:

- Given the user chooses blank screenplay, when the project is created, then the project has metadata and an empty screenplay.
- Given the user chooses short film template, when the project is created, then the project includes short-film defaults and remains editable as normal screenplay data.
- Given the user chooses feature film template, when the project is created, then the project includes feature-film defaults and remains editable as normal screenplay data.

Data model implications: Requires template metadata, template ID, created project metadata, and optional starter notes or scene placeholders.

Storage implications: Template output becomes canonical project data only after project creation. Template definitions may be bundled app resources later.

Edge cases:

- User cancels template creation.
- Template version changes.
- Template creates placeholder scenes the user deletes.
- Localized template names.

Future cross-platform notes: Template IDs and generated data should be platform-neutral; platform-specific template presentation is adapter behavior.

### M2-EXPORTPRESETS-001: Export Presets Foundation

User story: As a writer, I want common export choices ready without configuring every export manually.

Beginner behavior: Simple Mode exposes common presets such as draft PDF and Fountain export when export implementation exists.

Pro behavior: Pro Mode may later allow creating, duplicating, editing, and validating presets. Milestone 2 defines the foundation and keeps editing hidden or disabled.

Acceptance criteria:

- Export preset records can represent preset ID, title, export type, options, and availability.
- Built-in preset definitions can exist without becoming project-specific mutable data.
- Project-specific preset overrides are deferred unless specified by later contracts.
- Preset availability reflects whether the required export capability exists.

Given/When/Then scenarios:

- Given export presets are listed in Simple Mode, when PDF export is not implemented, then the draft PDF preset is disabled or marked unavailable.
- Given Fountain export intent exists, when Fountain preset is selected in future UI, then export settings map to the Fountain export request.
- Given Pro Mode is hidden, when viewing presets, then advanced preset editing is not visible.

Data model implications: Requires export preset definition records and later mapping to export request contracts.

Storage implications: Built-in presets can be app resources. Project-specific preset storage is deferred to later specs.

Edge cases:

- Missing export capability.
- Unsupported preset option.
- Renamed built-in preset.
- Preset conflicts with future custom fields.

Future cross-platform notes: Preset definitions should describe export intent, not Apple-only renderer choices.

### M2-MODES-001: Simple Mode

User story: As a beginner screenwriter, I want DreamJotter to show the writing and organization tools I need without exposing advanced production controls.

Beginner behavior: Simple Mode is the default mode. It exposes project creation, editor entry, dashboard, scene list/cards, character manager foundation, notes, idea inbox, search, snapshots, health report, starter templates, and basic export preset visibility.

Pro behavior: Not applicable for Simple Mode except that Pro features may exist in data as hidden or disabled capabilities.

Acceptance criteria:

- Simple Mode is the default product mode.
- Simple Mode hides or disables Pro-only features through Milestone 2.
- Simple Mode does not fork the `.dreamjotter` project format.
- Simple Mode can open projects containing future Pro metadata without losing it.

Given/When/Then scenarios:

- Given a new user opens DreamJotter, when no mode preference exists, then Simple Mode is active.
- Given Pro-only metadata exists in a project, when opened in Simple Mode, then the metadata is preserved but not surfaced as editable advanced controls.
- Given Simple Mode is active, when viewing project organization, then custom fields, routines, plugin settings, and advanced production controls are hidden or disabled.

Data model implications: Requires mode preference as app metadata or project preference to be specified later; project data should remain mode-independent.

Storage implications: Mode preference must not alter canonical screenplay semantics. If stored, it must not prevent cross-platform readers from accessing project data.

Edge cases:

- Project created in future Pro Mode opened in Simple Mode.
- Missing mode preference.
- User toggles mode once Pro Mode is enabled later.

Future cross-platform notes: Mode behavior is product policy and should not depend on Apple-only UI state.

### M2-PROMODE-001: Pro Mode Hidden/Disabled Foundation

User story: As a product maintainer, I want Pro Mode capabilities reserved without confusing MVP users or forcing advanced architecture too early.

Beginner behavior: Pro Mode controls are hidden or disabled in Milestone 2 Simple Mode unless explicitly needed for read-only preservation.

Pro behavior: Pro Mode is a planned capability surface for later milestones. In Milestone 2, it is not a full editable experience.

Acceptance criteria:

- Pro Mode-specific controls are not required for Milestone 2 MVP workflows.
- Pro Mode metadata, if encountered, is preserved rather than deleted.
- Plugin runtime, arbitrary code execution, routines, advanced production breakdown, custom fields editing, and full revision workflows remain deferred.
- No Milestone 2 feature depends on Pro Mode being enabled.

Given/When/Then scenarios:

- Given Simple Mode is active, when the user opens the app, then Pro-only controls are hidden or disabled.
- Given a future project contains Pro metadata, when loaded in Milestone 2-compatible behavior, then the metadata is preserved if the package can be read.
- Given a user attempts a Pro-only workflow, when Pro Mode is disabled, then the action is unavailable without changing project data.

Data model implications: Requires capability flags or mode policies later; Pro metadata preservation requires tolerant package loading.

Storage implications: Unknown or unsupported project sections should be preserved according to future package contracts where possible.

Edge cases:

- Unknown future Pro metadata.
- User expectation mismatch when controls are disabled.
- Imported project with custom fields.
- Future routines section present but unsupported.

Future cross-platform notes: Pro Mode gating should be represented as capabilities, not Apple-specific view logic.

## Milestone 2 Exit Criteria

Milestone 2 is ready for implementation only when future prompts have produced data contracts for project package layout, notes, characters, scene metadata, snapshots, templates, export presets, and health findings.

Milestone 2 is complete when future implementation can demonstrate:

- Creating a blank screenplay project.
- Creating projects from short film and feature film templates.
- Adding and viewing characters.
- Linking notes to scenes.
- Searching across script, notes, characters, and ideas.
- Creating snapshots.
- Saving and loading a `.dreamjotter` package.
- Reporting missing or invalid package files without data invention.
- Generating advisory script health findings.
- Hiding or disabling Pro features in Simple Mode.

## MVP Boundaries

Milestone 2 makes DreamJotter useful for real writing organization, but it does not include full professional workflow implementation. It does not include real-time collaboration, cloud sync, full plugin marketplace, arbitrary code execution, full FDX support, real AI provider integration, production scheduling, budgeting, or Windows/Linux/Android native app implementation.
