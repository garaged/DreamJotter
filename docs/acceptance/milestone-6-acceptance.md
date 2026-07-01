# Milestone 6 Acceptance

## Purpose

This file defines acceptance criteria for Milestone 6: Document Lifecycle and Writer Workflow Stabilization.

## A. New Project

### A-M6-NEW-001: New Blank Project Opens

Given the app has no open project, when the user creates a new project, then a blank screenplay project is opened with a default title.

Traceability: APP-NEW-PROJECT, APP-DOCUMENT-LIFECYCLE.

### A-M6-NEW-002: New Project Uses Portable Models

Given a new project is created, when it opens in the Mac app, then it uses existing portable project and screenplay models and does not require SwiftData.

Traceability: APP-NEW-PROJECT.

### A-M6-NEW-003: Unsaved New Project Routes Save To Save As

Given a new unsaved project, when the user saves, then the app must request a `.dreamjotter` destination.

Traceability: APP-NEW-PROJECT, APP-SAVE, APP-SAVE-AS.

## B. Open Project

### A-M6-OPEN-001: Valid Package Loads

Given a valid `.dreamjotter` package, when the user opens it, then project title, script text, scenes, notes, and metadata are loaded.

Traceability: APP-OPEN-PROJECT.

### A-M6-OPEN-002: Invalid Package Shows Friendly Error

Given an invalid package, when the user opens it, then the app shows a friendly error and keeps the current project safe.

Traceability: APP-OPEN-PROJECT, APP-ERROR-HANDLING.

### A-M6-OPEN-003: Dirty Open Requires Safe Transition

Given the current project is dirty, when the user opens another project, then the app must not discard changes without confirmation or an explicit safe state transition.

Traceability: APP-OPEN-PROJECT, APP-UNSAVED-CHANGES-PROTECTION.

## C. Save

### A-M6-SAVE-001: Save Existing Package Clears Dirty

Given a saved project with unsaved edits, when the user saves, then the package is updated and dirty state clears.

Traceability: APP-SAVE, APP-DIRTY-STATE.

### A-M6-SAVE-002: Save Failure Preserves Dirty

Given a save failure, when the save operation fails, then the app shows a friendly error and dirty state remains true.

Traceability: APP-SAVE, APP-ERROR-HANDLING.

### A-M6-SAVE-003: Unsaved Save Routes To Save As

Given an unsaved project, when the user invokes Save, then the workflow routes to Save As.

Traceability: APP-SAVE, APP-SAVE-AS.

## D. Save As

### A-M6-SAVEAS-001: Save As Assigns Package URL

Given an unsaved project, when the user completes Save As, then the project has a package URL and dirty state is false.

Traceability: APP-SAVE-AS.

### A-M6-SAVEAS-002: Save As Cancel Preserves State

Given Save As is canceled, then no package URL is assigned and dirty state remains unchanged.

Traceability: APP-SAVE-AS.

### A-M6-SAVEAS-003: Save As Failure Is Friendly

Given Save As fails, then the app shows a friendly error.

Traceability: APP-SAVE-AS, APP-ERROR-HANDLING.

### A-M6-SAVEAS-004: Existing Package Requires Deliberate Choice

Given a destination already exists, when the user saves as that package, then overwrite or replacement only occurs after a deliberate platform or app confirmation.

Traceability: APP-SAVE-AS, APP-UNSAVED-CHANGES-PROTECTION.

## E. Dirty State

### A-M6-DIRTY-001: Script Edit Marks Dirty

Given a clean project, when script text changes, then dirty state becomes true.

Traceability: APP-DIRTY-STATE.

### A-M6-DIRTY-002: Metadata Edit Marks Dirty

Given a clean project, when the title, logline, synopsis, or editable note changes, then dirty state becomes true.

Traceability: APP-DIRTY-STATE.

### A-M6-DIRTY-003: Save Clears Dirty

Given a dirty project, when save succeeds, then dirty state becomes false.

Traceability: APP-DIRTY-STATE, APP-SAVE.

### A-M6-DIRTY-004: Export Does Not Dirty

Given a clean project, when the user exports Fountain, then dirty state remains false.

Traceability: APP-DIRTY-STATE, APP-EXPORT-FOUNTAIN.

## F. Recent Projects

### A-M6-RECENTS-001: Open Records Recent Project

Given a project is opened, when open succeeds, then it appears in recent projects.

Traceability: APP-RECENT-PROJECTS.

### A-M6-RECENTS-002: Save As Records Recent Project

Given a project is saved as a package, when Save As succeeds, then it appears in recent projects.

Traceability: APP-RECENT-PROJECTS, APP-SAVE-AS.

### A-M6-RECENTS-003: Missing Recent Is Friendly

Given a recent project path no longer exists, when selected, then the app shows a friendly error and does not crash.

Traceability: APP-RECENT-PROJECTS, APP-ERROR-HANDLING.

### A-M6-RECENTS-004: Duplicate Recents Collapse

Given duplicate recent paths, then the app keeps a single latest entry.

Traceability: APP-RECENT-PROJECTS.

## G. Reopen Last Project

### A-M6-REOPEN-001: Valid Last Project May Reopen

Given a valid last opened project exists, when the app launches, then it may offer or perform reopen according to the chosen behavior.

Traceability: APP-RECENT-PROJECTS.

### A-M6-REOPEN-002: Missing Last Project Falls Back To Library

Given the last opened project is missing, when the app launches, then the app shows Project Library normally.

Traceability: APP-RECENT-PROJECTS, APP-ERROR-HANDLING.

Implementation status: deferred unless explicitly implemented after this spec baseline.

## H. Export Fountain

### A-M6-EXPORT-001: Fountain File Is Produced

Given an open project, when the user exports Fountain, then a Fountain file is produced.

Traceability: APP-EXPORT-FOUNTAIN.

### A-M6-EXPORT-002: Export Failure Is Friendly

Given export fails, then the app shows a friendly error.

Traceability: APP-EXPORT-FOUNTAIN, APP-ERROR-HANDLING.

### A-M6-EXPORT-003: Export Does Not Change Dirty State

Given a clean project, when export succeeds, then dirty state remains false.

Traceability: APP-EXPORT-FOUNTAIN, APP-DIRTY-STATE.

## I. App Error Handling

### A-M6-ERROR-001: Storage Errors Become App Errors

Given a storage error, when surfaced to UI, then it maps to a human-readable app error.

Traceability: APP-ERROR-HANDLING.

### A-M6-ERROR-002: Unknown Errors Are Safe

Given an unknown error, when surfaced to UI, then the app shows a safe generic message.

Traceability: APP-ERROR-HANDLING.

### A-M6-ERROR-003: Errors Preserve Project State

Given an error occurs, then the current project state is not corrupted.

Traceability: APP-ERROR-HANDLING, APP-DOCUMENT-LIFECYCLE.

## J. Mac Menu Commands

### A-M6-COMMANDS-001: Cmd+N Starts New Project

Given the app is running, when Cmd+N is used, then New Project workflow starts.

Traceability: APP-MENU-COMMANDS, APP-NEW-PROJECT.

### A-M6-COMMANDS-002: Cmd+O Starts Open

Given the app is running, when Cmd+O is used, then Open Project workflow starts.

Traceability: APP-MENU-COMMANDS, APP-OPEN-PROJECT.

### A-M6-COMMANDS-003: Cmd+S Saves Dirty Saved Project

Given a dirty saved project, when Cmd+S is used, then Save workflow runs.

Traceability: APP-MENU-COMMANDS, APP-SAVE.

### A-M6-COMMANDS-004: Cmd+S On Unsaved Requires Save As

Given an unsaved project, when Cmd+S is used, then Save As workflow is required.

Traceability: APP-MENU-COMMANDS, APP-SAVE-AS.

## K. Close Or Replace Protection

### A-M6-PROTECT-001: Dirty Replacement Requires Confirmation

Given a dirty project, when the user attempts to open another project, then the app enters a confirmation-required state.

Traceability: APP-UNSAVED-CHANGES-PROTECTION.

### A-M6-PROTECT-002: Cancel Keeps Dirty Project

Given confirmation is canceled, then the current project remains open and dirty.

Traceability: APP-UNSAVED-CHANGES-PROTECTION.

### A-M6-PROTECT-003: Discard Requires Explicit Decision

Given confirmation proceeds without save, then the app may replace the project only through an explicit user decision.

Traceability: APP-UNSAVED-CHANGES-PROTECTION.

### A-M6-PROTECT-004: Save Before Replace Must Succeed

Given confirmation proceeds with save, then save must succeed before replacement.

Traceability: APP-UNSAVED-CHANGES-PROTECTION, APP-SAVE.

### A-M6-PROTECT-005: Dirty Window Close Requires Confirmation

Given the current project has unsaved changes, when the user closes the macOS app window, then the app blocks immediate close and presents an unsaved-changes confirmation before allowing discard-and-close.

Traceability: APP-UNSAVED-CHANGES-PROTECTION.

## Deferred Acceptance

- Native document-based app behavior.
- Autosave.
- Reopen last project implementation, unless deliberately selected after this spec baseline.
- Full Save / Discard / Cancel dirty-state dialog polish.
- UI automation tests.
