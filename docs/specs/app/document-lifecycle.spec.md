# App Document Lifecycle Spec

Status: specified
Milestone: M6
Registry IDs: APP-DOCUMENT-LIFECYCLE, APP-NEW-PROJECT, APP-OPEN-PROJECT, APP-SAVE, APP-SAVE-AS, APP-DIRTY-STATE, APP-EXPORT-FOUNTAIN, APP-UNSAVED-CHANGES-PROTECTION

## User Goal

A writer can trust DreamJotter with an active screenplay project: create it, edit it, save it, reopen it, export it, and avoid losing unsaved work.

## Scope

- New blank screenplay project creation.
- Opening existing `.dreamjotter` packages.
- Save and Save As routing.
- Dirty-state tracking for screenplay text, title, logline, synopsis, and notes.
- Dirty close and dirty replacement protection.
- Fountain export as a read-only operation.
- Testable document-lifecycle state transitions in app view models or app services.

## Non-Goals

- No iCloud, sync, collaboration, or remote storage.
- No SwiftData canonical project storage.
- No iOS or iPadOS target.
- No native document-based `DocumentGroup` migration in this milestone.
- No autosave unless separately specified.
- No TextKit editor replacement or advanced screenplay layout polish.
- No plugin runtime or real AI provider.

## Architecture Rules

- SwiftUI views stay thin and call view-model/app-service actions.
- Workflow state belongs in app view models or app services.
- Canonical project persistence remains the `.dreamjotter` package through existing storage code.
- The semantic screenplay model remains source of truth.
- TextKit and SwiftUI `TextEditor` are editor adapters only.
- Recent project metadata is app metadata, not canonical project data.

## User-Facing Behavior

### New Project

A new project opens with a default title, no package URL, editable metadata, blank screenplay text, and clean dirty state until the writer changes content.

### Open Project

Opening a valid `.dreamjotter` package loads project title, script text, scenes, notes, and metadata through the storage layer. Opening an invalid package shows a friendly error and keeps the current project safe.

### Save

Saving a project with a package URL writes to that package. Saving a project without a package URL routes to Save As. Successful saves clear dirty state; failed saves keep dirty state.

### Save As

Save As lets the user choose a `.dreamjotter` package destination. Success updates the current package URL and clears dirty state. Cancel preserves the current state. Existing packages require deliberate user confirmation from the platform save panel or equivalent workflow.

### Dirty State

Editing screenplay text, title, logline, synopsis, or editable notes marks the document dirty. Saving clears dirty state. Exporting Fountain does not mark dirty.

### Close Or Replace Protection

If the current project is dirty, opening another project, creating another project, returning to the library, closing the project, or closing the window must require confirmation or a testable confirmation-required state.

### Export Fountain

Fountain export uses existing parser/export behavior and writes an external `.fountain` file without mutating project data, clearing dirty state, or setting dirty state.

## Given/When/Then Examples

- Given the app has no open project, when the user creates a new project, then a blank screenplay project opens with a default title and no package URL.
- Given a new unsaved project, when the user edits script text, then the project is marked dirty.
- Given a new unsaved project, when the user saves, then the app requests a `.dreamjotter` destination.
- Given a valid `.dreamjotter` package, when the user opens it, then project title, script text, scenes, notes, and metadata are loaded.
- Given an invalid package, when the user opens it, then the app shows a friendly error and keeps the current project safe.
- Given the current project is dirty, when the user opens another project, then changes are not discarded without confirmation or an explicit safe state transition.
- Given a saved project with unsaved edits, when the user saves, then the package is updated and dirty state clears.
- Given a save failure, when the save operation fails, then the app shows a friendly error and dirty state remains true.
- Given an unsaved project, when the user invokes Save, then the workflow routes to Save As.
- Given an unsaved project, when the user completes Save As, then the project has a package URL and dirty state is false.
- Given Save As is canceled, then no package URL is assigned and dirty state remains unchanged.
- Given a clean project, when the user exports Fountain, then dirty state remains false.
- Given a dirty project, when the user attempts to close the window, then the app enters confirmation-required state before allowing data loss.
- Given confirmation is canceled, then the current project remains open and dirty.
- Given confirmation proceeds with save, then save must succeed before replacement.

## Edge Cases

- Package path is missing, moved, or permission-denied.
- Package version is unsupported.
- Save As destination already exists.
- Export destination is not writable.
- Dirty document is replaced by a recent-project open request.
- Parser diagnostics exist in the screenplay text but should not block save.

## Data Model Implications

`AppDocumentState` tracks current project identity, package URL, dirty state, current screenplay text, selected UI state, last saved timestamp, and pending confirmation state. Canonical screenplay data remains in portable project models.

## Storage Implications

Save/Open use the existing `.dreamjotter` package store. App document state may keep paths and timestamps, but it is not sufficient to reconstruct a user project without the package.

## Command Implications

Mac commands and toolbar actions must call the same view-model/app-service operations. They must not duplicate save/open/export business logic in views.

## UI Implications

The UI shows whether the document is unsaved or dirty, routes Save to Save As when needed, and presents friendly errors. Save/open panels are app-shell concerns and pass selected URLs into workflow actions.

## Testability Notes

View-model or app-service tests should cover state transitions without launching UI: dirty tracking, save routing, Save As cancel/success/failure, open valid/invalid package, export without dirtying, and dirty replacement confirmation.

## Platform Implications

Milestone 6 is macOS first. iPadOS/iOS document workflows are deferred until Mac ownership, save, and replacement behavior stabilizes.

## Security And Privacy Notes

All project data remains local unless the user chooses a location backed by external sync outside DreamJotter. Errors shown in UI should not expose stack traces or sensitive local paths unless needed for recovery.

## Open Questions

- Should Milestone 7 move to native document-based app behavior or continue with the custom package workflow?
- Should close protection present Save / Discard / Cancel in one dialog before autosave is specified?
- Should reopen-last-project be automatic or offered as a Project Library action?

## Executable Spec Plan

- New project starts unsaved.
- Editing script marks dirty.
- Editing title/logline/synopsis marks dirty.
- Save with existing URL clears dirty.
- Save without URL requires Save As.
- Save As success records package URL.
- Save As cancel preserves dirty state.
- Open valid package loads project.
- Open invalid package returns friendly error.
- Export Fountain does not mark dirty.
- Dirty project replacement requires confirmation.
- Failed save preserves dirty state.
