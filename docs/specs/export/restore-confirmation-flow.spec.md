# Restore Confirmation Flow Spec

Status: implemented
Milestone: M9.6
Traceability ID: RESTORE-CONFIRMATION-FLOW

## Purpose

Define the restore-specific Save / Discard / Cancel flow used when a writer attempts to restore a backup while the current project has unsaved changes.

## User Story

As a writer, I want DreamJotter to warn me before a backup restore replaces my current unsaved work, so I can save, discard, or cancel safely.

## Preconditions

- The user has selected a backup file.
- The backup payload has been read.
- Restore validation has either succeeded or failed.
- The current project may be clean or dirty.

## State Model

The app models restore as a two-phase operation:

1. Validate candidate backup.
2. Apply candidate backup only when current-project replacement is safe.

Implemented state lives in `MacAppViewModel` as pending restore state for a validated candidate.

The implemented behavior covers:

- No pending restore.
- Validation failure before pending replacement state.
- Pending dirty-project restore decision.
- Restore application after Save and Restore or Discard and Restore.
- Cancellation that clears pending restore state.

## Behavior

### Clean Current Project

When the current project is clean and backup validation succeeds, restore may apply immediately after user file selection.

Expected result:

- Current project data is replaced with restored data.
- Project package ownership follows the existing restore workflow policy.
- Feedback reports restore success.
- Dirty state follows explicit restore policy and is tested.

### Dirty Current Project

When the current project is dirty and backup validation succeeds, restore must not apply immediately.

The app presents three choices:

#### Save and Restore

- Attempt to save the current project through existing save lifecycle behavior.
- If save succeeds, apply the validated restore candidate.
- If save fails or is canceled, do not restore.
- Report specific feedback.

#### Discard and Restore

- Explicitly discard unsaved current changes.
- Apply the validated restore candidate.
- Report restore success.

#### Cancel

- Clear pending restore candidate.
- Preserve current project data, package URL, and dirty state.
- Report canceled feedback or dismiss clearly without implying success.

### Invalid Backup

Invalid backup input must never enter a replacement confirmation flow.

Expected result:

- Current project data is unchanged.
- Dirty state is unchanged.
- Feedback explains that the backup could not be restored.

## Feedback Requirements

Feedback text should be plain-language and action-oriented.

Examples:

- `Restore canceled. Your current project was not changed.`
- `Restore blocked because the current project could not be saved.`
- `This backup is not valid DreamJotter backup data.`
- `Restore complete.`

## Edge Cases

- Dirty unsaved project with no package URL chooses Save and Restore: routes through Save As.
- User cancels Save As during Save and Restore: does not restore.
- Backup validates, but applying restore fails: preserve current state if possible and report failure.
- User selects another backup while one is pending: current implementation replaces pending candidate only through explicit restore action flow.
- Review Mode restore entry point exits read-only review context only after restore completes.

## Acceptance Criteria

- Dirty restore never replaces current state before explicit user choice.
- Save and Restore respects M6 save semantics.
- Discard and Restore is explicit and applies only validated backup data.
- Cancel is non-destructive.
- Invalid backups are rejected before replacement confirmation.
- Tests cover clean restore, dirty restore, save failure, cancel, discard, and invalid backup.

## Implementation Notes

Implemented by PR #3:

- `MacAppViewModel` owns pending restore state and restore decision methods.
- `AppRootView` presents a restore-specific Save and Restore / Discard and Restore / Cancel alert.
- `Tests/DreamJotterMacTests/M9RestoreUXTests.swift` covers the M9.6 restore decision flow.

Validation passed on the feature branch and on `main`.
