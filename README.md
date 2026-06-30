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

Expected flow:

1. Write or update the relevant spec.
2. Add or update acceptance criteria using observable behavior.
3. Update traceability so requirements can be followed through milestones, tests, and implementation.
4. Implement only the scoped behavior.
5. Validate against acceptance criteria.

## Repo Layout

```text
DreamJotter/
  AGENTS.md
  README.md
  CONTRIBUTING.md
  TODO.md
  docs/
    vision/
    architecture/
    adr/
    milestones/
    acceptance/
```

Future spec folders may include `docs/specs`, `docs/data-contracts`, `docs/editor`, `docs/storage`, `docs/export`, `docs/routines`, `docs/ai`, and `docs/plugins` when those areas receive detailed specs.

## Current Status

Milestone 0 is in progress: SDD foundation. No app code, Swift package, Xcode project, production UI, plugin runtime, or external service integration exists yet.
