# Milestone 6: Document Lifecycle and Writer Workflow Stabilization

Status: implemented
Milestone: M6
Traceability ID: M6-DOCUMENT-LIFECYCLE

## Goal

Make DreamJotter behave like a reliable Mac writing app around project ownership, save state, recent projects, replacement protection, and basic app commands.

Milestone 6 does not change canonical storage. The `.dreamjotter` package remains the project source of truth, and the screenplay remains semantic project data derived through portable core parsing.

## Scope

- New projects start unsaved until saved to a package URL.
- Editing screenplay text, title, logline, synopsis, or notes marks the document dirty.
- Saving to an existing package clears dirty state.
- Saving an untitled package requests Save As.
- Save As updates the current package URL and clears dirty state.
- Opening a package loads through `DreamJotterPackageStore`.
- Failed opens produce human-readable errors.
- Dirty replacement requests are centralized and require confirmation before discarding changes.
- Closing the macOS window with dirty edits requires confirmation before the window closes.
- Recent project URLs are recorded after successful open/save and displayed in the Project Library.
- Basic Mac commands are wired for New Project, Open, Save, Save As, and Export Fountain.
- Fountain export remains read-only and does not dirty the document.

## Non-Goals

- No iCloud or sync.
- No SwiftData canonical storage.
- No document-based `DocumentGroup` migration yet.
- No autosave.
- No reopen-last-project-on-launch behavior.
- No fragile UI automation tests.
- No iPadOS or iOS implementation.
- No plugin runtime or real AI provider.

## Architecture Rules

- SwiftUI views call app view-model operations and present panels or alerts.
- `ProjectDocumentViewModel` owns dirty state for editor-facing project mutations.
- `MacAppViewModel` owns document lifecycle decisions, recent-project records, save routing, and dirty replacement state.
- File persistence continues through `DreamJotterPackageStore`.
- Export continues through parser-backed Fountain text.
- Core modules remain free of SwiftUI, AppKit, UIKit, SwiftData, and CloudKit.

## Acceptance Summary

- New project opens with no package URL and clean state.
- Editing marks the document dirty.
- Save without a package URL requests Save As.
- Save As writes `.dreamjotter`, records the recent project, updates package URL, and clears dirty state.
- Opening a package restores clean state and records the recent project.
- Invalid recent packages fail with readable errors and can be removed from the recent list.
- Opening, closing, or creating over dirty state requires a discard confirmation path.
- Closing the app window with dirty state shows the same unsaved-change warning before allowing close.
- Export Fountain writes an export artifact without dirtying the project.
- Menu commands and keyboard shortcuts call the same app actions as toolbar/library controls.

## Deferred Polish

- Native document-based lifecycle with `DocumentGroup` or a custom document controller.
- Autosave and snapshot policy for unsaved packages.
- Reopen last project on launch.
- Richer dirty-state prompts with Save, Discard, and Cancel in one dialog.
- Recent-project availability badges and missing-package repair flow.
