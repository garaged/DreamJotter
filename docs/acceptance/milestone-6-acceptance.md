# Milestone 6 Acceptance

## Purpose

This file defines acceptance examples for Milestone 6: Document Lifecycle and Writer Workflow Stabilization.

## Acceptance Fixture Set

### A-M6-NEW-001: New Project Starts Unsaved

Given the Project Library is visible, when the user creates a new project, then the project opens with a default title, no package URL, and no dirty edits yet.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-DIRTY-001: Edits Mark Dirty

Given a project is open, when the user edits screenplay text, title, logline, synopsis, or notes, then the document is marked dirty and visible UI indicates unsaved changes.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-SAVE-001: Save Existing Package

Given a saved project has a package URL and dirty edits, when the user chooses Save, then DreamJotter writes the package through `DreamJotterPackageStore`, keeps the package URL, records the recent project, and clears dirty state.

Traceability: M6-DOCUMENT-LIFECYCLE, STORAGE-DREAMJOTTER-PACKAGE-FORMAT.

### A-M6-SAVEAS-001: Save Unsaved Package

Given a project has no package URL, when the user chooses Save, then the app requests Save As. When the user chooses a `.dreamjotter` destination, then the app writes the package, updates the package URL, records the recent project, and clears dirty state.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-OPEN-001: Open Existing Package

Given the user chooses a `.dreamjotter` package, when the package is valid, then the app loads canonical project data through the existing storage layer and opens a clean document.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-OPEN-ERROR-001: Open Failure Is Readable

Given the user chooses an invalid package, when loading fails, then the app presents a human-readable error instead of raw diagnostics or stack traces.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-REPLACE-001: Dirty Replacement Requires Confirmation

Given the current project has unsaved changes, when the user tries to open another project, create another project, or return to the library, then the app records the pending replacement and requires confirmation before discarding changes.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-RECENTS-001: Recent Projects

Given the user successfully opens or saves a package, when they return to the Project Library, then the package appears in Recent Projects. Invalid recent entries are handled gracefully when opened.

Traceability: M6-DOCUMENT-LIFECYCLE.

### A-M6-EXPORT-001: Export Does Not Dirty Project

Given a clean saved project is open, when the user exports Fountain, then the export writes parser-backed Fountain text and the project remains clean.

Traceability: M6-DOCUMENT-LIFECYCLE, EDITOR-FOUNTAIN-SUPPORT.

### A-M6-COMMANDS-001: Basic Mac Commands

Given the app is running, when the user chooses New Project, Open, Save, Save As, or Export Fountain from commands or keyboard shortcuts, then the app routes to the same document lifecycle actions used by visible controls.

Traceability: M6-DOCUMENT-LIFECYCLE.

## Deferred Acceptance

- Autosave.
- Reopen last project on launch.
- Native document-based app behavior.
- Full Save / Discard / Cancel replacement dialog polish.
- UI automation tests.
