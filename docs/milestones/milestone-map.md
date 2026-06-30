# Milestone Map

This map summarizes the current Spec Driven Development path. The implementation navigation source of truth is `docs/acceptance/traceability-matrix.md`, which maps feature areas to specs, acceptance docs, data contracts, future executable specs, planned modules, and status.

## Milestone 0: SDD Foundation

Goal: Establish documentation structure, product direction, architecture decisions, templates, validation scripts, traceability, and executable spec scaffolding before product implementation.

Acceptance focus:

- Repository explains vision, workflow, layout, and current status.
- ADRs record Apple-native-first, `.dreamjotter`, and command sequencing decisions.
- `docs/constitution.md` captures non-negotiable architecture rules.
- `specs/registry.yml` indexes specs and validates with `scripts/spec-check`.
- `docs/acceptance/traceability-matrix.md` maps feature areas to implementation planning links.
- `Package.swift` and `Tests/DreamJotterExecutableSpecs/` provide documentation-focused executable specs.

## Milestone 1: Apple Prototype Foundations

Goal: Prove the core writing experience and portable architecture foundations before building advanced features.

Scope:

- Portable core module plan.
- Semantic screenplay model.
- Basic screenplay parser.
- Basic Fountain import/export.
- Local project creation concept.
- Editor behavior model, not full UI.
- Scene list foundation.
- Character autocomplete foundation.
- Location autocomplete foundation.
- PDF export abstraction.
- macOS/iPad/iPhone app shell expectations.
- Architecture guardrails.

Primary specs:

- `docs/milestones/milestone-1-apple-prototype-foundations.md`
- `docs/editor/screenplay-engine-spec.md`
- `docs/editor/fountain-support-spec.md`
- `docs/editor/editor-behavior-spec.md`
- `docs/data-contracts/core-domain-model.md`
- `docs/storage/dreamjotter-package-format.md`

Executable spec direction:

- `Tests/DreamJotterExecutableSpecs/Milestone1ExecutableSpecs.swift`

## Milestone 2: Real MVP Writer Organization

Goal: Make DreamJotter useful as a real writing app, not just a screenplay text editor.

Scope:

- Project dashboard.
- Character manager foundation.
- Scene cards.
- Notes system.
- Idea inbox.
- Search.
- Snapshots.
- Local `.dreamjotter` package save/load.
- Script health report.
- Starter templates.
- Export presets foundation.
- Simple Mode default behavior.
- Pro Mode hidden/disabled foundation.

Primary specs:

- `docs/milestones/milestone-2-real-mvp.md`
- `docs/specs/script-analysis-spec.md`
- `docs/storage/dreamjotter-package-format.md`
- `docs/export/export-system-spec.md`

Executable spec direction:

- `Tests/DreamJotterExecutableSpecs/Milestone2ExecutableSpecs.swift`

## Milestone 3: Friendly Writer Tools

Goal: Add beginner-friendly story-development tools and safe AI-assisted workflows.

Scope:

- Guided story setup.
- Logline builder.
- Synopsis builder.
- Beat sheet templates.
- Scene starter generation.
- AI abstraction with no real provider.
- AI suggestion workflow.
- Snapshot-before-AI-rewrite safety.
- Continuity warnings.
- Character consistency checks.
- Table-read/read-aloud data model.
- Friendly warning language.

Primary specs:

- `docs/milestones/milestone-3-friendly-writer-tools.md`
- `docs/ai/ai-abstraction-spec.md`
- `docs/specs/continuity-analysis-spec.md`
- `docs/specs/table-read-spec.md`

Executable spec direction:

- `Tests/DreamJotterExecutableSpecs/Milestone3ExecutableSpecs.swift`

## Milestone 4: Pro Apple Version Foundations

Goal: Define pro features without compromising beginner usability or portable core architecture.

Scope:

- Revision colors.
- Draft versions.
- Draft comparison.
- Production breakdown.
- Advanced export presets.
- Custom fields.
- Routine system v1.
- Routine runner safety.
- Command-engine integration.
- Pro Mode visibility.
- Future plugin extension points only.

Primary specs:

- `docs/milestones/milestone-4-pro-foundations.md`
- `docs/architecture/command-engine-spec.md`
- `docs/routines/routine-system-v1-spec.md`
- `docs/plugins/future-plugin-extension-points.md`
- `docs/plugins/future-plugin-model.md`
- `docs/export/export-system-spec.md`

Executable spec direction:

- `Tests/DreamJotterExecutableSpecs/Milestone4ExecutableSpecs.swift`

## Deferred Beyond Milestone 4

Deferred scope:

- Full plugin runtime.
- Plugin marketplace.
- Arbitrary scripting or arbitrary code execution.
- Real AI provider integration.
- Cloud sync.
- Full FDX support.
- Native Windows/Linux/Android apps.
- Final production UI implementation.

Deferred work remains documented only where useful for guardrails and must not drive Milestone 1 through Milestone 4 architecture.

## Validation Commands

Use these checks after spec or traceability changes:

```bash
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```
