# Routine System v1 Spec

Status: specified
Milestone: M4
Traceability IDs: M4-ROUTINES-001, M4-ROUTINE-RUNNER-001, ROUTINE-SYSTEM-001

## Purpose

Routine System v1 defines no-code automation for DreamJotter Pro Mode. Routines orchestrate approved commands through CommandEngine. They do not execute arbitrary scripts, run plugins, call networks, or mutate project internals directly.

Routine v1 exists to let advanced users automate safe repetitive workflows without forcing beginners to understand automation and without introducing a plugin runtime too early.

## Scope

Routine v1 includes:

- No-code routine definitions.
- Supported triggers.
- Supported conditions.
- Supported actions.
- Enabled/disabled state.
- Routine run logs.
- Failure behavior.
- Snapshot-before-destructive-action policy.
- CommandEngine-only mutation.
- Simple Mode and Pro Mode visibility rules.

Routine v1 excludes:

- Arbitrary scripting.
- Plugin execution.
- Network actions.
- Cross-project automation.
- Background daemon behavior.
- User-authored code.
- Marketplace distribution.

## No-Code Routine Definition

A routine is structured project data. It is not code.

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable routine ID. |
| `title` | Yes | User-visible name. |
| `description` | No | Short explanation of routine behavior. |
| `enabled` | Yes | Whether the routine can run. |
| `trigger` | Yes | One supported trigger. |
| `conditions` | No | Ordered conditions that must pass before actions run. |
| `actions` | Yes | Ordered supported actions. |
| `failurePolicy` | No | Stop-on-failure by default; continuation policies are deferred. |
| `createdAt` | Yes | ISO-8601 creation timestamp. |
| `updatedAt` | Yes | ISO-8601 last update timestamp. |

Routine definitions must be Codable-compatible, Equatable where practical, and Sendable where practical when implemented in Swift. They must not require SwiftUI, AppKit, UIKit, SwiftData, CloudKit, scripting engines, or plugin APIs.

## Trigger

A trigger describes when a routine is considered for execution. It does not mutate state by itself.

Supported triggers:

| Trigger | Description |
| --- | --- |
| `manual` | User starts the routine explicitly. |
| `sceneStatusChanged` | Scene status changes through CommandEngine. |
| `beforeExport` | Export command is about to execute. |
| `afterExport` | Export command completed. |
| `beforeAIRewrite` | AI rewrite acceptance is about to create a snapshot and apply mutation. |

Unsupported triggers fail validation and must not execute actions.

## Condition

A condition gates routine execution. All conditions must pass before the first action runs.

Supported conditions:

| Condition | Description |
| --- | --- |
| `sceneStatusEquals` | Runs only when a relevant scene status matches the configured value. |
| `projectHasOpenTODOs` | Runs only when project analysis finds unresolved TODO notes. |
| `proModeEnabled` | Runs only when Pro Mode is active. |

Condition evaluation must be read-only. Persisting analysis findings requires CommandEngine.

## Action

An action is a no-code instruction that compiles to one or more approved command requests or read-only analysis steps.

Supported actions:

| Action | Description | Mutation | Command Boundary | Snapshot Policy |
| --- | --- | --- | --- | --- |
| `createSnapshot` | Creates a project snapshot. | Yes | `createSnapshot` command. | Not required before itself. |
| `addNote` | Adds a note to project, scene, or character target. | Yes | `addNote` command. | Required only if configured as destructive replacement later. |
| `runAnalysis` | Runs read-only health or continuity analysis. | No by default. | `runAnalysis` placeholder or read-only analysis. | Not required. |
| `updateSceneStatus` | Updates scene status field. | Yes | `updateSceneStatus` command. | Required if bulk or destructive by command policy. |
| `exportProject` | Placeholder for export action. | Maybe | `exportProject` placeholder command. | Depends on overwrite/export target policy later. |

Routine actions must not write `.dreamjotter` files directly. They must not mutate in-memory project internals directly.

## Enabled Flag

The `enabled` flag controls whether a routine can run.

Rules:

- Disabled routines do not execute actions.
- Disabled routines may still be visible in Pro Mode routine management.
- Trigger events may record a skipped log entry if logging policy enables skipped-run logs.
- Simple Mode should not expose routine enablement controls by default.

## Routine Logs

Each routine run produces a log when execution is attempted or when skipped-run logging is enabled.

| Field | Required | Description |
| --- | --- | --- |
| `runId` | Yes | Stable run ID. |
| `routineId` | Yes | Routine definition ID. |
| `trigger` | Yes | Trigger that started or considered the run. |
| `startedAt` | Yes | ISO-8601 start timestamp. |
| `endedAt` | No | ISO-8601 end timestamp when complete. |
| `status` | Yes | `succeeded`, `failed`, `skipped`, or `cancelled`. |
| `conditionResults` | No | Ordered condition results. |
| `actionResults` | Yes | Ordered action/command results. |
| `diagnostics` | No | Warnings or failure details. |
| `snapshotIds` | No | Snapshots created during the run. |

Logs should be bounded by future retention policy. SwiftData may cache log summaries later only if canonical project behavior does not depend on that cache.

## Failure Behavior

Failure must preserve valid project state.

Rules:

- Validation failures stop execution before mutation.
- Command failures stop the routine by default.
- Partial success must be visible in logs.
- Routine failure must not directly roll back successful earlier commands unless future command/transaction policy supports it.
- Snapshot failure prevents destructive action execution.
- Unsupported triggers, conditions, or actions fail validation.
- Failures must use stable diagnostics suitable for future UI and tests.

## Snapshot Before Destructive Actions

Destructive or major automated actions require a snapshot first. The routine runner may either include an explicit `createSnapshot` action or rely on CommandEngine snapshot policy.

Snapshot is required before:

- Destructive `updateSceneStatus` variants.
- Any future action that deletes, replaces, or bulk rewrites screenplay content.
- `beforeAIRewrite` actions that would apply accepted AI text changes.
- Future plugin-originated routine-like command requests.

If snapshot creation fails, the destructive action must not execute.

## CommandEngine-Only Mutation

Routine execution order:

1. Resolve trigger context.
2. Verify routine is enabled.
3. Validate routine definition.
4. Evaluate conditions read-only.
5. Validate action list.
6. Convert each mutation action into a command request.
7. Ask CommandEngine to validate and execute each command.
8. Record command results in routine logs.
9. Stop on failure unless future policy explicitly allows continuation.

The routine runner must not mutate project models, storage files, SwiftData cache, indexes, or UI state directly.

## Simple Mode Visibility

Simple Mode behavior:

- Routine creation and editing are hidden by default.
- Existing routines do not surface as beginner-facing concepts.
- Routines with automatic triggers may still run only if enabled and safe, according to future product policy.
- Routine logs and diagnostics should not interrupt beginner writing flows.
- Simple Mode must preserve routine definitions in project data without requiring users to understand them.

## Pro Mode Visibility

Pro Mode behavior:

- Users may view, create, disable, and manually run routines.
- Routine action lists are presented as approved no-code choices.
- Validation problems are explained before execution where practical.
- Logs are visible for troubleshooting.
- Destructive actions must clearly indicate snapshot behavior.

## Given/When/Then Scenarios

### Routine Disabled

Given a routine is disabled
When its trigger fires
Then no command requests are created
And the routine is skipped or not logged according to logging policy
And project state remains unchanged.

### Routine Manually Run

Given a Pro Mode user manually runs an enabled routine with `createSnapshot` and `addNote`
When the routine runner executes it
Then CommandEngine receives a `createSnapshot` command followed by an `addNote` command
And the routine log records both action results.

### Routine Triggered Before Export

Given an enabled routine has trigger `beforeExport` and action `runAnalysis`
When an export is requested
Then the routine evaluates its conditions before export proceeds
And read-only analysis may run before the `exportProject` placeholder command.

### Routine Failure

Given a routine includes `updateSceneStatus`
When CommandEngine rejects the command during validation
Then the routine stops by default
And the routine log records a failed action
And no direct project mutation occurs.

### Snapshot Failure Before Destructive Action

Given a routine action requires a snapshot
When snapshot creation fails
Then the destructive action does not run
And the routine log records the snapshot failure.

### Simple Mode Hidden

Given Simple Mode is active
When routine definitions exist in the project
Then routine management controls remain hidden
And the project remains readable and editable.

## Data Model Implications

Routine definitions, triggers, conditions, actions, run logs, action results, and diagnostics are part of the portable core model direction in `docs/data-contracts/core-domain-model.md`. Project-specific routines belong in the `.dreamjotter` package. Built-in routines may be app resources but must compile to the same definition structure.

## Storage Implications

Routine definitions may live in `routines.json` inside the `.dreamjotter` package. Routine logs may be stored as bounded project logs or derived app metadata according to a future retention decision. SwiftData must not be required to recover routine definitions.

## Testability

Future executable specs should cover:

- Disabled routine does not run.
- Manual trigger executes actions in order.
- `beforeExport` trigger runs before export action.
- Conditions gate execution.
- CommandEngine is called for every mutation action.
- No direct mutation occurs from the routine runner.
- Failure produces run log.
- Snapshot failure prevents destructive action.
- Unsupported trigger, condition, or action fails validation.

## Non-Goals

- No production routine runner implementation.
- No UI for routine editing.
- No arbitrary scripting.
- No plugin execution.
- No marketplace.
- No network routine actions.
- No cross-project automation.

## Related Specs

- `docs/architecture/command-engine-spec.md`
- `docs/milestones/milestone-4-pro-foundations.md`
- `docs/acceptance/milestone-4-acceptance.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
- `docs/constitution.md`
