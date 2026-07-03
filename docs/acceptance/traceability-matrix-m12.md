# Milestone 12 Traceability Matrix Extension

This extension supplements the primary traceability matrix for writer workflow polish.

| Requirement | Slice | Spec | Acceptance | Implementation | Executable coverage | Status |
| --- | --- | --- | --- | --- | --- | --- |
| M12-WRITER-WORKFLOW-POLISH | M12 | `docs/milestones/milestone-12-writer-workflow-polish.md` | `docs/acceptance/milestone-12-acceptance.md` | writer workflow and localization modules | slice-specific suites | in-progress |
| M12-PROFILE-MANAGEMENT | M12.1 | `docs/specs/writer-workflow/m12-profile-management.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | profile workflow core and macOS views | `ProfileManagementExecutableSpecs.swift` | implemented |
| M12-NOTES-WORKSPACE | M12.2 | `docs/specs/writer-workflow/m12-notes-workspace.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | notes workflow core and macOS views | `NotesWorkspaceExecutableSpecs.swift` | implemented |
| M12-SCENE-WORKFLOW | M12.3 | `docs/specs/writer-workflow/m12-scene-workflow.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | scene workflow core and macOS adapters | `SceneWorkflowExecutableSpecs.swift` | implemented pending validation |
| M12-LOCALIZATION-SPANISH | M12.4 | `docs/specs/writer-workflow/m12-localization-spanish.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | language profiles, parser lexicons, diagnostics, resources, fixtures, editor integration | `LocalizationSpanishExecutableSpecs.swift` | implemented pending validation |
| M12-FULL-SPANISH-UI | M12.5 | `docs/specs/writer-workflow/m12-full-ui-localization.spec.md` | `docs/acceptance/milestone-12-acceptance.md` | planned complete String Catalog, localization audit, localized errors, accessibility labels, and Spanish UI tests | planned localization audit and UI smoke suites | specified |

## Cross-Slice Traceability Rules

- Persisted fields include save and reopen coverage.
- Metadata-only workflows preserve screenplay order and navigation state.
- Search projections are verified after mutations.
- Localization preserves semantic identity and original screenplay text.
- Application language and screenplay language remain independent.
- Existing English fixtures remain regression-stable.
- Every required UI workflow must be understandable in Spanish without exposing raw implementation values.

## M12.1 Coverage

Profile lifecycle, CRUD, search, rename, merge, snapshot failure handling, linked metadata updates, and package persistence.

## M12.2 Coverage

Stored-note CRUD, target assignment, Unicode search, filters, localized TODO projection, navigation, orphan handling, and package persistence.

## M12.3 Coverage

Scene metadata, search, filters, planning order, navigation, screenplay-order application, scene-block preservation, and package persistence.

## M12.4 Coverage

English and Spanish screenplay-language profiles, bilingual parsing, Unicode cues, Spanish constructs, localized diagnostics, project-language persistence, fixtures, and localized TODO projection.

## M12.5 Planned Coverage

Complete `es-MX` and `es-419` localization for menus, project library, dashboard, editor, profiles, scenes, notes, review, health, export, backup, restore, settings, alerts, panels, tooltips, dynamic messages, plurals, accessibility, and layout; automated missing-key detection; Spanish UI smoke tests; and native-speaker review.
