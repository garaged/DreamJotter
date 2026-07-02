# Milestone 8 Acceptance

## Purpose

This file defines acceptance criteria for Milestone 8: Character, Location, Notes, and Scene Workflow v1.

## A. Character Profile Workflow

### A-M8-CHARACTER-001: Character Profile Drives Autocomplete

Given the user creates a character named `ELENA`, when they type `ELE` in a character line, then `ELENA` is suggested.

Traceability: CHARACTER-PROFILE-WORKFLOW.

### A-M8-CHARACTER-002: Editing Marks Dirty

Given a character profile exists, when the user edits the profile, then the project becomes dirty.

Traceability: CHARACTER-PROFILE-WORKFLOW, M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-CHARACTER-003: Save Reopen Preserves Profiles

Given the project is saved and reopened, then character profiles are preserved.

Traceability: CHARACTER-PROFILE-WORKFLOW.

### A-M8-CHARACTER-004: Appearances Are Derived

Given a character appears in the script, then the character profile can show appearances.

Traceability: CHARACTER-PROFILE-WORKFLOW.

### A-M8-CHARACTER-005: Archived Profile Is Not Primary Suggestion

Given a character is archived, then it is not the primary autocomplete suggestion unless explicitly included.

Traceability: CHARACTER-PROFILE-WORKFLOW.

## B. Detected Character Workflow

Implementation status: core behavior, app view-model actions, Characters pane presentation, and save/reopen behavior are executable-spec verified for this slice.

### A-M8-DETECTED-CHARACTER-001: Unresolved Detected Character Appears

Given the script contains `SOFIA` as a character cue and no profile exists, then `SOFIA` appears as a detected character.

Traceability: DETECTED-CHARACTER-RESOLUTION.

### A-M8-DETECTED-CHARACTER-002: Convert Detection To Profile

Given the user converts detected `SOFIA`, then a project character profile named `SOFIA` is created.

Traceability: DETECTED-CHARACTER-RESOLUTION, CHARACTER-PROFILE-WORKFLOW.

### A-M8-DETECTED-CHARACTER-003: Ignore Generic Name

Given the user ignores detected `MAN`, then `MAN` no longer appears as unresolved.

Traceability: DETECTED-CHARACTER-RESOLUTION.

### A-M8-DETECTED-CHARACTER-004: Existing Profile Resolves Detection

Given the script contains `SOFIA` and a character profile `SOFIA` already exists, then it is not shown as unresolved.

Traceability: DETECTED-CHARACTER-RESOLUTION.

### A-M8-DETECTED-CHARACTER-005: Malformed Text Safe

Given malformed uppercase text, detection does not crash.

Traceability: DETECTED-CHARACTER-RESOLUTION.

### A-M8-DETECTED-CHARACTER-006: Unicode Preserved

Given Spanish or Unicode character names, detection preserves text.

Traceability: DETECTED-CHARACTER-RESOLUTION.

## C. Location Profile Workflow

### A-M8-LOCATION-001: Location Profile Drives Autocomplete

Given the user creates location `COFFEE SHOP`, when they type `INT. COF`, then `COFFEE SHOP` is suggested.

Traceability: LOCATION-PROFILE-WORKFLOW.

### A-M8-LOCATION-002: Editing Location Marks Dirty

Given the user edits a location profile, then the project becomes dirty.

Traceability: LOCATION-PROFILE-WORKFLOW, M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-LOCATION-003: Save Reopen Preserves Locations

Given the project is saved and reopened, then location profiles are preserved.

Traceability: LOCATION-PROFILE-WORKFLOW.

### A-M8-LOCATION-004: Scene Appearances Derived

Given a location appears in scene headings, then its profile can show scene appearances.

Traceability: LOCATION-PROFILE-WORKFLOW.

## D. Detected Location Workflow

### A-M8-DETECTED-LOCATION-001: Location Detected From Heading

Given the script contains `INT. COFFEE SHOP - DAY`, then `COFFEE SHOP` is detected as a location.

Traceability: DETECTED-LOCATION-RESOLUTION.

### A-M8-DETECTED-LOCATION-002: Unresolved Location Appears

Given no location profile exists for `COFFEE SHOP`, then it appears as unresolved.

Traceability: DETECTED-LOCATION-RESOLUTION.

### A-M8-DETECTED-LOCATION-003: Convert Location Detection

Given the user converts detected `COFFEE SHOP`, then a location profile is created.

Traceability: DETECTED-LOCATION-RESOLUTION, LOCATION-PROFILE-WORKFLOW.

### A-M8-DETECTED-LOCATION-004: Ignore Location Detection

Given the user ignores detected `COFFEE SHOP`, then it no longer appears as unresolved.

Traceability: DETECTED-LOCATION-RESOLUTION.

### A-M8-DETECTED-LOCATION-005: Duplicate Locations Collapse

Given duplicate scene headings use the same location, then only one detected location entry appears.

Traceability: DETECTED-LOCATION-RESOLUTION.

## E. Scene Cards Workflow

### A-M8-SCENE-001: Scene Cards In Screenplay Order

Given a multi-scene script, when the user opens the Scenes pane, then scene cards appear in screenplay order.

Traceability: SCENE-CARD-WORKFLOW.

### A-M8-SCENE-002: Scene Card Navigates Editor

Given the user clicks a scene card, then the editor navigates to that scene.

Traceability: SCENE-CARD-WORKFLOW.

### A-M8-SCENE-003: Status Update Marks Dirty

Given the user changes scene status, then the project becomes dirty.

Traceability: SCENE-CARD-WORKFLOW, M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-SCENE-004: User Metadata Persists

Given the project is saved and reopened, then user-authored scene card metadata is preserved.

Traceability: SCENE-CARD-WORKFLOW.

### A-M8-SCENE-005: Heading Change Preserves Metadata Where Possible

Given a scene heading changes, then derived scene card heading updates without losing user metadata where possible.

Traceability: SCENE-CARD-WORKFLOW.

## F. Notes Workflow

### A-M8-NOTES-001: Project Note Marks Dirty

Given the user adds a project note, then the project becomes dirty.

Traceability: NOTES-WORKFLOW, M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-NOTES-002: Scene Note Links To Scene

Given the user adds a scene note, then it appears linked to that scene.

Traceability: NOTES-WORKFLOW.

### A-M8-NOTES-003: Script TODO Detected

Given the script contains `[[TODO: improve this dialogue]]`, then the TODO appears in notes/TODO workflow.

Traceability: SCRIPT-TODO-DETECTION, NOTES-WORKFLOW.

### A-M8-NOTES-004: Resolved Notes Hide By Default

Given a note is resolved, then it no longer appears in open notes by default.

Traceability: NOTES-WORKFLOW.

### A-M8-NOTES-005: Manual Notes Persist

Given the project is saved and reopened, then manual notes are preserved.

Traceability: NOTES-WORKFLOW.

### A-M8-NOTES-006: Removed TODO Updates Derived Behavior

Given parsed TODO syntax is removed from script, then derived TODO note behavior is updated according to the chosen rule.

Traceability: SCRIPT-TODO-DETECTION.

## G. Dashboard Integration

### A-M8-DASHBOARD-001: Scene Count

Given a project with script text, when dashboard opens, then it shows scene count.

Traceability: DASHBOARD-WORKSPACE-SUMMARY.

### A-M8-DASHBOARD-002: Unresolved Character Count

Given unresolved detected characters exist, then dashboard shows the count.

Traceability: DASHBOARD-WORKSPACE-SUMMARY.

### A-M8-DASHBOARD-003: Unresolved Location Count

Given unresolved detected locations exist, then dashboard shows the count.

Traceability: DASHBOARD-WORKSPACE-SUMMARY.

### A-M8-DASHBOARD-004: Open Note Count

Given open notes exist, then dashboard shows open note count.

Traceability: DASHBOARD-WORKSPACE-SUMMARY.

### A-M8-DASHBOARD-005: Saved Information

Given project is saved, then dashboard can show last saved information if available.

Traceability: DASHBOARD-WORKSPACE-SUMMARY.

## H. Search Integration

### A-M8-SEARCH-001: Character Search

Given a character profile named `ELENA`, when user searches `ELE`, then the character profile appears.

Traceability: PROJECT-OBJECT-SEARCH-INTEGRATION.

### A-M8-SEARCH-002: Location Search

Given a location profile named `COFFEE SHOP`, when user searches `coffee`, then the location appears.

Traceability: PROJECT-OBJECT-SEARCH-INTEGRATION.

### A-M8-SEARCH-003: Note Search

Given a note contains `rewrite`, when user searches `rewrite`, then the note appears.

Traceability: PROJECT-OBJECT-SEARCH-INTEGRATION.

## I. Save/Open/Export Preservation

### A-M8-PRESERVE-001: Metadata Persists

Given character, location, note, or scene metadata changes, when saved and reopened, then the data is preserved.

Traceability: M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-PRESERVE-002: Fountain Export Remains Screenplay Text

Given M8 metadata exists, when Fountain export runs, then screenplay text exports correctly.

Traceability: M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-PRESERVE-003: Export Does Not Dirty Project

Given export runs, then project dirty state is not changed by export alone.

Traceability: M8-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M8-PRESERVE-004: TextKit And TextEditor Continue To Save

Given TextKit and TextEditor fallback are used, both still preserve save/reopen behavior.

Traceability: M8-DOCUMENT-WORKFLOW-PRESERVATION.
