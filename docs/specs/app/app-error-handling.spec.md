# App Error Handling Spec

Status: specified
Milestone: M6
Registry ID: APP-ERROR-HANDLING

## User Goal

A writer receives understandable recovery-oriented messages when open, save, Save As, export, or recent-project workflows fail.

## Scope

- Central app-error categories for document lifecycle operations.
- Human-readable user messages.
- Optional technical detail for diagnostics.
- Recovery suggestions where practical.
- Preservation of current project state after failures.

## Non-Goals

- No remote error reporting.
- No crash analytics.
- No localization pass in Milestone 6.
- No exposure of raw stack traces as primary UI text.

## Error Categories

- `openFailed`
- `saveFailed`
- `saveAsCanceled`
- `saveAsFailed`
- `exportFailed`
- `invalidPackage`
- `unsupportedPackageVersion`
- `missingProjectFile`
- `permissionDenied`
- `unknown`

## Architecture Rules

- Storage and export errors map to app-facing errors before presentation.
- Views present app errors but do not interpret raw storage failures.
- Unknown errors map to a safe generic message.
- Current document state must remain safe after any reported error.

## User-Facing Behavior

Errors use concise language a non-programmer can understand, such as "DreamJotter could not open this project package" with a recovery suggestion when available.

## Given/When/Then Examples

- Given a storage error, when surfaced to UI, then it maps to a human-readable app error.
- Given an unknown error, when surfaced to UI, then the app shows a safe generic message.
- Given an error occurs, then the current project state is not corrupted.
- Given Save As is canceled, when surfaced to UI, then the app does not show a failure alert unless the workflow needs explicit status.
- Given permission is denied, when open or save fails, then the message names the permission problem and suggests choosing another location.

## Edge Cases

- Unknown Swift error without useful description.
- Package exists but required files are missing.
- Unsupported package version.
- Save destination is read-only.
- Export path has an unsupported extension or permission issue.

## Data Model Implications

`AppError` includes ID, category, user message, optional technical detail, optional recovery suggestion, source operation, and timestamp.

## UI Implications

Alerts should show the user message first and recovery suggestion second. Technical detail may be logged or exposed through a future details control.

## Testability Notes

Tests should cover storage-error mapping, unknown-error fallback, and state preservation after open/save/export failures.

## Open Questions

- Should technical details be copyable from error dialogs in a diagnostics mode?
- Should Save As cancel be silent in all entry points?

## Executable Spec Plan

- Storage errors map to `AppError` categories.
- Unknown errors map to a generic user message.
- Failed open preserves current document.
- Failed save preserves dirty state.
