# DreamJotter

DreamJotter is a screenplay app for non-programmers who want to write, revise, organize, and export scripts without learning technical tooling. It should feel approachable at first launch, while still allowing optional professional customization for writers, editors, production teams, and technically advanced users.

## Project Vision

DreamJotter helps writers create screenplay documents from semantic script elements rather than from unstructured rich text. Scenes, actions, characters, dialogue, parentheticals, transitions, notes, outline items, and future production metadata must be represented as meaningful screenplay data that can be validated, transformed, exported, searched, and automated.

The product follows progressive complexity:

- Simple Mode: beginner-friendly workflows, constrained choices, clear defaults, and minimal visible configuration.
- Pro Mode: specialized formatting, advanced document controls, automation surfaces, export tuning, and optional customization.

## Platform Priority

Priority platforms are:

1. macOS first.
2. iPadOS and iOS next.
3. Linux, Windows, and Android later.

The Apple experience should be native and excellent, but core domain behavior must remain portable.

## Architecture Direction

DreamJotter is Apple-native first with a portable core. Swift and SwiftUI are the expected direction for Apple UI, with TextKit/AppKit/UIKit integration later for the serious editor surface.

The canonical project format is a local-first `.dreamjotter` document package. SwiftData may be used later for app metadata, cache, search, or indexing, but SwiftData is not the canonical screenplay or project storage format.

The portable core must own the screenplay model, storage contracts, command system, routines, export behavior, and AI abstractions. UI frameworks must not leak into core specs or future core modules.

Plugins are future work. MVP architecture should be driven by commands first, routines second, and plugin APIs later.

## Spec-Driven Workflow

Specs are the source of truth. Implementation should follow documented product goals, architecture decisions, acceptance criteria, data contracts, and traceability.

Current SDD flow:

1. Check the constitution in `docs/constitution.md`.
2. Create or update the relevant spec using `docs/templates/feature-spec-template.md` when applicable.
3. Add acceptance criteria and Given/When/Then examples.
4. Add data contracts for persistent model or package changes.
5. Add an ADR for architecture-changing decisions.
6. Register the spec in `specs/registry.yml`.
7. Run the spec checks before implementation.
8. Add or update executable specs when behavior is ready to be tested.
9. Implement only behavior that traces back to registry IDs.

## SDD Commands

Run the spec validation checks:

```sh
python3 scripts/spec-check
```

View traceability grouped by milestone:

```sh
python3 scripts/spec-trace
```

Create a new feature spec from the template:

```sh
python3 scripts/spec-new PRD-EDITOR-002 "Editor Commands" M2 docs/specs/editor-commands.md
```

Run executable documentation specs:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

`spec-new` creates the file only. Add the new spec to `specs/registry.yml` before implementation work starts.

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

## Current Status

The repository contains documentation-first specs through Milestone 4 plus a SwiftPM executable-spec skeleton. No production app code, Xcode project, production UI, plugin runtime, real AI provider, cloud sync, or external service integration exists yet.
