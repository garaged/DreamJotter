# Review Mode Export UX Spec

Status: specified
Milestone: 9.5
Traceability ID: REVIEW-MODE-EXPORT-UX

## User Goal

A writer can review a read-only script and export common review artifacts without leaving Review Mode unexpectedly.

## Scope

- Export picker from Review Mode.
- Reader PDF, Fountain, and Markdown as common outputs.
- Shared export UI state.
- Read-only preview clarity.
- Feedback in Review Mode.

## Non-Goals

- No reviewer comments.
- No locked review sessions.
- No collaboration.

## User-Facing Behavior

Review Mode clearly states that the script preview is read-only. Export opens the same picker used from the workspace. Cancel and failure leave Review Mode open.

## Acceptance Criteria

- Given Review Mode is open, when export is selected, then export picker opens.
- Given Reader PDF is exported from Review Mode, then dirty state is unchanged.
- Given export is canceled, then Review Mode remains open.
- Given export fails, then friendly feedback is shown.

## Given/When/Then Examples

- Given the writer is reviewing findings, when they export Markdown, then Review Mode remains active and feedback appears.
- Given export is canceled, then selected finding state remains unchanged.

## Edge Cases

- No open project.
- Empty script.
- Export failure after destination chosen.
- Finding selected before export.

## Data Model Implications

Uses `ExportUIState.sourceContext = reviewMode`.

## Storage Implications

No canonical project storage changes.

## Command Implications

Export is read-only.

## UI Implications

Review Mode should not expose editable controls in the script preview.

## Testability Notes

Tests should validate Review Mode export uses shared export state and does not dirty project.

## Platform Implications

Future platforms can reuse the same state machine with platform-specific document exporters.

## Security and Privacy Notes

Reader-facing exports from Review Mode must still follow preset metadata rules.

## Open Questions

- Should Review Mode offer one-click Reader PDF after picker implementation proves stable?
