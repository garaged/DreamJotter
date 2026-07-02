# DreamJotter

DreamJotter is a screenplay and movie-script writing app for non-programmers. It is designed to let beginners write, organize, and export scripts without learning technical tooling, while still leaving room for optional Pro Mode workflows such as revision colors, draft comparison, production breakdown, custom fields, export presets, and no-code routines.

Milestone 1 through Milestone 4 portable-core foundations are implemented and covered by executable specs. Milestone 5 adds the first launchable macOS SwiftUI vertical slice as a package executable target. Milestone 6 stabilizes document lifecycle behavior for saving, dirty state, recent projects, replacement protection, and basic commands. Milestone 7 implements screenplay editor usability v1 with TextKit Smart Enter, Tab cycling, suggestions, scene navigation/cursor sync, adapter-only styling, and passive blank-script guidance. Milestone 8 implements character, location, notes, and scene workflow v1 with detected object resolution, profile creation/editing, scene-card status, parsed TODO notes, dashboard summary, and search integration. Milestone 9 implements export, review, backup/restore, and script health v1. Milestone 9.5 implements export UX and release-readiness polish. There is no plugin runtime, real AI provider, cloud sync, or external service integration.

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
- `docs/milestones/`: Milestone 1 through Milestone 9.5 specs and milestone map.
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
| Milestone 5 | Implemented | First macOS SwiftUI vertical slice exists as the `DreamJotterMac` package executable: Project Library, editable title/logline/synopsis, temporary TextEditor screenplay editing, parsed scenes/characters, notes, dashboard, package save/open, Fountain export, health report, and simple error alerts. |
| Milestone 6 | Implemented | Document lifecycle is implemented for the macOS app: dirty state, Save/Save As routing, Save As cancel preservation, failed-save dirty preservation, recent-project deduplication, app errors, Save / Discard / Cancel protection, basic commands, and export without dirtying the project. |
| Milestone 7 | Implemented | Screenplay editor usability v1 is implemented: TextKit Smart Enter, Tab cycling, scene heading suggestions, character/location autocomplete, parse state, scene navigation/cursor sync, adapter-only line styling, empty guidance, and preserved document workflow. |
| Milestone 8 | Implemented | Character, location, notes, and scene workflow v1 covers detected character/location resolution, profile create/edit/save/reopen, scene-card status, parsed TODO notes, dashboard summary, and search integration. Rich archive/delete/profile-field polish remains deferred. |
| Milestone 9 | Implemented | Export, Review, and Script Health v1 covers Fountain/plain text/Markdown/JSON backup/basic PDF export, presets, backup/restore validation, read-only Review Mode, health reports, formatting warnings, and review findings. |
| Milestone 9.5 | Implemented | Export UX and Release Readiness Polish covers format/preset picker UI, destination and feedback flows, Review Mode export reuse, backup/restore UI, export UI state, export feedback, and a Mac MVP manual QA checklist. |
| Milestone 9.6 | Implemented | Restore UX Hardening implements Save / Discard / Cancel protection for restoring backups over dirty current projects. |
| Milestone 10 | Specified | Production PDF Export defines deterministic screenplay PDF layout, pagination, title-page behavior, metadata privacy, diagnostics, and renderer boundaries. |

Implementation status: Milestone 1 through Milestone 4 portable-core foundations are `accepted`; Milestone 5, Milestone 6, Milestone 7, Milestone 8, Milestone 9, Milestone 9.5, and Milestone 9.6 app/editor/workspace/export/restore foundations are implemented. Milestone 10 is specified as next-stage work. Real AI providers, cloud sync, iOS targets, and plugin runtime remain deferred.

## Current App Capabilities

- Launches as the `DreamJotterMac` macOS SwiftUI app.
- Creates a blank screenplay project from the Project Library.
- Lets the writer edit project title, logline, and synopsis.
- Provides a TextKit/AppKit `NSTextView` screenplay editor foundation.
- Keeps a SwiftUI `TextEditor` fallback available from the Script pane editor switch.
- Parses screenplay text into semantic core elements.
- Shows derived scene and character lists.
- Adds project notes and can link a note to the first parsed scene.
- Saves and opens canonical `.dreamjotter` packages.
- Tracks dirty state and shows unsaved status in the app UI.
- Routes Save to Save As when a project has no package URL.
- Records recently opened or saved packages in the Project Library.
- Requires confirmation before replacing a project with unsaved changes.
- Shows a SwiftUI export picker with Reader Copy, Contest Submission, Print Script, Writer Backup, and Plain Text Archive presets.
- Exports parser-backed Fountain, plain text, Markdown, JSON backup, and basic PDF artifacts through the core export workflow.
- Shows export success, cancel, and failure feedback, including Reveal in Finder for successful file exports.
- Reuses the same export picker from Review Mode.
- Validates JSON backup restore before replacing current project state and protects dirty current projects with Save / Discard / Cancel restore choices.
- Shows read-only Review Mode and script health findings.
- Provides basic commands and shortcuts for New Project, Open, Save, Save As, and Export Fountain.

## Running The macOS App

Open the package in Xcode:

```sh
open Package.swift
```

Select the `DreamJotterMac` scheme and a macOS run destination, then run. The app opens a Project Library window where you can create a blank project, type screenplay text, save/open `.dreamjotter` packages, export Fountain, and inspect scenes, characters, dashboard data, notes, and health findings.

In the Script pane, use the segmented `Editor` control to switch between `TextKit` and `TextEditor`. Both paths edit the same project text and feed the same semantic parser, save, reopen, and Fountain export behavior.

Command-line validation for the app target:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
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
