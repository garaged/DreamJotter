# Export Workflow v1 Spec

Status: specified
Milestone: M9
Traceability ID: EXPORT-WORKFLOW-V1

## User Goal

As a writer, I want to export my project in useful formats without changing the project or leaking internal management metadata by accident.

## Scope

- Export Fountain, plain text, Markdown, JSON backup, and basic PDF.
- Export from workspace or Review Mode.
- Human-readable errors.
- Dirty state preservation.

## Non-Goals

- No FDX import/export.
- No production-grade pagination.
- No collaboration package or cloud share link.

## Beginner Behavior

The user chooses a preset and destination. DreamJotter suggests a safe default format and filename.

## Pro Behavior

Future Pro Mode may expose more metadata inclusion controls, but M9 defaults must remain safe.

## User-Facing Behavior

- Exports are read-only projections.
- Export failure keeps current project safe.
- Reader-facing exports exclude notes, internal IDs, detected unresolved items, and project-management metadata unless the selected preset includes them.

## Acceptance Criteria

- Given an open project, when the user exports Fountain, then a Fountain file is produced.
- Given an open project, when the user exports Markdown, then a readable Markdown file is produced.
- Given an open project, when the user exports plain text, then readable script text is produced.
- Given an open project, when the user exports JSON backup, then a restorable backup artifact is produced.
- Given an export failure, then the app shows a friendly error and does not corrupt project state.
- Given a clean or dirty project, when export succeeds, then dirty state remains unchanged.

## Edge Cases

- Destination permission denied.
- Unsupported preset/format combination.
- Empty screenplay.
- Malformed screenplay text.
- Dirty project exported before save.

## Data Model Implications

Uses `ExportRequest`, `ExportResult`, and `ExportPreset`. Export artifacts are not canonical project data.

## Storage Implications

Exports may write outside the `.dreamjotter` package. Backup exports may contain structured package data.

## Command Implications

Export is not a mutation command. Restore is separate and must protect dirty state.

## UI Implications

SwiftUI views should call export view-model/app-service actions and show friendly errors.

## Testability Notes

Executable specs should assert generated artifact type, metadata exclusion, error mapping, and dirty-state preservation.

## Platform Implications

Portable export request/result logic should be platform-neutral. PDF rendering may use an Apple adapter.

## Security and Privacy

Internal notes, IDs, and project metadata must be excluded by default from reader-facing exports.

## Open Questions

- Should export artifacts be recorded in project history or only in app recents?
