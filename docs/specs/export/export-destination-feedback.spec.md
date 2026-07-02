# Export Destination and Feedback Spec

Status: specified
Milestone: 9.5
Traceability ID: EXPORT-DESTINATION-FEEDBACK

## User Goal

A writer understands where an export went, whether it succeeded, and what to do if it failed.

## Scope

- Destination selection.
- Success feedback.
- Failure feedback.
- Cancel feedback.
- Reveal in Finder availability.
- Dirty-state preservation.

## Non-Goals

- No export history.
- No automatic cloud upload.
- No background queue.

## User-Facing Behavior

- Destination cancel is a normal canceled state, not an error.
- Success feedback includes filename/path when available.
- Failures use friendly messages and optional recovery suggestions.
- Reveal in Finder is available only when a real output path exists.

## Acceptance Criteria

- Given export succeeds, then success feedback is visible.
- Given destination selection is canceled, then no error is shown and dirty state is unchanged.
- Given export fails, then friendly feedback is shown.
- Given export succeeds with an output path, then Reveal in Finder availability is represented.

## Given/When/Then Examples

- Given the user cancels a save panel, when the export UI returns, then feedback says export was canceled.
- Given a permission error occurs, when surfaced, then the user sees a short message and current project remains safe.

## Edge Cases

- Read-only folder.
- Missing external drive.
- Filename collision.
- Destination path empty.

## Data Model Implications

Uses `ExportFeedback`.

## Storage Implications

No canonical project storage changes.

## Command Implications

Export is a read-only operation.

## UI Implications

Feedback should be visible in workspace and Review Mode contexts.

## Testability Notes

Tests should validate feedback kind, message, output path, and reveal availability.

## Platform Implications

Reveal in Finder is macOS-specific; the state should remain portable enough to express equivalent future actions.

## Security and Privacy Notes

Technical detail should not be the primary user-facing message.

## Open Questions

- Should successful export feedback auto-dismiss?
