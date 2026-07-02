# Formatting Warning v1 Spec

Status: specified
Milestone: M9
Traceability ID: FORMATTING-WARNING-V1

## User Goal

As a writer, I want gentle formatting warnings that help improve structure without blocking writing.

## Scope

Initial warnings:

- Scene heading missing location.
- Scene heading missing time of day.
- Character cue without dialogue.
- Dialogue without clear character.
- Transition in unusual position.
- Empty scene.
- Note/TODO still open before export.
- Unresolved detected character.
- Unresolved detected location.

## Non-Goals

- No automatic rewrites.
- No mandatory fixes.
- No AI-based formatting judgment.

## Acceptance Criteria

- Given a scene heading missing time of day, warning appears.
- Given a character cue without dialogue, warning appears.
- Given warnings exist, save still works.
- Given warnings exist, export still works unless the chosen export explicitly blocks it.
- Given the user ignores warnings, project text is unchanged.

## Data Model Implications

Formatting warnings become `ReviewFinding` records with source `formatting`.

## Testability Notes

Executable specs should cover malformed and Unicode screenplay text.

## Open Questions

- Should dismissed warnings persist as project metadata or remain session-local?
