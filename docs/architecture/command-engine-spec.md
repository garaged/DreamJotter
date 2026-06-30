# Command Engine Spec

Status: specified
Milestone: M1-M4
Traceability ID: COMMAND-ENGINE-001

## Purpose

The CommandEngine is DreamJotter's safe mutation boundary. Any feature that changes canonical project state must express the change as a validated command request. This includes editor actions, project organization tools, AI suggestion acceptance, routines, and future plugin integrations.

Commands exist so DreamJotter can keep mutation explicit, testable, undoable where practical, snapshot-aware, and independent from UI frameworks or arbitrary automation code.

## Why Commands Exist

Commands provide:

- A single validation point before project mutation.
- A predictable mutation history for undo, diagnostics, and future recovery.
- A stable integration boundary for routines and future plugins.
- A place to enforce snapshot-before-destructive-action policy.
- A way to keep portable core behavior independent from SwiftUI, AppKit, UIKit, SwiftData, CloudKit, plugins, or AI providers.
- A testable contract for all user-facing mutations.

Commands must not be confused with UI actions. UI adapters may request commands, but CommandEngine owns validation and mutation rules.

## Command Execution Model

A command request contains:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable request ID for tracing and idempotency checks where practical. |
| `type` | Yes | Command type such as `createScene` or `addNote`. |
| `payload` | Yes | Portable JSON-compatible command data. |
| `origin` | Yes | Source such as `user`, `routine`, `aiAcceptance`, `import`, or future `plugin`. |
| `requestedAt` | Yes | ISO-8601 timestamp. |
| `requiresSnapshot` | No | Explicit snapshot requirement when caller already knows the risk. |
| `traceabilityIds` | No | Related spec or acceptance IDs. |

Execution flow:

1. Receive command request.
2. Validate command type and payload schema.
3. Validate project state preconditions.
4. Validate safety policy and permissions for the origin.
5. Create a snapshot first when policy requires it.
6. Apply the mutation to canonical semantic project data.
7. Produce a `CommandResult`.
8. Append a `CommandHistoryEntry` when the command is accepted for execution.
9. Return diagnostics to caller without exposing internal mutable references.

## Validation

Validation must happen before mutation. It includes:

- Command type is known and enabled.
- Payload fields exist and use expected types.
- Referenced project, scene, character, note, snapshot, or export IDs exist where required.
- The command origin is allowed to request the command.
- The command is safe in the current mode and project state.
- Snapshot policy is satisfied for destructive or major automated actions.
- Future plugin callers have declared permission for the requested command.

Validation failure returns a failed `CommandResult` and must not mutate project state.

## CommandResult

A `CommandResult` is a portable response object.

| Field | Required | Purpose |
| --- | --- | --- |
| `commandId` | Yes | ID of the command request. |
| `type` | Yes | Command type executed or rejected. |
| `status` | Yes | `succeeded`, `failed`, `rejected`, or `cancelled`. |
| `snapshotId` | No | Snapshot created before mutation, when applicable. |
| `affectedIds` | No | IDs of changed project records. |
| `diagnostics` | No | Stable warnings or errors. |
| `undoToken` | No | Opaque undo support data, when available. |
| `completedAt` | Yes | ISO-8601 completion timestamp. |

`CommandResult` must not contain platform UI objects or direct mutable references to project internals.

## CommandHistoryEntry

A `CommandHistoryEntry` records accepted command execution for traceability and recovery.

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable history entry ID. |
| `commandId` | Yes | Original command request ID. |
| `type` | Yes | Command type. |
| `origin` | Yes | Source of the command request. |
| `payloadSummary` | Yes | Safe summary suitable for logs. |
| `status` | Yes | Final command status. |
| `snapshotId` | No | Snapshot created before mutation. |
| `affectedIds` | No | Changed records. |
| `diagnostics` | No | Errors or warnings. |
| `createdAt` | Yes | ISO-8601 timestamp. |

Sensitive data should be redacted from summaries where future privacy rules require it.

## Undo Strategy

Undo is command-specific. A command may support undo when the engine can produce a safe inverse operation or preserve enough prior state.

Rules:

- Undo must use CommandEngine or a dedicated undo path governed by the same safety policy.
- Destructive commands should prefer snapshot restore when exact inverse behavior is risky.
- Routines and future plugins must not bypass undo policy.
- Undo availability must be explicit in `CommandResult`.
- Undo must preserve Unicode and semantic screenplay structure.

Initial undo support may be limited to simple commands. Lack of undo must be visible to callers so UI can avoid promising unsupported behavior.

## Snapshot Strategy

Snapshots protect writers from destructive or major automated changes.

A snapshot is required before:

- `deleteScene`.
- Bulk or destructive `updateSceneStatus` operations.
- `applyAISuggestion` when it rewrites existing user text.
- Future routine actions marked destructive.
- Future plugin-originated mutations that affect screenplay content or project structure.

Snapshot failure blocks the destructive command. The command must return a failed `CommandResult` and leave canonical project state unchanged.

## Error Handling

Command errors use stable diagnostics and must preserve project integrity.

Error categories include:

| Category | Example |
| --- | --- |
| `validationFailed` | Missing required payload field. |
| `notFound` | Scene ID does not exist. |
| `permissionDenied` | Future plugin lacks required permission. |
| `snapshotRequired` | Destructive command requested without snapshot policy. |
| `snapshotFailed` | Snapshot creation failed. |
| `conflict` | Command preconditions no longer match project state. |
| `unsupported` | Placeholder command not implemented yet. |
| `internalFailure` | Unexpected engine failure after validation. |

Unexpected failures must not leave partial direct mutations. Implementation should prefer transactional mutation or rollback through snapshots when available.

## Commands As Safe Mutation Boundary

All mutation-capable systems must use CommandEngine:

- Editor behavior.
- Project dashboard and organization tools.
- Notes and idea inbox changes.
- Snapshot creation.
- Export state changes.
- AI suggestion acceptance.
- Routine actions.
- Future plugins.

Systems that may read project state do not need commands for read-only analysis, but any persisted result must be written through a command.

## Required Commands

| Command | Purpose | Snapshot Policy | Notes |
| --- | --- | --- | --- |
| `createScene` | Creates a semantic scene and related screenplay element(s). | Not required by default. | Validates insertion point and scene heading text. |
| `deleteScene` | Removes or archives a scene and related scene-owned data according to future policy. | Required. | Must preserve recoverability through snapshot. |
| `renameCharacter` | Renames a character record and optionally updates linked cues by explicit scope. | Required when changing screenplay text. | Must preserve Unicode and aliases. |
| `addNote` | Adds a project, scene, character, or element-linked note. | Not required by default. | Must validate target if provided. |
| `updateSceneStatus` | Changes scene status metadata. | Required for bulk/destructive changes only. | Used by routines. |
| `createSnapshot` | Creates a snapshot of current canonical project state. | Not required before itself. | May be called directly or by policy. |
| `exportProject` | Placeholder for export command intent. | Depends on overwrite target policy. | May initially return `unsupported` until export implementation exists. |
| `runAnalysis` | Placeholder for health/continuity analysis request. | Not required for read-only analysis. | Persisted findings require a follow-up command. |
| `applyAISuggestion` | Placeholder for applying accepted AI suggestion. | Required when changing user-authored text. | Must reject unaccepted suggestions. |

## Command Details

### createScene

Validation:

- Project exists.
- Scene heading text is present or generated from valid location/time data.
- Insertion point is valid.

Result:

- Creates scene and screenplay elements.
- Returns affected scene/element IDs.

### deleteScene

Validation:

- Scene exists.
- Snapshot can be created first.
- Caller has permission to delete.

Result:

- Deletes, archives, or marks scene removed according to future storage policy.
- Returns snapshot ID and affected IDs.

### renameCharacter

Validation:

- Character exists.
- New name is non-empty Unicode text.
- Optional screenplay cue updates have explicit scope.

Result:

- Updates character metadata.
- Optionally updates selected semantic character cue elements through explicit accepted scope.

### addNote

Validation:

- Note text is present.
- Optional target ID exists.

Result:

- Creates a note record and links it where applicable.

### updateSceneStatus

Validation:

- Scene exists.
- New status is in supported status set.
- Bulk status changes satisfy snapshot policy.

Result:

- Updates scene status metadata and records affected scene ID.

### createSnapshot

Validation:

- Project can serialize canonical state.
- Snapshot storage target is available.

Result:

- Creates a snapshot and returns snapshot ID.

### exportProject Placeholder

Validation:

- Export preset or intent is valid.
- Export destination policy is satisfied.

Result:

- May return `unsupported` until export implementation exists.
- Later produces export artifacts without making exports canonical state.

### runAnalysis Placeholder

Validation:

- Requested analysis kind is known.
- Analysis is read-only unless a follow-up persist command is requested.

Result:

- Returns findings or `unsupported` until implemented.

### applyAISuggestion Placeholder

Validation:

- AI feature is enabled.
- Suggestion exists and is explicitly accepted.
- Mutation scope is explicit.
- Snapshot succeeds before text mutation.

Result:

- Applies accepted suggestion through semantic mutation only.
- Rejected or pending suggestions produce no mutation.

## Future Plugin Compatibility

Future plugins, if ever introduced, may request approved commands only. They must not mutate project internals, write `.dreamjotter` files directly, or bypass validation.

Future plugin command requests must include:

- Plugin identity.
- Declared permission set.
- Command type.
- Payload.
- User approval status where required.

Unsafe or undeclared plugin command requests must be rejected with `permissionDenied` or `unsupported` diagnostics.

## Given/When/Then Examples

### Valid Command

Given a project is open and a valid `addNote` command is requested
When CommandEngine validates and executes it
Then the note is added through canonical project mutation
And a `CommandResult` reports success.

### Validation Failure

Given a `deleteScene` command references a missing scene ID
When CommandEngine validates the command
Then no mutation occurs
And the result reports `failed` with a `notFound` diagnostic.

### Snapshot Failure

Given `deleteScene` requires a snapshot
When snapshot creation fails
Then the scene remains unchanged
And CommandEngine returns a failed result.

### Future Plugin Unsafe Mutation

Given a future plugin requests direct file mutation outside approved commands
When the request reaches the command boundary
Then the request is rejected
And project files remain unchanged.

## Non-Goals

- No production command implementation.
- No Swift package creation in this prompt.
- No UI command palette implementation.
- No real export engine.
- No real AI provider integration.
- No routine runner implementation.
- No plugin runtime or arbitrary scripting.

## Related Specs

- `docs/constitution.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
- `docs/routines/routine-system-v1-spec.md`
- `docs/plugins/future-plugin-model.md`
- `docs/data-contracts/core-domain-model.md`
