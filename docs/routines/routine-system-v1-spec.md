# Routine System v1 Spec

## Purpose

Routine System v1 defines no-code automation for DreamJotter Pro Mode. Routines orchestrate approved commands through CommandEngine. They do not execute arbitrary scripts, run plugins, call networks, or mutate project internals directly.

## Scope

Routine v1 includes:

- Routine definitions.
- Supported triggers.
- Supported conditions.
- Supported actions.
- Routine enable/disable state.
- Routine run logs.
- CommandEngine execution boundary.
- Snapshot policy for destructive actions.
- Failure handling that preserves valid project state.

Routine v1 excludes:

- Arbitrary scripting.
- Plugin execution.
- Network actions.
- Cross-project automation.
- Background daemon behavior.
- User-authored code.

## Routine Definition

A routine is structured project data with:

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable routine ID. |
| `title` | Yes | User-visible name. |
| `enabled` | Yes | Whether the routine can run. |
| `trigger` | Yes | One supported trigger. |
| `conditions` | No | Ordered conditions that must pass. |
| `actions` | Yes | Ordered supported actions. |
| `failurePolicy` | No | Stop-on-failure by default; other policies deferred. |
| `createdAt` | Yes | Creation timestamp. |
| `updatedAt` | Yes | Last update timestamp. |

## Supported Triggers

| Trigger | Description |
| --- | --- |
| `manual` | User starts the routine explicitly. |
| `sceneStatusChanged` | Scene status changes through a command. |
| `beforeExport` | Export command is about to execute. |
| `afterExport` | Export command completed. |
| `beforeAIRewrite` | AI rewrite acceptance is about to create snapshot and apply mutation. |

## Supported Conditions

| Condition | Description |
| --- | --- |
| `sceneStatusEquals` | Runs only when a relevant scene status matches the configured value. |
| `projectHasOpenTODOs` | Runs only when project analysis finds unresolved TODO notes. |
| `proModeEnabled` | Runs only when Pro Mode is active. |

## Supported Actions

| Action | Description | Mutation | Snapshot Policy |
| --- | --- | --- | --- |
| `createSnapshot` | Creates a project snapshot. | Yes | Not required before itself. |
| `addNote` | Adds a note to project, scene, or character target. | Yes | Required only if configured as destructive replacement later. |
| `runAnalysis` | Runs read-only analysis such as health or continuity checks. | No | Not required. |
| `updateSceneStatus` | Updates scene status field. | Yes | Required if bulk or destructive according to command safety level. |
| `exportProject` | Placeholder for export action. | Maybe | Depends on overwrite/export target policy later. |

## CommandEngine Boundary

Rules:

- Routine actions produce command requests.
- CommandEngine validates and executes command requests.
- Routines must not directly mutate project internals.
- Command results feed routine run logs.
- Failed command validation prevents unsafe mutation.

Execution order:

1. Resolve trigger context.
2. Verify routine is enabled.
3. Validate conditions.
4. Validate action list.
5. For each action, create a command request.
6. Apply snapshot policy before destructive commands.
7. Execute command through CommandEngine.
8. Record action result.
9. Stop on failure unless a later failure policy explicitly allows continuation.

## Routine Run Logs

Each routine run produces a log with:

| Field | Required | Description |
| --- | --- | --- |
| `runId` | Yes | Stable run ID. |
| `routineId` | Yes | Routine definition ID. |
| `trigger` | Yes | Trigger that started the run. |
| `startedAt` | Yes | Start timestamp. |
| `endedAt` | Yes | End timestamp when complete. |
| `status` | Yes | `succeeded`, `failed`, `skipped`, or `cancelled`. |
| `actionResults` | Yes | Ordered action results. |
| `diagnostics` | No | Warnings or failure details. |
| `snapshotIds` | No | Snapshots created during the run. |

## Safety Rules

- Routines can be disabled.
- Disabled routines do not execute actions.
- Routine failures must not corrupt project state.
- Destructive routine actions require snapshot first.
- No arbitrary scripting is allowed.
- No plugin runtime is allowed.
- No network actions are allowed.
- Routines must use CommandEngine for mutations.
- Routine logs must not expose hidden or private data in Simple Mode contexts.

## Given/When/Then Examples

- Given a disabled routine, when its trigger fires, then no command requests are created and the run is skipped or not started according to future logging policy.
- Given a manual routine with `createSnapshot` and `addNote`, when the user runs it in Pro Mode, then CommandEngine receives a snapshot command followed by an add-note command.
- Given a routine includes `updateSceneStatus`, when CommandEngine validation fails, then the action is logged as failed and no direct project mutation occurs.
- Given a routine has `proModeEnabled`, when Simple Mode is active, then the routine conditions fail and actions do not execute.
- Given a destructive routine action requires a snapshot, when snapshot creation fails, then the destructive action does not execute.

## Data Model Implications

Routine definitions, triggers, conditions, actions, run logs, action results, and diagnostics require a future data contract. Routine definitions should be portable `.dreamjotter` data if project-specific. Built-in routines may be app resources but must still compile to the same definition structure.

## Storage Implications

Routine definitions may live in a `.dreamjotter` routines section when project-specific. Routine logs may be stored in bounded project logs or derived app metadata according to a future data contract. SwiftData may cache run summaries only if rebuildable or non-canonical.

## Testability

Future tests should cover:

- Disabled routine does not run.
- Manual trigger executes actions in order.
- Conditions gate execution.
- CommandEngine is called for every mutation action.
- No direct mutation occurs from routine runner.
- Failure produces run log.
- Snapshot failure prevents destructive action.
- Unsupported trigger, condition, or action fails validation.

## Related Specs

- `docs/milestones/milestone-4-pro-foundations.md`
- `docs/acceptance/milestone-4-acceptance.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
- `docs/constitution.md`
