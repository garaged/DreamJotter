# Future Plugin Extension Points

## Purpose

This document identifies possible future plugin extension points without implementing a plugin runtime. Plugins are future work and must not drive Milestone 1-4 design.

## Milestone 4 Boundary

Milestone 4 allows documentation of future extension surfaces only. It does not allow:

- Plugin runtime.
- Plugin marketplace.
- Arbitrary code execution.
- User-authored scripts.
- Third-party code loading.
- Network-capable plugins.
- Plugin-required project readability.
- Plugin-owned mutation of project internals.

## Architectural Rules

Future plugins, if ever added, must obey these rules:

- Commands remain the mutation boundary.
- Plugins cannot directly mutate `.dreamjotter` package internals.
- Routines remain command orchestration, not plugin execution.
- Core project data must remain readable without plugins.
- Plugin failures must not corrupt project state.
- Plugin permissions, signing, sandboxing, and review require future ADRs.
- Simple Mode must not expose plugin controls by default.

## Possible Future Extension Points

These are candidate extension points only:

| Extension Point | Possible Future Use | Milestone 4 Status |
| --- | --- | --- |
| Commands | Register new safe command types after review. | Deferred. |
| Export adapters | Add new export targets. | Deferred. |
| Analysis rules | Add custom health or continuity checks. | Deferred. |
| Templates | Add story or project templates. | Deferred. |
| Custom field schemas | Provide predefined field sets. | Deferred. |
| Routine action catalogs | Add approved no-code action types. | Deferred. |
| Import adapters | Add import formats. | Deferred. |

## Explicit Non-Goals

- No plugin package format.
- No plugin SDK.
- No extension manifest.
- No plugin permissions model.
- No plugin loader.
- No scripting engine.
- No marketplace metadata.
- No network access model.
- No dependency system.

## Given/When/Then Guardrails

- Given a proposed Milestone 4 feature requires arbitrary plugin code, when checked against this document, then the feature is rejected or deferred.
- Given a future plugin wants to change screenplay content, when future architecture is designed, then the change must be expressed as a command request.
- Given a `.dreamjotter` project contains future plugin metadata, when opened without that plugin, then canonical screenplay and project data must remain readable according to future compatibility rules.
- Given Simple Mode is active, when future plugin concepts exist, then plugin controls remain hidden by default.

## Data Model Implications

Milestone 4 introduces no plugin data model. Future plugin metadata requires data contracts and ADRs before implementation.

## Storage Implications

Milestone 4 introduces no plugin runtime storage. `.dreamjotter` packages must not require plugin code to understand canonical screenplay content.

## Safety Rules

- No arbitrary scripting.
- No direct mutation.
- No network actions.
- No third-party code execution.
- No plugin-first design.
- No required plugin for project readability.

## Future ADRs Required

Future plugin work requires ADRs for:

- Runtime architecture.
- Security model.
- Permission model.
- Signing and trust.
- Marketplace or distribution.
- Compatibility and project portability.
- Command registration boundaries.

## Related Specs

- `docs/milestones/milestone-4-pro-foundations.md`
- `docs/routines/routine-system-v1-spec.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
- `docs/constitution.md`
