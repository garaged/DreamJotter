# Milestone 9.6 Acceptance: Restore UX Hardening

Status: specified
Milestone: M9.6
Traceability ID: M9-6-RESTORE-UX-HARDENING

## Acceptance Summary

Milestone 9.6 is accepted when restore can safely replace the current project only after restore data is validated and dirty current work is protected by an explicit Save / Discard / Cancel decision.

## Required Acceptance Criteria

### Restore Validation

- Valid backup data is parsed and validated before replacement.
- Invalid backup data never replaces current project state.
- Incompatible backup data produces clear failure feedback.
- Restore validation does not dirty the current project.

### Clean Project Restore

- Restoring into a clean current project applies valid backup data through the existing restore workflow.
- Restore success feedback is shown.
- Project state after restore is deterministic and covered by tests.

### Dirty Project Restore

- Restoring into a dirty current project does not apply immediately.
- The app enters pending restore confirmation state.
- The writer can choose Save and Restore, Discard and Restore, or Cancel.

### Save and Restore

- Save and Restore uses existing M6 save lifecycle behavior.
- If save succeeds, the validated restore candidate is applied.
- If save fails, the restore is blocked and current dirty work is preserved.
- If Save As is required and the writer cancels it, restore is canceled and current work is preserved.

### Discard and Restore

- Discard and Restore requires explicit user intent.
- The validated restore candidate replaces current project state.
- Dirty state follows the restore policy and is tested.

### Cancel

- Cancel clears pending restore state.
- Current project data, package URL, and dirty state are unchanged.
- Feedback reports cancellation or the UI dismisses clearly without implying success.

### Preservation

- Existing export picker behavior remains unchanged.
- Existing backup creation remains unchanged.
- Existing M6 document lifecycle behavior remains intact.
- Existing M7 editor, M8 workspace/project-object, and M9 review/export/health behavior remains intact.

## Required Tests

- Valid restore into clean project.
- Valid restore into dirty project creates pending confirmation state.
- Cancel preserves current dirty project.
- Discard and Restore applies validated backup.
- Save and Restore applies only after successful save.
- Save failure blocks restore.
- Invalid backup does not create pending replacement state.
- Restore feedback distinguishes success, cancel, invalid input, save failure, and blocked replacement.

## Validation Commands

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

## Acceptance Decision

M9.6 should remain `specified` until the restore confirmation flow is executable-spec covered and implemented.
