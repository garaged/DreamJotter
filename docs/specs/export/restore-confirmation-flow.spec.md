# Restore Confirmation Flow Spec

Status: specified
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

The app should model restore as a two-phase operation:

1. Validate candidate backup.
2. Apply candidate backup only when current-project replacement is safe.

Suggested state cases:

```text
idle
validating
validationFailed(reason)
readyToApply(candidate)
requiresDirtyProjectDecision(candidate)
applying
completed(feedback)
canceled(feedback)
failed(feedback)
```

This state may live in a dedicated restore UI state type or inside the existing export/backup UI state, but it must remain adapter-neutral.

## Behavior

### Clean Current Project

When the current project is clean and backup validation succeeds, restore may apply immediately after user file selection.

Expected result:

- Current project data is replaced with restored data.
- Project package ownership follows the existing restore workflow policy.
- Feedback reports restore success.
- Dirty state follows explicit restore policy and must be tested.

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
- Report canceled feedback or dismiss silently if the UI already makes cancellation obvious.

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

- Dirty unsaved project with no package URL chooses Save and Restore: route through Save As.
- User cancels Save As during Save and Restore: do not restore.
- Backup validates, but applying restore fails: preserve current state if possible and report failure.
- User selects another backup while one is pending: replace pending candidate only after explicit user action, or cancel the first pending operation first.
- Review Mode restore entry point, if present, must exit read-only review context only after restore completes.

## Acceptance Criteria

- Dirty restore never replaces current state before explicit user choice.
- Save and Restore respects M6 save semantics.
- Discard and Restore is explicit and applies only validated backup data.
- Cancel is non-destructive.
- Invalid backups are rejected before replacement confirmation.
- Tests cover clean restore, dirty restore, save failure, cancel, discard, and invalid backup.

## Implementation Notes

The current M9.5 implementation already returns confirmation-required feedback for dirty restore attempts. M9.6 should evolve that feedback into first-class pending restore state and a dedicated confirmation UI path.
