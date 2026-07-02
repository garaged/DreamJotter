# Backup and Restore UI Spec

Status: specified
Milestone: 9.5
Traceability ID: BACKUP-RESTORE-UI

## User Goal

A writer can create a backup and restore a backup without losing unsaved work or needing to understand package internals.

## Scope

- Create Backup UI.
- Restore Backup UI.
- Backup success/failure feedback.
- Restore validation.
- Dirty current project protection.
- Restore cancel behavior.

## Non-Goals

- No cloud backup.
- No scheduled backups.
- No zipped package format decision.
- No merge restore.

## User-Facing Behavior

Create Backup uses Writer Backup/JSON Backup behavior. Restore validates the selected artifact before replacing current state. Dirty current work requires Save, Discard, or Cancel protection.

## Acceptance Criteria

- Given an open project, when Create Backup is selected, then a backup artifact is produced.
- Given backup succeeds, then success feedback is shown.
- Given backup fails, then friendly feedback is shown.
- Given current project is dirty, then restore protects unsaved changes.
- Given a valid backup is selected, then restored project opens.
- Given invalid backup is selected, then current project remains safe.
- Given restore is canceled, then current project remains unchanged.

## Given/When/Then Examples

- Given a dirty project, when Restore Backup is selected, then the app requires an explicit safe path before replacing it.
- Given an invalid JSON file is selected, then the app shows a friendly error and keeps the current project open.

## Edge Cases

- Missing backup file.
- Unsupported backup version.
- Backup project ID mismatch.
- Permission denied.
- Dirty current project.

## Data Model Implications

Uses `ExportUIState`, `ExportFeedback`, `BackupArchive`, and `RestoreResult`.

## Storage Implications

Backups are artifacts, not canonical project storage. `.dreamjotter` remains canonical.

## Command Implications

Restore is a replacement workflow and must route through existing document lifecycle protection.

## UI Implications

Restore confirmation should be centralized in view-model/app-support state, not duplicated in views.

## Testability Notes

Tests should cover valid restore, invalid restore, dirty restore protection, cancel, and feedback generation.

## Platform Implications

macOS uses open/save panels. Future platforms can reuse validation but not panel UI.

## Security and Privacy Notes

Backups include private notes and internal project metadata; UI must warn users.

## Open Questions

- Should restore create a snapshot of the current project before replacement?
