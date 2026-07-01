# Milestone 6: Document Lifecycle and Writer Workflow Stabilization

Status: implemented
Milestone: M6
Traceability ID: M6-DOCUMENT-LIFECYCLE

## Goal

Make DreamJotter behave like a reliable Mac writing app before adding more screenplay-editor polish, real AI providers, plugin runtime, iOS/iPadOS targets, or advanced Pro Mode UI.

Milestone 6 stabilizes project ownership, save state, recent projects, safe replacement, close protection, error presentation, and basic Mac commands. It does not change canonical storage: the `.dreamjotter` package remains the source of truth, and screenplay content remains semantic project data parsed through the portable core.

## Scope

- New blank screenplay project workflow.
- Opening existing `.dreamjotter` packages.
- Save and Save As workflow.
- Dirty-state tracking for script text, title, logline, synopsis, and notes.
- Dirty replacement, dirty close, and safe confirmation behavior.
- Recent project recording and Project Library display.
- Reopen-last-project behavior specified and deferred unless implemented deliberately.
- Fountain export as a read-only operation.
- Central app-error handling for document lifecycle failures.
- Basic macOS menu commands and keyboard shortcuts.
- View-model or app-service executable-spec plan for lifecycle behavior.

## Non-Goals

- No iCloud, cloud sync, or collaboration.
- No SwiftData canonical storage.
- No iPadOS or iOS target.
- No plugin runtime.
- No real AI provider.
- No TextKit replacement of the semantic model.
- No advanced pagination, revision-color editor polish, or production layout behavior.
- No fragile UI automation tests.
- No native document-based app migration unless separately specified.

## Architecture Rules

- macOS first.
- Apple-native app shell.
- Portable core always.
- SwiftUI views remain thin.
- View models and app services own workflow behavior.
- Canonical storage remains the local-first `.dreamjotter` package.
- TextKit remains an editor adapter, not the canonical screenplay model.
- The semantic screenplay model remains the source of truth.
- Recent-project storage is app metadata only.

## Feature Areas

### A. New Project

The user can create a blank screenplay project with a default title. The project starts without a package URL and is treated as unsaved until written to disk. Title edits are allowed and mark the project dirty once the user changes content.

### B. Open Project

The user can open a `.dreamjotter` package through the existing storage layer. Valid packages load project title, script text, scenes, notes, and metadata. Invalid packages produce friendly errors and preserve the current project.

### C. Save

Save writes to the current package URL when one exists. If no package URL exists, Save routes to Save As. Successful saves clear dirty state and failed saves preserve dirty state.

### D. Save As

Save As asks the user for a `.dreamjotter` package destination, writes through the existing storage layer, updates the current package URL, records the project as recent, and clears dirty state on success. Cancel and failure preserve the previous safe state.

### E. Dirty State

Editing script text, title, logline, synopsis, or editable notes marks the project dirty. Saving clears dirty state. Exporting does not mark dirty. The UI must visibly indicate unsaved changes.

### F. Recent Projects

The app records successfully opened and saved packages as recent projects. Recents may survive relaunch through app metadata if practical. Missing, invalid, duplicate, or permission-denied entries are handled gracefully and never become canonical storage.

### G. Reopen Last Project

The app may reopen the last project on launch if safe. If not implemented in Milestone 6, the behavior remains deferred: launch must not block and must fall back to Project Library when the last package is missing or invalid.

### H. Export Fountain

Fountain export uses existing parser/export/core logic, produces a `.fountain` artifact, and does not mutate the project or dirty state.

### I. App Error Handling

Document lifecycle errors map to app-facing errors with user messages, optional technical details, optional recovery suggestions, source operations, and timestamps. UI messages avoid raw stack traces.

### J. Mac Menu Commands

The app wires New Project, Open, Save, Save As, and Export Fountain commands where practical. Cmd+N, Cmd+O, Cmd+S, and Shift+Cmd+S should route through the same app workflow actions as visible controls.

### K. Close Or Replace Protection

Replacing the current project, opening another project, returning to the library, or closing the app window while dirty must not silently discard changes. The app must either present confirmation or enter a testable confirmation-required state.

## Data Contracts

- `docs/data-contracts/app-document-state.md`
- `docs/data-contracts/recent-projects.md`
- `docs/data-contracts/app-error.md`

## Related Specs

- `docs/specs/app/document-lifecycle.spec.md`
- `docs/specs/app/recent-projects.spec.md`
- `docs/specs/app/app-error-handling.spec.md`
- `docs/specs/app/mac-menu-commands.spec.md`

## Related ADR

- `docs/adr/0004-macos-document-lifecycle-before-ios.md`

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
- Recent project recorded after open.
- Recent project recorded after Save As.
- Duplicate recent projects collapse to one entry.
- Export Fountain does not mark dirty.
- Dirty project replacement requires confirmation.
- Failed save preserves dirty state.
- Storage errors map to `AppError`.

## Deferred Work

- Native document-based lifecycle with `DocumentGroup` or a custom document controller.
- Autosave and snapshot policy for unsaved packages.
- Automatic or prompted reopen-last-project-on-launch behavior.
- Save / Discard / Cancel dialog polish for dirty close and replacement.
- Recent-project availability badges and repair flow.
- iPadOS/iOS document workflows.
