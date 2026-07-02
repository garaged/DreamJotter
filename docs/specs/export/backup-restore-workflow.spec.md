# Backup and Restore Workflow Spec

Status: specified
Milestone: M9
Traceability ID: BACKUP-RESTORE-WORKFLOW-V1

## User Goal

As a writer, I want to back up and restore my project without losing current unsaved work.

## Scope

- Export restorable backup artifacts.
- Restore valid backups.
- Validate before replacing project state.
- Protect dirty current work.
- Preserve M8 metadata.

## Non-Goals

- No cloud sync.
- No collaboration merge.
- No cross-device conflict resolution.

## Acceptance Criteria

- Given an open project, when the user exports backup, then a backup artifact is produced.
- Given a valid backup, when restored, project data is loaded.
- Given restore while current project is dirty, unsaved changes are protected.
- Given an invalid backup, the app shows a friendly error and keeps current state safe.
- Given a restored project is saved and reopened, restored data remains intact.

## Backup Contents

- Manifest/package version.
- Project metadata.
- Screenplay data and Fountain projection where available.
- Characters, locations, notes, scene metadata.
- Ignored detected characters/locations where implemented.
- Routines/custom fields where already supported.

## Data Model Implications

Uses `BackupArchive` and `RestoreResult`.

## Command Implications

Restore is a state replacement workflow and must pass through dirty-state protection.

## Security and Privacy

Backups may contain internal notes, IDs, and metadata. UI must describe this.

## Open Questions

- Should backup artifacts be zipped `.dreamjotter` folders or JSON bundles first?
