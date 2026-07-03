# DreamJotter

DreamJotter is a local-first macOS screenplay-writing app built with Swift, SwiftUI, AppKit, and a portable semantic core.

## Requirements

- macOS 14 Sonoma or later
- Swift 6 through Xcode or Swift Package Manager

## Current Status

Milestones 1 through 11 are implemented or accepted. All four Milestone 12 slices are implemented on the current development branch and remain pending local build, automated test, and manual acceptance results before merge.

Milestone 12 includes:

- M12.1 character and location profile management
- M12.2 notes and TODO workspace
- M12.3 scene workflow polish
- M12.4 English and Spanish localization and screenplay-language support
- Unicode-aware search across Characters, Locations, Scenes, Notes, Script, and Review
- Direct navigation between planning, findings, linked notes, and script locations

The M12.4 specification is located at:

```text
docs/specs/writer-workflow/m12-localization-spanish.spec.md
```

## Architecture

- `.dreamjotter` packages are canonical project storage.
- Core screenplay and workflow behavior is independent from Apple UI frameworks.
- Commands are the mutation boundary for important project changes.
- Snapshots protect high-impact operations.
- Planning order is stored separately from screenplay order.
- Application language and screenplay language are independent concerns.
- Localization never translates or rewrites screenplay content.
- FDX and Fountain are interchange formats rather than canonical storage.

## Current Capabilities

- Semantic screenplay editing with TextKit and TextEditor adapters
- Script find with previous and next match navigation
- Character and location profile workflows
- Targeted notes, localized TODO projection, filters, and linked navigation
- Scene summaries, notes, statuses, plotline tags, and planning order
- Optional application of planning order to complete screenplay scene blocks
- Review findings with filters and direct script navigation
- English, Mexican Spanish, and Latin American Spanish UI resources
- Automatic, English, and Spanish screenplay-language profiles
- Unicode character cues such as `SOFÍA`, `ÍÑIGO`, and `DOÑA ÁNGELES`
- Spanish scene headings such as `INT. CASA - NOCHE` and `I/E. AUTO - CONTINUO`
- Spanish transitions such as `CORTE A:` and `FUNDIDO A NEGRO.`
- Spanish shots, title-page aliases, TODO tokens, parentheticals, and cue extensions
- Localized diagnostic message lookup using stable codes
- Screenplay-language preference persisted in existing project metadata
- Fountain, text, Markdown, JSON backup, FDX, and production PDF export
- Local package save, reopen, backup, and restore

## Specifications

- `docs/milestones/`
- `docs/acceptance/`
- `docs/specs/`
- `docs/data-contracts/`
- `Tests/DreamJotterExecutableSpecs/`

## Run

```sh
open Package.swift
```

Select the `DreamJotterMac` scheme and a macOS 14 or later destination.
