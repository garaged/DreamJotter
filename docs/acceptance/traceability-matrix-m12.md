# Milestone 12 Traceability Matrix Extension

This extension supplements the primary traceability matrix for writer workflow polish.

| Requirement | Slice | Spec | Acceptance | Implementation | Executable coverage | Status |
| --- | --- | --- | --- | --- | --- | --- |
| M12-WRITER-WORKFLOW-POLISH | M12 | `docs/milestones/milestone-12-writer-workflow-polish.md` | `docs/acceptance/milestone-12-acceptance.md` | CommandEngine, ProjectDocumentViewModel, writer workspace views | slice-specific suites | in-progress |
| M12-PROFILE-MANAGEMENT | M12.1 | `docs/specs/writer-workflow/m12-profile-management.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | `Sources/DreamJotterCore/ProfileManagement.swift`, profile workspace views | `Tests/DreamJotterExecutableSpecs/ProfileManagementExecutableSpecs.swift` | implemented |
| M12-NOTES-WORKSPACE | M12.2 | `docs/specs/writer-workflow/m12-notes-workspace.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | `Sources/DreamJotterCore/NotesWorkspace.swift`, `Apps/DreamJotterMac/Views/NotesView.swift`, `Apps/DreamJotterMac/Views/ProjectWorkspaceView.swift` | `Tests/DreamJotterExecutableSpecs/NotesWorkspaceExecutableSpecs.swift` | implemented |
| M12-SCENE-WORKFLOW | M12.3 | `docs/milestones/milestone-12-writer-workflow-polish.md` | `docs/acceptance/milestone-12-acceptance.md` | SceneWorkflow, CommandEngine, editor navigation integration | planned | planned |

## Cross-Slice Traceability Rules

- Every destructive mutation maps to a concrete command request and executable spec.
- Every bulk mutation includes snapshot-failure coverage.
- Every persisted field includes save and reopen coverage.
- Every metadata-only workflow includes a regression assertion for screenplay order and editor navigation state.
- Search and dashboard projections are verified after mutations rather than treated as canonical state.

## M12.1 Coverage

M12.1 coverage includes archive and restore, explicit confirmation for profile removal and merge, deterministic rename previews, stale-preview rejection, snapshot failure blocking, Unicode character and location rename, duplicate merge, linked-note remapping, scene-card metadata updates, package save/reopen persistence, and persisted-profile CRUD adapters.

## M12.2 Coverage

M12.2 coverage includes stored-note CRUD, Unicode-aware search, state and target filtering, parsed TODO separation, linked-target resolution and workspace navigation, resolve and reopen, explicit confirmation and snapshot failure blocking for bulk resolve, orphan detection and safe unlinking, dashboard/search projection updates, and package save/reopen persistence.
