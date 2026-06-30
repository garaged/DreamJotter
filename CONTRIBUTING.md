# Contributing

DreamJotter uses Spec Driven Development. Specs are binding project artifacts, not supporting notes. Product behavior, architecture boundaries, data contracts, acceptance criteria, executable specs, and implementation modules must trace back to documented requirement IDs.

## Constitution First

Read `docs/constitution.md` before changing specs or implementation.

Non-negotiable rules include:

- Apple-native UI first.
- Portable core always.
- Semantic screenplay model, not rich text only.
- `.dreamjotter` package is canonical project storage.
- SwiftData is not canonical storage.
- Core modules must not depend on SwiftUI, AppKit, UIKit, SwiftData, or CloudKit.
- Commands are the safe mutation boundary.
- Routines execute commands instead of directly mutating state.
- Plugins are future work and must not drive Milestone 1 through Milestone 4 design.
- AI suggestions must not mutate user text until accepted.
- Destructive or major automated actions require snapshots.

## Spec Change Workflow

For spec-only changes:

1. Identify the affected feature area in `docs/acceptance/traceability-matrix.md`.
2. Read the owning spec, related acceptance document, related data contract, and related ADRs.
3. Update the spec before or alongside acceptance criteria.
4. Update data contracts for persistent model, package, command, export, routine, or compatibility changes.
5. Add or update an ADR for architecture-changing decisions.
6. Update `specs/registry.yml` for new or moved specs.
7. Update `docs/acceptance/traceability-matrix.md` for new requirements, changed status, or changed module ownership.
8. Run `python3 scripts/spec-check`.
9. Run executable specs if present.
10. Capture future work in `TODO.md` or the relevant milestone spec.

For implementation changes:

1. Name the registry ID and traceability row being implemented.
2. Add or update executable specs first when behavior is testable.
3. Implement the minimum scoped behavior needed for the referenced spec.
4. Preserve architecture guardrails.
5. Run relevant tests and spec checks.
6. Do not expand behavior beyond documented requirements without updating specs first.

## Requirement ID Rules

Requirement IDs must be stable and readable.

Use these prefixes:

- `PRD-*` for product requirements.
- `M1-*`, `M2-*`, `M3-*`, `M4-*` for milestone-scoped behavior.
- `DATA-*` for data contracts.
- `EDITOR-*` for editor/parser behavior.
- `STORAGE-*` for `.dreamjotter` package and storage errors.
- `COMMAND-*` for command engine behavior.
- `ROUTINE-*` for routine system behavior.
- `PLUGIN-*` for deferred plugin model or extension points.
- `EXPORT-*` for export behavior.
- `AI-*` for AI abstraction behavior.
- `UX-*` for writing experience requirements.
- `EXECUTABLE-SPECS-*` for executable spec scaffolding.
- `SPEC-REVIEW-*` for consistency review artifacts.

Rules:

- Do not reuse an ID for different behavior.
- Do not rename an ID without updating registry, traceability, acceptance docs, and references.
- Prefer adding a new ID over changing the meaning of an existing accepted ID.
- Every implementation prompt should cite one or more IDs.

## Acceptance Criteria Rules

Acceptance criteria are required for user-facing behavior, data persistence behavior, command/routine behavior, import/export behavior, and architecture guardrails.

Acceptance criteria must include:

- Observable expected behavior.
- Given/When/Then examples where practical.
- Edge cases and malformed input behavior.
- Simple Mode and Pro Mode differences where relevant.
- Platform behavior where relevant.
- Storage and command implications where relevant.
- Non-goals and deferred scope.

Acceptance criteria must not rely only on comments, commit messages, or informal notes.

## Traceability Rules

Update `docs/acceptance/traceability-matrix.md` whenever a feature area, milestone, data contract, executable spec, planned module, or status changes.

Each traceability row should include:

- Product requirement ID.
- Milestone.
- Feature area.
- Spec document.
- Acceptance document.
- Data contract document if applicable.
- Future executable spec file.
- Planned implementation module.
- Status.
- Notes.

Status values:

- `specified`: documentation exists and is ready for executable spec or implementation planning.
- `executable-spec-pending`: behavior-specific executable specs still need to be written.
- `implementation-pending`: executable specs or implementation can be planned next.
- `deferred`: intentionally out of scope through Milestone 4.

## Registry Rules

Specs must be registered in `specs/registry.yml` before implementation begins.

Each registry entry must include:

- `id`
- `title`
- `milestone`
- `status`
- `spec`
- `acceptance`
- `related_adrs`
- `related_data_contracts`
- `planned_modules`
- `guardrails`
- `notes`

Run:

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
```

## Executable Spec Rules

Executable specs live in `Tests/DreamJotterExecutableSpecs/` and currently validate documentation and traceability. Future implementation prompts should add behavior-level executable specs before production code.

Executable specs should:

- Reference requirement IDs in test names or comments when useful.
- Use fixtures from `specs/fixtures/` where practical.
- Test portable core behavior before Apple UI adapters.
- Avoid creating production app features just to satisfy documentation checks.
- Fail when required specs, traceability rows, or architecture guardrails disappear.

Run executable specs with:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

Plain `swift test` may be sufficient outside restricted sandbox environments.

## Data Contracts

Data contracts are required for:

- Persistent canonical models.
- `.dreamjotter` package content.
- Import/export formats.
- Snapshots.
- Commands that persist state.
- Routine definitions and logs.
- Derived indexes that need compatibility rules.

Persistent canonical data must be defined as `.dreamjotter` package data unless an ADR explicitly says otherwise. SwiftData must not become canonical storage.

## ADRs

An ADR is required for architecture-changing decisions, including changes to:

- Platform strategy.
- Module boundaries.
- Storage strategy.
- Command/routine/plugin sequencing.
- AI provider boundaries.
- Cross-platform portability.
- Cloud sync or collaboration.
- Real PDF/FDX adapter commitments.

Use `docs/templates/adr-template.md` for new ADRs.

## Implementation Boundaries

Implementation should not invent product behavior that is absent from specs. If implementation reveals a missing rule, update the spec before or alongside code.

Do not implement during documentation-only prompts:

- Production app code.
- Xcode project.
- Production UI.
- TextKit wrappers.
- Plugin runtime.
- Real AI provider.
- Cloud sync.
- Full FDX support.
- Windows/Linux/Android app.

## Definition Of Done

A change is done when:

- Relevant specs, acceptance docs, data contracts, or ADRs are current.
- Specs are registered in `specs/registry.yml`.
- Traceability links the change to milestone, feature area, acceptance, executable specs, and planned modules.
- Acceptance criteria are observable.
- Data contracts exist for persistent model changes.
- Executable specs are added or updated when behavior is testable.
- Implementation, if any, follows cited registry IDs without expanding scope.
- `python3 scripts/spec-check` passes.
- Executable specs pass when present.
- Future work is captured in `TODO.md` or the relevant milestone document.
