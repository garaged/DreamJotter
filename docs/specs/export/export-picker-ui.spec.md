# Export Picker UI Spec

Status: specified
Milestone: 9.5
Traceability ID: EXPORT-FORMAT-PICKER-UI

## User Goal

A writer can choose a useful export format without knowing technical file-format details.

## Scope

- Show Fountain, PDF, Markdown, Plain Text, and JSON Backup formats.
- Explain each format in beginner-friendly language.
- Use the existing M9 export workflow for execution.
- Keep export read-only.

## Non-Goals

- No FDX export.
- No production pagination.
- No cloud sharing.
- No rewrite of export core.

## User-Facing Behavior

- Fountain: "Best for screenplay tools and plain screenplay exchange."
- PDF: "Best for reading or printing."
- Markdown: "Best for notes-friendly readable text."
- Plain Text: "Best for durable archives."
- JSON Backup: "Best for restoring your DreamJotter project."

Unsupported preset/format combinations must be disabled or explained.

## Acceptance Criteria

- Given an open project, when export UI opens, then all supported formats are visible.
- Given PDF is selected, when export runs, then existing PDF adapter is used.
- Given a text format is selected, when export runs, then existing text export is used.
- Given JSON Backup is selected, when export runs, then backup export workflow is used.
- Given export completes, then dirty state is unchanged.

## Given/When/Then Examples

- Given Reader Copy is selected, when the user chooses PDF, then export is allowed.
- Given Plain Text Archive is selected, when the user chooses PDF, then the UI disables PDF or explains the mismatch.
- Given the user cancels export, then the project remains unchanged.

## Edge Cases

- No open project.
- Empty screenplay.
- Invalid destination.
- Unsupported preset/format pair.
- Dirty project.

## Data Model Implications

Uses `ExportUIState` and existing M9 `ExportRequest`.

## Storage Implications

No canonical project storage changes.

## Command Implications

Export is read-only and does not require a mutation command.

## UI Implications

SwiftUI views should bind to app/view-model state and not duplicate export validation logic.

## Testability Notes

Adapter-neutral tests should verify available formats, default format, disabled reasons, and dirty-state preservation.

## Platform Implications

macOS uses native save panels; future iPad/iPhone can use platform document exporters.

## Security and Privacy Notes

Reader-facing formats must avoid internal metadata by default.

## Open Questions

- Should PDF be grouped as "Reader Copy" first instead of format first?
