# Milestone 9.6: Restore UX Hardening

Status: implemented
Milestone: M9.6
Traceability ID: M9-6-RESTORE-UX-HARDENING

## Goal

Turn the current restore protection behavior into a complete writer-safe restore experience.

M9.5 correctly blocked restore when the current project had unsaved changes, but it only returned confirmation-required feedback. M9.6 adds the richer user flow: Save / Discard / Cancel before restore replaces the current project.

## Product Outcome

- A writer can restore a valid backup without losing unsaved work accidentally.
- A writer with dirty current work receives clear choices before restore.
- Restore remains local-first, deterministic, and reversible by user intent.
- Invalid or incompatible backups never replace current project state.

## Implemented Scope

- Restore-specific dirty-project confirmation flow.
- Save / Discard / Cancel restore choices.
- Restore feedback messages for success, cancel, invalid backup, failed save, and blocked replacement.
- View-model/app-support state for pending restore data.
- Tests that prove restore choices preserve or replace state correctly.
- Documentation updates for acceptance, TODO, and status surfaces.

## Non-Goals

- No production PDF pagination.
- No export history.
- No cloud backup or sync.
- No automatic background backup.
- No native document-version browser.
- No destructive restore without explicit user choice.

## Architecture Rules

- Restore validation must happen before any current project replacement.
- Dirty current work must be protected before restore commits.
- Save-before-restore must use the same save lifecycle as M6 document save behavior.
- Cancel must leave current project content, package URL, and dirty state unchanged.
- Discard must be explicit and must only replace state after a valid backup is already parsed.
- SwiftUI views remain thin; decision state belongs in app-support/view-model logic.
- `.dreamjotter` package remains canonical project storage.

## Implemented Feature Areas

### A. Pending Restore State

`MacAppViewModel` now owns pending restore state for a validated restore candidate while waiting for writer choice.

The implemented state represents:

- No pending restore.
- Pending restore requires dirty-current-project decision.
- Invalid restore data rejected before pending state is created.

### B. Restore Confirmation Choices

When current project is dirty, the restore flow presents:

- Save and Restore: save current project first; restore only if save succeeds.
- Discard and Restore: discard unsaved current work and restore validated backup.
- Cancel: abandon restore and preserve current state.

### C. Save Failure Safety

If Save and Restore fails, restore does not apply. The current dirty project and pending restore candidate are preserved so the writer can recover.

### D. Restore Feedback

Feedback distinguishes:

- Restore completed.
- Restore canceled.
- Restore blocked because save failed.
- Restore blocked because backup is invalid.
- Restore blocked because no project replacement decision was made.

### E. Tests

Implemented tests cover:

- Valid restore into a clean project replaces state and clears dirty state according to restore policy.
- Valid restore into a dirty project enters pending confirmation state.
- Cancel preserves current project data and dirty state.
- Discard applies restore and replaces current project data.
- Save and Restore requires Save As for unsaved dirty projects.
- External Save As followed by restore applies the pending backup.
- Save failure prevents restore and preserves current dirty project.
- Invalid restore never creates pending replacement state.

## Acceptance Criteria

- Restore cannot replace dirty current work without Save and Restore or Discard and Restore.
- Cancel restore is non-destructive and does not dirty the project further.
- Failed save before restore blocks restore.
- Invalid backup data preserves the current project.
- Restore feedback is specific enough for a non-technical writer.
- Existing M9.5 export picker and backup creation behavior remain unchanged.
- Existing M6 lifecycle, M7 editor, M8 project objects, and M9 review/export/health behavior are preserved.

## Implementation Summary

Implemented by PR #3:

- `Apps/DreamJotterMac/ViewModels/MacAppViewModel.swift`
- `Apps/DreamJotterMac/Views/AppRootView.swift`
- `Tests/DreamJotterMacTests/M9RestoreUXTests.swift`

Validation passed on the feature branch and on `main`:

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

## Related Specs

- `docs/specs/export/backup-restore-workflow.spec.md`
- `docs/specs/export/backup-restore-ui.spec.md`
- `docs/specs/export/restore-confirmation-flow.spec.md`
- `docs/specs/app/document-lifecycle.spec.md`
- `docs/data-contracts/app-document-state.md`
- `docs/data-contracts/restore-result.md`
- `docs/data-contracts/export-feedback.md`

## Deferred Work

- Automatic restore snapshots.
- Backup browser/history.
- Cloud backup.
- Native macOS document-version integration.
