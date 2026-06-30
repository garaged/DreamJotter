# Contributing

DreamJotter uses Spec Driven Development. Specs are binding project artifacts, not supporting notes.

## Constitution First

Read `docs/constitution.md` before changing specs or implementation. The constitution defines non-negotiable rules: Apple-native UI first, portable core always, semantic screenplay model, `.dreamjotter` canonical storage, SwiftData derived-only, commands before routines before plugins, accepted AI suggestions only, and snapshots for destructive or major automated actions.

## How To Write Specs

Write specs for both product and engineering readers. Every feature spec should include:

- User goal.
- Scope.
- Non-goals.
- User-facing behavior.
- Acceptance criteria.
- Given/When/Then examples where useful.
- Edge cases.
- Data model implications.
- Storage implications.
- Command implications.
- Testability notes.
- Platform implications.
- Future cross-platform implications.

Use `docs/templates/feature-spec-template.md` for new feature specs unless a more specific template exists. Avoid vague terms such as "easy", "fast", or "smart" unless the spec defines observable behavior.

Separate beginner workflows from advanced controls. Simple Mode should stay understandable for new screenplay writers. Pro Mode may expose specialized features without forcing them into the beginner path.

## Registry Requirements

Specs must be registered in `specs/registry.yml` before implementation begins. Each registry entry should include:

- Stable ID.
- Title.
- Milestone.
- Status.
- Spec path.
- Acceptance path when known.
- Related ADRs when known.
- Related data contracts when known.
- Planned modules.
- Guardrails.
- Notes.

Implementation must trace back to registry IDs. Pull requests or implementation prompts should name the registry IDs they satisfy.

## Updating Acceptance Criteria

Acceptance criteria are required for feature behavior. They must be specific enough to become tests later. Each criterion should identify:

- The user or system action.
- The expected observable result.
- Any relevant data state.
- Mode differences between Simple Mode and Pro Mode.
- Platform differences, if any.

When behavior changes, update the acceptance criteria in the same change as the spec. Do not leave implementation expectations only in comments, issues, or commit messages.

## Data Contracts

Data contracts are required for persistent models, `.dreamjotter` package content, import/export formats, snapshots, commands that persist state, and derived indexes that need compatibility rules.

Use `docs/templates/data-contract-template.md` for new contracts. Persistent canonical data must be defined as `.dreamjotter` package data unless an ADR explicitly says otherwise. SwiftData must not become canonical storage.

## ADRs

An ADR is required for architecture-changing decisions, including changes to platform strategy, module boundaries, storage strategy, command/routine/plugin sequencing, AI provider boundaries, or cross-platform portability.

Use `docs/templates/adr-template.md` for new ADRs.

## Maintaining Traceability

Update `docs/acceptance/traceability-matrix.md` and `specs/registry.yml` whenever a new requirement, milestone, ADR, data contract, or acceptance criterion is added.

Traceability should answer:

- Which requirement or decision introduced this behavior?
- Which registry ID owns it?
- Which milestone owns it?
- Which acceptance criteria validate it?
- Which future implementation or tests should cover it?

Run before implementation:

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
```

## Implementation Follows Specs

Implementation should not invent product behavior that is absent from specs. If implementation reveals a missing rule, update the spec before or alongside the code change.

The canonical project format is `.dreamjotter`. Do not make SwiftData the source of truth for projects or screenplay content. The screenplay model must be semantic, not merely rich text with formatting spans.

Plugins are future work. Build command concepts first, routine automation second, and plugin extension points only after those surfaces are proven by specs and implementation.

## Definition Of Done

A change is done when:

- Relevant specs or ADRs are created or updated.
- Specs are registered in `specs/registry.yml`.
- Acceptance criteria are observable and current.
- Data contracts exist for persistent model changes.
- Traceability links the change to milestones and validation.
- Implementation, if any, follows registry IDs without expanding scope.
- Tests or validation notes exist where appropriate.
- `python3 scripts/spec-check` passes.
- No production app code is introduced during documentation-only prompts.
- Future work is captured in `TODO.md` or the relevant milestone document.
