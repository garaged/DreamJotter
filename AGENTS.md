# DreamJotter Agent Instructions

We are building **DreamJotter**, a screenplay/movie-script app.

## Primary product direction

* Desktop and mobile.
* Priority platforms:

  1. macOS
  2. iPadOS / iOS
  3. Later: Linux, Windows, Android
* Apple-native first, but portable core always.
* The first UI should feel excellent on Mac, iPad, and iPhone.
* The core domain, screenplay engine, storage format, command system, routines, export system, and AI abstractions must remain platform-neutral.
* The app is for non-programmers first, with optional pro/customization features for advanced users.

## Final technical direction

* Swift + SwiftUI for Apple app UI.
* TextKit/AppKit/UIKit wrappers later for the serious screenplay editor.
* Core logic belongs in Swift Package modules.
* Canonical project storage is a local-first `.dreamjotter` document package.
* SwiftData may be used later only for app metadata, cache, and search indexing.
* SwiftData must never become the canonical project format.
* Do not start with Flutter, Electron, Tauri, Kotlin Multiplatform, or a web editor.
* Do not build arbitrary plugins early.
* Build in this order:

  1. specs
  2. data contracts
  3. executable specs/tests
  4. core implementation
  5. Apple UI
  6. commands
  7. routines
  8. future plugin API

## Current repository assumption

The repository may already contain initial Spec Driven Development documents from previous work.

Do not assume the repository is empty.

Before making changes:

1. Inspect the current repo structure.
2. Preserve existing documents unless they are clearly obsolete duplicates.
3. Do not reset, delete, or rewrite large parts of the repo unless explicitly requested.
4. Prefer incremental updates.
5. Keep existing product direction unless a prompt explicitly changes it.

The repository should evolve toward this structure:

```text
docs/
  constitution.md
  vision/
  architecture/
  adr/
  specs/
  milestones/
  acceptance/
  data-contracts/
  routines/
  plugins/
  ai/
  export/
  storage/
  editor/
  ux/
  templates/

specs/
  registry.yml
  executable/
  fixtures/

scripts/
  spec-check
  spec-new
  spec-trace

README.md
CONTRIBUTING.md
TODO.md
```

## Development style

This project uses **Spec Driven Development**.

Specs are the source of truth.

Before implementation, create or update:

* product specs
* architecture specs
* acceptance criteria
* data contracts
* behavioral examples
* ADRs when architecture decisions change
* traceability entries
* executable specs/tests when appropriate

Favor Given/When/Then examples.

Specs should be concrete enough that tests and implementation can be generated from them later.

Do not implement production app features unless explicitly requested by the current prompt.

Creating lightweight validation scripts, schema examples, fixtures, executable spec placeholders, and documentation checks is allowed when useful.

## Custom SDD management rules

The repo should contain a lightweight custom SDD layer.

The key files are:

```text
docs/constitution.md
specs/registry.yml
scripts/spec-check
scripts/spec-trace
scripts/spec-new
```

### `docs/constitution.md`

This file defines non-negotiable project rules.

It must mention:

* Apple-native first.
* Portable core always.
* Semantic screenplay model, not rich text only.
* `.dreamjotter` package is canonical project storage.
* SwiftData is not canonical storage.
* Core modules must not depend on SwiftUI, AppKit, UIKit, SwiftData, or CloudKit.
* Commands are the safe mutation boundary.
* Routines execute commands instead of directly mutating state.
* Plugins are future work and must not drive Milestone 1–4 design.
* AI suggestions must not mutate user text until accepted.
* Destructive or major automated actions require snapshots.

### `specs/registry.yml`

The registry is the project’s spec index.

Every meaningful feature/spec should have a registry entry with:

* id
* title
* milestone
* status
* spec path
* acceptance path, if available
* related ADRs, if available
* related data contracts, if available
* planned modules
* guardrails
* notes

Allowed statuses:

```text
idea
specified
clarified
planned
executable-spec-ready
implementation-ready
implemented
accepted
deferred
```

Before adding or changing specs, update `specs/registry.yml`.

After changing specs, run:

```bash
python3 scripts/spec-check
python3 scripts/spec-trace
```

If these scripts do not exist yet, create them before continuing major spec work.

## Spec quality rules

Specs must be written for both product and engineering readers.

Avoid vague words like “easy”, “fast”, “simple”, or “smart” unless paired with observable behavior.

Every feature spec should include:

* user goal
* scope
* non-goals
* beginner behavior
* pro behavior, where relevant
* user-facing behavior
* acceptance criteria
* Given/When/Then examples
* edge cases
* data model implications
* storage implications
* command implications
* UI implications
* testability notes
* platform implications
* future cross-platform implications
* security/privacy notes, where relevant
* open questions

Every milestone should have acceptance documentation.

Every major architecture decision should have an ADR.

Persistent model changes should have a data contract.

Implementation should trace back to registry IDs.

## Architecture guardrails

Core modules must remain platform-neutral.

The following imports are forbidden in portable core modules unless a prompt explicitly creates an Apple-specific adapter module:

```text
SwiftUI
AppKit
UIKit
SwiftData
CloudKit
```

The screenplay must be modeled semantically.

Do not store screenplay content only as:

```text
NSAttributedString
AttributedString
raw rich text
editor buffer only
```

The editor may use TextKit later, but TextKit is an adapter, not the canonical model.

The canonical model should support:

* Codable serialization
* stable IDs
* semantic screenplay elements
* Fountain import/export
* `.dreamjotter` package persistence
* future cross-platform reading

## Storage rules

The `.dreamjotter` package is canonical.

Expected package direction:

```text
MyMovie.dreamjotter/
  manifest.json
  project.json
  screenplay.json
  script.fountain
  characters.json
  locations.json
  notes.json
  routines.json
  custom-fields.json
  snapshots/
  attachments/
  exports/
  indexes/
```

SwiftData may be used later for:

* app metadata
* recent projects
* local search index
* cached summaries
* UI state

SwiftData must not be required to recover or understand a user’s project.

## Commands, routines, and plugins

Commands come first.

Routines come second.

Plugins come later.

Commands are the safe mutation layer for project changes.

Routines must execute commands instead of directly mutating project internals.

Plugins are deferred beyond Milestone 4 unless explicitly requested.

Do not create:

* arbitrary code execution
* plugin marketplace
* third-party plugin runtime
* network-capable plugins
* unsafe file access

through Milestone 4.

## AI rules

Do not call external AI services unless explicitly requested.

AI features through Milestone 4 should be abstractions/specs/fake providers only.

AI suggestions must not mutate screenplay text until accepted.

Rejecting an AI suggestion must leave the project unchanged.

Applying an AI rewrite must create a snapshot first.

AI must be optional and disableable.

## Simple Mode and Pro Mode

Keep beginner workflows separate from pro features.

Simple Mode should prioritize:

* writing
* scenes
* characters
* notes
* search
* export
* guided help

Pro Mode may expose:

* revision colors
* draft comparison
* production breakdown
* custom fields
* routines
* advanced exports
* future plugin extension points

Do not let pro features complicate beginner workflows.

## Milestone scope

### Milestone 1 — Apple prototype foundations

* portable core plan
* semantic screenplay model
* screenplay parser
* Fountain import/export
* editor behavior model
* scene list foundation
* character/location autocomplete foundation
* local project/package concept
* PDF export abstraction
* architecture guardrails

### Milestone 2 — Real MVP

* project dashboard
* character manager foundation
* scene cards
* notes
* idea inbox
* search
* snapshots
* `.dreamjotter` save/load
* script health report
* starter templates
* Simple Mode / Pro Mode foundation

### Milestone 3 — Friendly writer tools

* guided story setup
* logline builder
* synopsis builder
* beat sheets
* scene starter generation
* AI abstraction
* AI suggestion workflow
* continuity warnings
* character consistency checks
* table-read/read-aloud data model

### Milestone 4 — Pro foundations

* revision colors
* draft versions
* draft comparison
* production breakdown
* advanced export presets
* custom fields
* routine system v1
* routine runner safety
* command-engine integration
* Pro Mode visibility
* future plugin extension points only

## What not to do unless explicitly requested

Do not create an Xcode project yet.

Do not create real app UI yet.

Do not create TextKit wrappers yet.

Do not create a plugin runtime yet.

Do not call external services.

Do not implement real AI providers.

Do not implement cloud sync.

Do not implement Windows/Linux/Android apps.

Do not make SwiftData canonical storage.

Do not replace the semantic screenplay model with rich text.

Do not bypass the spec registry.

## Expected workflow for each task

For spec tasks:

1. Inspect existing files.
2. Update or create relevant spec documents.
3. Update `specs/registry.yml`.
4. Update traceability/acceptance docs.
5. Run `python3 scripts/spec-check` if available.
6. Run `python3 scripts/spec-trace` if available.
7. Report files changed and checks run.

For implementation tasks:

1. Identify related registry IDs.
2. Confirm the spec and acceptance criteria exist.
3. Add or update executable specs/tests first.
4. Implement the minimum code needed.
5. Preserve architecture guardrails.
6. Run relevant tests.
7. Run spec checks.
8. Report commands used and results.

## Reporting expectations

At the end of each task, report:

* files created
* files updated
* registry entries added or changed
* commands run
* test/spec-check results
* assumptions
* deferred work

