# Review Mode v1 Spec

Status: specified
Milestone: M9
Traceability ID: REVIEW-MODE-V1

## User Goal

As a writer, I want a read-only review workspace so I can inspect my script, notes, TODOs, findings, and exports without accidentally editing.

## Scope

- Read-only script preview.
- Scene navigator.
- Notes/TODO section.
- Health findings list.
- Export actions.
- Navigation from finding/scene to editor target where practical.

## Non-Goals

- No collaborative comments.
- No track changes.
- No reviewer accounts.

## Acceptance Criteria

- Given an open project, when user enters Review Mode, then script appears read-only.
- Given health findings exist, when Review Mode opens, findings are visible.
- Given a finding linked to a scene, then the app can navigate to or identify that scene.
- Given export from Review Mode, export workflow runs.
- Given the user returns to Script editor, normal editing remains available.

## Data Model Implications

Uses `ReviewModeState` and `ReviewFinding`.

## UI Implications

Review Mode must clearly indicate read-only state and provide a route back to editing.

## Testability Notes

Executable specs can assert view-model state rather than fragile UI automation.

## Open Questions

- Should Review Mode be a sidebar section or a separate window mode?
