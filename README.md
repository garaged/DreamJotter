# DreamJotter

DreamJotter is a screenplay and movie-script writing app for non-programmers. It is designed to let beginners write, organize, and export scripts without learning technical tooling, while still leaving room for optional Pro Mode workflows such as revision colors, draft comparison, production breakdown, custom fields, export presets, and no-code routines.

Implementation has not started yet. This repository currently contains the Spec Driven Development baseline through Milestone 4, plus a SwiftPM executable-spec skeleton that validates documentation and traceability. There is no production app code, Xcode project, production UI, TextKit editor, plugin runtime, real AI provider, cloud sync, or external service integration.

## Product Direction

DreamJotter is built around a semantic screenplay model, not plain rich text. Scenes, action, character cues, dialogue, parentheticals, transitions, notes, outline data, and future production metadata must be represented as meaningful project data that can be parsed, validated, searched, exported, analyzed, and automated.

The product uses progressive complexity:

- Simple Mode is the default beginner workflow.
- Pro Mode exposes advanced controls only when they are useful and safe.

## Platform Direction

Priority platforms:

1. macOS first.
2. iPadOS and iOS second.
3. Linux, Windows, and Android later.

DreamJotter is Apple-native first with a portable core. Apple UI may use SwiftUI, AppKit, UIKit, and TextKit adapters later, but core domain behavior must remain independent from Apple UI frameworks.

## Architecture Guardrails

Core rules:

- `.dreamjotter` is the canonical local-first project package.
- SwiftData may be used later only for app metadata, recents, cache, UI state, or rebuildable indexes.
- SwiftData is not canonical project storage.
- Commands are the safe mutation boundary.
- Routines execute commands and do not mutate project internals directly.
- Plugins are deferred beyond Milestone 4 and must not drive MVP architecture.
- AI suggestions never mutate user text until accepted.
- Real AI providers are out of scope through Milestone 4.
- PDF export is currently an abstraction; real PDF rendering is future adapter work.

## How Specs Are Organized

Key SDD files:

- `docs/constitution.md`: non-negotiable project rules.
- `docs/vision/`: product vision, personas, principles.
- `docs/architecture/`: architecture overview, portable core, command engine, Apple-native direction.
- `docs/adr/`: accepted architecture decisions.
- `docs/milestones/`: Milestone 1 through Milestone 4 specs and milestone map.
- `docs/acceptance/`: acceptance documents, traceability matrix, consistency review notes.
- `docs/data-contracts/`: portable core data contracts and serialization rules.
- `docs/editor/`: screenplay engine, Fountain support, and editor behavior specs.
- `docs/storage/`: `.dreamjotter` package format and storage errors.
- `docs/export/`: export system behavior.
- `docs/ai/`: AI abstraction and FakeAIProvider boundary.
- `docs/routines/`: no-code routine system v1.
- `docs/plugins/`: future plugin boundaries only.
- `docs/specs/`: product requirements and analysis/table-read specs.
- `docs/ux/`: writing experience principles.
- `specs/registry.yml`: machine-readable spec registry.
- `specs/fixtures/`: screenplay fixture inputs for future parser tests.
- `Tests/DreamJotterExecutableSpecs/`: executable documentation specs.

## Milestone Status

| Milestone | Status | Notes |
| --- | --- | --- |
| Milestone 0 | Specified | SDD foundation, constitution, registry, templates, traceability, and executable-spec skeleton exist. |
| Milestone 1 | Specified | Apple prototype foundations, semantic screenplay model, parser/Fountain/editor behavior, package format, and architecture guardrails are documented. |
| Milestone 2 | Specified | Real MVP writer organization is documented: dashboard, characters, scene cards, notes, idea inbox, search, snapshots, package load/save, health report, templates, and mode foundation. |
| Milestone 3 | Specified | Friendly writer tools, FakeAIProvider-only AI abstraction, continuity analysis, and table-read data model are documented. |
| Milestone 4 | Specified | Pro foundations, command engine, routine system v1, advanced export/customization, and future plugin boundaries are documented. |

Implementation status: `implementation-pending`. The only Swift code currently present is `SpecSupport` for executable spec checks.

## Spec Workflow

1. Read `docs/constitution.md`.
2. Find the owning row in `docs/acceptance/traceability-matrix.md`.
3. Check `specs/registry.yml` for the registry ID and planned modules.
4. Update specs, acceptance criteria, data contracts, and ADRs before implementation changes.
5. Add or update executable specs when behavior is ready to be tested.
6. Keep implementation scoped to documented registry IDs.

## Validation Commands

Run registry checks:

```sh
python3 scripts/spec-check
```

View traceability grouped by milestone:

```sh
python3 scripts/spec-trace
```

Create a new spec from the feature template:

```sh
python3 scripts/spec-new PRD-EDITOR-002 "Editor Commands" M2 docs/specs/editor-commands.md
```

Run executable documentation specs:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

Plain `swift test` may work in a normal shell. The command above redirects SwiftPM scratch/cache paths for restricted sandbox environments.

## Repo Layout

```text
DreamJotter/
  AGENTS.md
  README.md
  CONTRIBUTING.md
  TODO.md
  Package.swift
  Sources/
    SpecSupport/
  Tests/
    DreamJotterExecutableSpecs/
  docs/
    constitution.md
    vision/
    architecture/
    adr/
    milestones/
    acceptance/
    specs/
    data-contracts/
    editor/
    storage/
    export/
    routines/
    ai/
    plugins/
    ux/
    templates/
  specs/
    registry.yml
    fixtures/
  scripts/
    spec-check
    spec-new
    spec-trace
```
