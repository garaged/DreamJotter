# Milestone 9.6: Restore UX Hardening

Status: specified
Milestone: M9.6
Traceability ID: M9-6-RESTORE-UX-HARDENING

## Goal

Turn the current restore protection behavior into a complete writer-safe restore experience.

M9.5 correctly blocks restore when the current project has unsaved changes, but it only returns confirmation-required feedback. M9.6 adds the richer user flow: Save / Discard / Cancel before restore replaces the current project.

## Product Outcome

- A writer can restore a valid backup without losing unsaved work accidentally.
- A writer with dirty current work receives clear choices before restore.
- Restore remains local-first, deterministic, and reversible by user intent.
- Invalid or incompatible backups never replace current project state.

## Scope

- Restore-specific dirty-project confirmation flow.
- Save / Discard / Cancel restore choices.
- Restore feedback messages for success, cancel, invalid backup, failed save, and blocked replacement.
- View-model/app-support state for pending restore data.
- Tests that prove restore choices preserve or replace state correctly.
- Documentation updates for acceptance, TODO, and traceability.

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

## Feature Areas

### A. Pending Restore State

The app needs adapter-neutral state that can hold a validated restore candidate while waiting for user choice.

The state should represent:

- No pending restore.
- Pending restore requires dirty-current-project decision.
- Pending restore is ready to apply.
- Pending restore failed validation.

### B. Restore Confirmation Choices

When current project is dirty, the restore flow presents:

- Save and Restore: save current project first; restore only if save succeeds.
- Discard and Restore: discard unsaved current work and restore validated backup.
- Cancel: abandon restore and preserve current state.

### C. Save Failure Safety

If Save and Restore fails, the restore must not apply. The writer should receive save-failure feedback and remain in the current dirty project.

### D. Restore Feedback

Feedback should distinguish:

- Restore completed.
- Restore canceled.
- Restore blocked because save failed.
- Restore blocked because backup is invalid.
- Restore blocked because backup is incompatible.
- Restore blocked because no project replacement decision was made.

### E. Tests

Tests should cover:

- Valid restore into a clean project replaces state and clears dirty state according to restore policy.
- Valid restore into a dirty project enters pending confirmation state.
- Cancel preserves current project data and dirty state.
- Discard applies restore and replaces current project data.
- Save and Restore applies restore only after successful save.
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
