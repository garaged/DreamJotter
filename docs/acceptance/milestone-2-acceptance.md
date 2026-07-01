# Milestone 2 Acceptance

## Purpose

This file defines acceptance examples for Milestone 2: Real MVP Writer Organization. These examples are covered by portable-core executable specs and do not require production app UI, TextKit integration, an Xcode project, cloud sync, real AI providers, routines, plugins, or full PDF rendering.

## Acceptance Fixture Set

### A-M2-BLANK-PROJECT-001: Creating A Blank Screenplay Project

Input:

```yaml
action: create_project
template: blank-screenplay
title: Untitled Screenplay
mode: Simple Mode
```

Expected result:

- A valid project model is created.
- Project metadata includes ID, title, schema version, created date, modified date, and primary screenplay reference.
- Primary screenplay document contains zero screenplay elements.
- Project can be represented as a future `.dreamjotter` package.
- Simple Mode is active by default.

Given/When/Then:

- Given the user chooses blank screenplay, when the project is created, then a valid empty screenplay project exists.
- Given the blank project exists, when the scene list is generated, then it returns no scenes.
- Given the blank project exists, when health report runs, then missing title or no-scene findings are advisory.

Traceability: M2-DASHBOARD-001, M2-TEMPLATES-001, M2-STORAGE-001, M2-MODES-001, M2-HEALTH-001.

### A-M2-SHORT-FILM-TEMPLATE-001: Creating From Short Film Template

Input:

```yaml
action: create_project
template: short-film
title: Rain On Set
mode: Simple Mode
```

Expected result:

- A valid project model is created from the short film template.
- Template metadata records the template ID and version where specified.
- Starter structure is represented as semantic project data or starter notes, not wizard-only state.
- User can delete or edit any starter content.

Given/When/Then:

- Given the user chooses short film template, when the project is created, then short-film defaults are applied to canonical project data.
- Given the project was created from a template, when saved, then it saves as a normal `.dreamjotter` package.

Traceability: M2-TEMPLATES-001, M2-DASHBOARD-001, M2-STORAGE-001.

### A-M2-FEATURE-FILM-TEMPLATE-001: Creating From Feature Film Template

Input:

```yaml
action: create_project
template: feature-film
title: The Long Night
mode: Simple Mode
```

Expected result:

- A valid project model is created from the feature film template.
- Template defaults remain editable and do not lock the screenplay structure.
- The resulting project uses the same storage contracts as a blank project.

Given/When/Then:

- Given the user chooses feature film template, when the project is created, then feature-film defaults are applied without requiring Pro Mode.
- Given the feature project is opened later, when loaded, then it behaves as a normal screenplay project.

Traceability: M2-TEMPLATES-001, M2-DASHBOARD-001, M2-STORAGE-001, M2-MODES-001.

### A-M2-CHARACTERS-001: Adding Characters

Input:

```yaml
action: add_character
name: NIÑA
note: Carries the opening mystery.
```

Expected result:

- Character record is stored in project data.
- Unicode name is preserved.
- Character appears in character manager results.
- Character is searchable by name and note text.

Given/When/Then:

- Given a blank project, when the user adds character `NIÑA`, then a character record is created with stable ID and display name.
- Given the character has a note, when search matches the note text, then the character result appears.
- Given the screenplay later includes `NIÑA` as a cue, when character manager derives records, then the manually created character and detected cue resolve according to normalization rules.

Traceability: M2-CHARACTER-001, M2-SEARCH-001.

### A-M2-LINK-NOTES-SCENES-001: Linking Notes To Scenes

Input:

```text
INT. KITCHEN - NIGHT

The lights flicker.
```

Note:

```yaml
body: Make this scene feel colder.
linked_to: scene:INT. KITCHEN - NIGHT
```

Expected result:

- Scene is represented as a semantic scene heading.
- Note record is stored in project data.
- Note link references the scene or scene element ID.
- Scene-linked note query returns the note.
- Search can find the note body and scene heading.

Given/When/Then:

- Given a scene exists, when the user links a note to it, then the note remains attached after save/load.
- Given the linked scene is deleted, when notes load, then the note remains recoverable and reports a missing target.

Traceability: M2-NOTES-001, M2-SCENECARDS-001, M2-SEARCH-001, M2-STORAGE-001.

### A-M2-SEARCH-001: Searching Across Script, Notes, Characters, And Ideas

Input project content:

```yaml
script: "EXT. PARK - DAY\n\nRain falls on empty benches."
character:
  name: MARIA
  note: Searches for her brother.
note:
  body: Rain motif should return in act three.
inbox:
  body: Add a park bench clue.
query: rain
```

Expected result:

- Search returns screenplay match for `Rain falls on empty benches.`
- Search returns note match for `Rain motif should return in act three.`
- Search may return character note match if query matches character notes.
- Search result records include source type, source ID, preview, and navigation target where available.

Given/When/Then:

- Given script, notes, characters, and inbox content exist, when a query matches multiple sources, then results are grouped or labeled by source type.
- Given a query differs only by case, when search runs, then matching behavior follows the later specified case policy and does not corrupt source text.

Traceability: M2-SEARCH-001, M2-NOTES-001, M2-CHARACTER-001, M2-INBOX-001.

### A-M2-SNAPSHOT-001: Creating Snapshots

Input:

```yaml
action: create_snapshot
name: Before rewriting opening
project_contains:
  screenplay: true
  notes: true
  characters: true
```

Expected result:

- Snapshot record is created with ID, name, schema version, and created date.
- Snapshot captures canonical project content according to future snapshot contract.
- Snapshot creation is available before destructive or major automated actions.

Given/When/Then:

- Given a project has script, notes, and characters, when a snapshot is created, then the snapshot can be listed by name and creation date.
- Given a destructive action is requested later, when the action requires recovery, then a snapshot requirement can be enforced by command policy.

Traceability: M2-SNAPSHOTS-001, M2-STORAGE-001, R-007.

### A-M2-LOAD-PACKAGE-001: Loading A Saved `.dreamjotter` Package

Input package concept:

```text
MyMovie.dreamjotter/
  manifest.json
  project.json
  screenplay.json
  characters.json
  notes.json
  inbox.json
  scene-cards.json
  snapshots/
```

Expected result:

- Package loader reads manifest and project metadata.
- Screenplay, character, note, inbox, scene-card, and snapshot sections load where present.
- SwiftData is not required to reconstruct project state.
- Unknown compatible sections are preserved according to future package contract.

Given/When/Then:

- Given a saved `.dreamjotter` package, when loaded, then canonical project data is reconstructed from package contents.
- Given app cache is missing, when the package loads, then project state still loads from `.dreamjotter` canonical data.

Traceability: M2-STORAGE-001, ADR-0002, PRD-STORAGE-001.

### A-M2-INVALID-PACKAGE-001: Handling Missing Or Invalid Package Files

Input package concept:

```text
Broken.dreamjotter/
  project.json
  screenplay.json   # malformed JSON
```

Expected result:

- Missing manifest is reported as a package diagnostic.
- Malformed screenplay file is reported as a package diagnostic.
- Loader does not silently invent screenplay content.
- Recoverable sections may be exposed only through explicit recovery behavior specified later.

Given/When/Then:

- Given a `.dreamjotter` package is missing required files, when loaded, then diagnostics identify missing files.
- Given a package file is malformed, when loaded, then diagnostics identify the failing file or section.
- Given package load fails, when the dashboard shows the project, then the project is not treated as successfully opened.

Traceability: M2-STORAGE-001, M2-DASHBOARD-001, M2-HEALTH-001.

### A-M2-HEALTH-REPORT-001: Generating A Script Health Report

Input project content:

```yaml
title: ""
script: ""
notes:
  - body: Attached to missing scene.
    linked_to: scene:missing-scene-id
characters:
  - JOSE
  - JOSÉ
```

Expected result:

- Report contains advisory finding for missing title.
- Report contains advisory finding for no scenes or empty screenplay.
- Report contains finding for note linked to missing scene.
- Report may contain possible character spelling variant finding for `JOSE` and `JOSÉ`.
- Findings do not block saving or writing.

Given/When/Then:

- Given a blank or incomplete project, when health report runs, then advisory findings are generated with stable rule IDs.
- Given findings exist, when displayed in future UI, then each finding has severity, message, and source reference where available.

Traceability: M2-HEALTH-001, M2-NOTES-001, M2-CHARACTER-001.

### A-M2-SIMPLE-MODE-001: Hiding Pro Features In Simple Mode

Input:

```yaml
mode: Simple Mode
project_contains:
  custom_fields: true
  routines: true
  advanced_export_presets: true
```

Expected result:

- Simple Mode is active by default.
- Custom field editing is hidden or disabled.
- Routine execution/configuration is hidden or disabled.
- Plugin configuration is unavailable.
- Advanced export preset editing is hidden or disabled.
- Existing unsupported Pro metadata is preserved where package contracts allow.

Given/When/Then:

- Given Simple Mode is active, when the organization features are shown, then Pro-only controls are hidden or disabled.
- Given a project contains future Pro metadata, when loaded in Simple Mode, then that metadata is not deleted.
- Given a user attempts a disabled Pro action, when the action is unavailable, then no project data changes.

Traceability: M2-MODES-001, M2-PROMODE-001, ADR-0003, PRD-CUSTOMFIELDS-001, PRD-ROUTINES-001.

### A-M2-EXPORT-PRESETS-001: Export Presets Foundation

Input:

```yaml
mode: Simple Mode
presets:
  - id: draft-pdf
    export_type: pdf
    available: false
  - id: fountain
    export_type: fountain
    available: true
```

Expected result:

- Presets can be listed with availability.
- Unavailable export capabilities are disabled rather than failing late.
- Preset selection maps to export intent where an export capability exists.
- Advanced preset editing remains hidden or disabled in Simple Mode.

Given/When/Then:

- Given PDF rendering is not implemented, when presets are listed, then draft PDF is disabled or marked unavailable.
- Given Fountain export intent exists, when the Fountain preset is selected in future behavior, then its settings can map to an export request.

Traceability: M2-EXPORTPRESETS-001, PRD-PDF-001, PRD-FOUNTAIN-001.

## Cross-Cutting Acceptance Rules

- All canonical project data must be recoverable from `.dreamjotter` package contents without SwiftData.
- Simple Mode must be the default and must not fork project format.
- Pro Mode features through Milestone 2 are hidden, disabled, or preserved read-only where encountered.
- Search, health reports, dashboard summaries, and indexes are derived from canonical project data.
- Notes, characters, inbox items, scene cards, snapshots, and templates are implemented as portable core records and may need expanded contracts as later milestones add behavior.
- Destructive or major automated actions require snapshot policy before execution.
- Missing or malformed package files must produce diagnostics rather than invented state.

## Deferred Acceptance

The following are explicitly deferred beyond Milestone 2 acceptance:

- Full production UI implementation.
- Full Pro Mode editing experience.
- Routines v1 execution.
- Plugin runtime or marketplace.
- Real AI provider integration.
- Cloud sync.
- Real-time collaboration.
- Full PDF rendering and pagination.
- Full FDX support.
- Production scheduling or budgeting.
- Native Windows/Linux/Android apps.
