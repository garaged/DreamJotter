# Future Plugin Model

Status: deferred
Milestone: Beyond M4
Traceability ID: PLUGIN-FUTURE-MODEL-001

## Purpose

This document defines the future plugin safety model without implementing a plugin runtime. Plugins are deferred beyond Milestone 4 and must not drive current DreamJotter architecture. Through Milestone 4, commands and routines provide the only planned extensibility model.

## Boundary

Plugins are future work. Early DreamJotter versions must not include:

- Plugin runtime.
- Arbitrary code execution.
- User-authored scripts.
- Third-party code loading.
- Plugin marketplace.
- Network-capable plugin actions.
- Plugin-owned project storage.
- Plugin-required readability for `.dreamjotter` projects.

## Future Plugin Principles

If plugins are introduced later, they must follow these principles:

- Future plugins call approved commands instead of mutating project internals.
- Future plugins must declare permissions before use.
- Future plugins must be disableable.
- Future plugins must not corrupt project files.
- Future plugins must not make canonical project data unreadable without the plugin.
- Future plugins must not bypass snapshots for destructive or major automated actions.
- Future plugins must produce diagnostics and logs suitable for troubleshooting.
- Future plugin architecture requires new ADRs and data contracts before implementation.

## No Arbitrary Code Execution In Early Versions

DreamJotter must not add an arbitrary scripting runtime through Milestone 4. This excludes embedded JavaScript, Python, shell scripts, Swift scripting, user-authored dynamic code, or third-party executable bundles.

The absence of arbitrary code execution is intentional. The safe sequence is:

1. Built-in commands.
2. Built-in no-code routines that execute commands.
3. Future plugin model that requests approved commands after separate security design.

## Future Plugin Command Boundary

A future plugin may request only approved command types through CommandEngine.

A future plugin command request must include:

| Field | Required | Purpose |
| --- | --- | --- |
| `pluginId` | Yes | Identifies the plugin. |
| `pluginVersion` | Yes | Identifies the plugin version. |
| `declaredPermissions` | Yes | Permissions the plugin declared. |
| `commandType` | Yes | Approved command requested. |
| `payload` | Yes | Portable command payload. |
| `userApproved` | Depends | Required for sensitive or destructive operations. |
| `requestedAt` | Yes | ISO-8601 timestamp. |

CommandEngine validates future plugin requests the same way it validates user, routine, and AI-acceptance commands, with additional permission checks.

## Permission Declaration

A future plugin must declare what it wants to do before it runs.

Possible future permission categories include:

| Permission | Meaning | Status |
| --- | --- | --- |
| `readProjectMetadata` | Read project title, settings, and non-content metadata. | Deferred. |
| `readScreenplay` | Read screenplay elements. | Deferred. |
| `writeNotes` | Request note creation commands. | Deferred. |
| `updateSceneMetadata` | Request scene metadata commands. | Deferred. |
| `exportProject` | Request export commands. | Deferred. |
| `runAnalysis` | Request analysis commands. | Deferred. |

Permission design requires a future ADR. This document only states that permissions are mandatory for any future plugin system.

## Disableability

Future plugins must be disableable by the user or app policy.

Rules:

- Disabled plugins cannot request commands.
- Disabling a plugin must not make a project unreadable.
- Canonical screenplay, notes, scenes, characters, and package data remain usable without plugins.
- Plugin-specific metadata, if ever allowed, must be optional and safely ignored when disabled.

## Project File Safety

Future plugins must not write directly into `.dreamjotter` package files. They must request commands or future approved extension-storage APIs.

Rules:

- Direct file mutation is rejected.
- Unknown plugin metadata must not hide or replace canonical project data.
- Plugin failure must not corrupt `manifest.json`, `project.json`, `screenplay.json`, or other canonical files.
- Destructive plugin-originated commands require snapshots.
- Plugin-originated errors must return stable diagnostics.

## Marketplace Out Of Scope

A plugin marketplace is out of scope. Future marketplace work would require separate specs for review, trust, signing, distribution, permissions, version compatibility, moderation, privacy, and support burden.

## Given/When/Then Scenarios

### Plugin Runtime Deferred

Given a Milestone 4 feature proposal requires a plugin runtime
When it is checked against this model
Then the feature is deferred
And no runtime, loader, marketplace, or arbitrary code execution is added.

### Plugin Requests Approved Command

Given a future plugin has declared `writeNotes`
When it requests the approved `addNote` command
Then CommandEngine validates the permission and payload
And the project changes only if validation succeeds.

### Plugin Tries Unsafe Mutation

Given a future plugin tries to modify `screenplay.json` directly
When the request reaches the plugin boundary
Then the request is rejected
And the `.dreamjotter` package remains unchanged.

### Plugin Requests Undeclared Permission

Given a future plugin declares only `runAnalysis`
When it requests `deleteScene`
Then CommandEngine rejects the request with a permission diagnostic
And no snapshot or mutation occurs.

### Plugin Disabled

Given a future plugin is disabled
When it attempts to request any command
Then the request is rejected
And project state remains unchanged.

## Required Future ADRs

Before any plugin implementation, DreamJotter requires ADRs for:

- Runtime architecture.
- Permission model.
- Sandboxing and process isolation.
- Signing and trust.
- Command registration boundaries.
- Storage compatibility.
- Marketplace or distribution, if ever pursued.
- Privacy and telemetry boundaries.

## Non-Goals

- No plugin runtime implementation.
- No plugin SDK.
- No plugin manifest schema.
- No arbitrary scripting.
- No plugin marketplace.
- No network permission design.
- No third-party code loading.

## Related Specs

- `docs/plugins/future-plugin-extension-points.md`
- `docs/architecture/command-engine-spec.md`
- `docs/routines/routine-system-v1-spec.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
- `docs/constitution.md`
