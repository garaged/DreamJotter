# DreamJotter

DreamJotter is a screenplay and movie-script writing app for non-programmers. It is designed to let beginners write, organize, and export scripts without learning technical tooling, while still leaving room for optional Pro Mode workflows such as revision colors, draft comparison, production breakdown, custom fields, export presets, and no-code routines.

Milestone 1 through Milestone 4 portable-core foundations are implemented and covered by executable specs. Milestone 5 adds the first launchable macOS SwiftUI app shell as a package executable target. There is no TextKit editor, plugin runtime, real AI provider, cloud sync, or external service integration.

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
- `docs/milestones/`: Milestone 1 through Milestone 5 specs and milestone map.
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
- `Apps/DreamJotterMac/`: first macOS SwiftUI app shell.

## Milestone Status

| Milestone | Status | Notes |
| --- | --- | --- |
| Milestone 0 | Specified | SDD foundation, constitution, registry, templates, traceability, and executable-spec skeleton exist. |
| Milestone 1 | Accepted | Portable-core foundations are implemented and executable-spec verified: semantic screenplay model, parser, supported Fountain import/export, editor behavior model basics, scene/autocomplete derivations, blank project package concept, export intent, semantic validation, and architecture guardrails. |
| Milestone 2 | Accepted | Portable writer organization is implemented and executable-spec verified: dashboard summaries, templates, characters, scene cards, notes, idea inbox, search, snapshots, `.dreamjotter` package save/load, health report, export presets, and Simple Mode policy. |
| Milestone 3 | Accepted | Friendly writer tools are implemented and executable-spec verified: guided setup, manual logline/synopsis builders, beat sheets, FakeAIProvider-only suggestions, accepted-only mutation, snapshot-before-rewrite, continuity analysis, friendly warnings, table-read plans, and story package persistence. |
| Milestone 4 | Accepted | Pro foundations are implemented and executable-spec verified: revision metadata, draft versions, semantic comparison, production breakdown, advanced export presets, custom fields, no-code routines, CommandEngine boundary, Pro Mode visibility, Pro metadata package persistence, and deferred plugin policy. |
| Milestone 5 | Implemented | First macOS SwiftUI app shell exists as the `DreamJotterMac` package executable: Project Library, temporary TextEditor screenplay editing, parsed scenes/characters, dashboard, package save/open, Fountain export, health report, and simple error alerts. |

Implementation status: Milestone 1 through Milestone 4 portable-core foundations are `accepted`; Milestone 5 app shell is implemented. TextKit adapters, real renderers, real AI providers, cloud sync, and plugin runtime remain deferred.

## Running The macOS App

Open the package in Xcode:

```sh
open Package.swift
```

Select the `DreamJotterMac` scheme and a macOS run destination, then run. The app opens a Project Library window where you can create a blank project, type screenplay text, save/open `.dreamjotter` packages, export Fountain, and inspect scenes, characters, dashboard data, notes, and health findings.

Command-line validation for the app target:

```sh
xcodebuild -packagePath . -scheme DreamJotterMac -destination 'platform=macOS' build
```

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
  Apps/
    DreamJotterMac/
  Sources/
    DreamJotterCore/
    SpecSupport/
  Tests/
    DreamJotterExecutableSpecs/
    DreamJotterMacTests/
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
