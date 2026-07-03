# Milestone 12 Traceability Matrix Extension

This extension supplements the primary traceability matrix for writer workflow polish.

| Requirement | Slice | Spec | Acceptance | Implementation | Executable coverage | Status |
| --- | --- | --- | --- | --- | --- | --- |
| M12-WRITER-WORKFLOW-POLISH | M12 | `docs/milestones/milestone-12-writer-workflow-polish.md` | `docs/acceptance/milestone-12-acceptance.md` | writer workflow and localization modules | slice-specific suites | in-progress |
| M12-PROFILE-MANAGEMENT | M12.1 | `docs/specs/writer-workflow/m12-profile-management.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | `Sources/DreamJotterCore/ProfileManagement.swift`, profile workspace views | `Tests/DreamJotterExecutableSpecs/ProfileManagementExecutableSpecs.swift` | implemented |
| M12-NOTES-WORKSPACE | M12.2 | `docs/specs/writer-workflow/m12-notes-workspace.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | `Sources/DreamJotterCore/NotesWorkspace.swift`, notes workspace views | `Tests/DreamJotterExecutableSpecs/NotesWorkspaceExecutableSpecs.swift` | implemented |
| M12-SCENE-WORKFLOW | M12.3 | `docs/specs/writer-workflow/m12-scene-workflow.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | scene workflow core and macOS adapters | `Tests/DreamJotterExecutableSpecs/SceneWorkflowExecutableSpecs.swift` | implemented pending validation |
| M12-LOCALIZATION-SPANISH | M12.4 | `docs/specs/writer-workflow/m12-localization-spanish.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | planned language profiles, localized parser lexicons, diagnostics, resources, and editor suggestions | planned localization and parser suites | specified |

## Cross-Slice Traceability Rules

- Persisted fields include save and reopen coverage.
- Metadata-only workflows preserve screenplay order and navigation state.
- Search projections are verified after mutations.
- Localization preserves semantic identity and original screenplay text.
- Application language and screenplay language remain independent.
- Existing English fixtures must remain regression-stable.

## M12.1 Coverage

Profile lifecycle, CRUD, search, rename, merge, snapshot failure handling, linked metadata updates, and package persistence.

## M12.2 Coverage

Stored-note CRUD, target assignment, Unicode search, filters, TODO projection, navigation, orphan handling, and package persistence.

## M12.3 Coverage

Scene metadata, search, filters, planning order, navigation, screenplay-order application, scene-block preservation, and package persistence.

## M12.4 Planned Coverage

English, `es-MX`, and `es-419` UI resources; independent app and screenplay language settings; Unicode character cues; Spanish scene headings, transitions, shots, title-page fields, TODO tokens, parentheticals, and cue extensions; localized diagnostics; English regression fixtures; Spanish and mixed-language round trips; export fidelity; accessibility; and UI smoke validation.
