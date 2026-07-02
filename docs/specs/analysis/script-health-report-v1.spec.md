# Script Health Report v1 Spec

Status: specified
Milestone: M9
Traceability ID: SCRIPT-HEALTH-REPORT-V1

## User Goal

As a writer, I want friendly, actionable screenplay/project health information that does not judge my creativity or mutate my work.

## Scope

Required metrics:

- Scene count.
- Screenplay element count.
- Character profile count.
- Unresolved detected character count.
- Location profile count.
- Unresolved detected location count.
- Open notes count.
- TODO count.
- Dialogue/action ratio.
- Longest scenes.
- Scenes without detected dialogue.
- Formatting warnings.
- Storage/saved status when available.

## Non-Goals

- No AI critique.
- No blocking save/export.
- No definitive creative scoring.

## Acceptance Criteria

- Given a project with scenes, scene count is correct.
- Given unresolved detected characters exist, report includes them.
- Given unresolved detected locations exist, report includes them.
- Given TODO notes exist, report includes TODO count.
- Given a character cue has no dialogue, report includes a warning.
- Given report runs, dirty state is unchanged.
- Given malformed script text, report does not crash.

## Data Model Implications

Uses `ScriptHealthReport` and `ReviewFinding`.

## Testability Notes

Executable specs should generate reports from small screenplay fixtures.

## Privacy Notes

Report stays local and does not call external services.

## Open Questions

- Should health report include optional targets or ranges for every finding?
