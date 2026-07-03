# DreamJotter

DreamJotter is a local-first macOS screenplay-writing app built with Swift, SwiftUI, AppKit, and a portable semantic core.

## Requirements

- macOS 14 Sonoma or later
- Swift 6 through Xcode or Swift Package Manager

## Current Status

Milestones 1 through 11 are implemented or accepted. All five Milestone 12 slices are implemented on the current development branch and remain pending local build, automated test, accessibility, native-speaker, and manual acceptance results before merge.

Milestone 12 includes:

- M12.1 character and location profile management
- M12.2 notes and TODO workspace
- M12.3 scene workflow polish
- M12.4 English and Spanish screenplay-language support
- M12.5 complete Mexican and Latin American Spanish UI localization
- Unicode-aware search across Characters, Locations, Scenes, Notes, Script, and Review
- Direct navigation between planning, findings, linked notes, and script locations

Specifications:

```text
docs/specs/writer-workflow/m12-localization-spanish.spec.md
docs/specs/writer-workflow/m12-full-ui-localization.spec.md
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
- Complete `es-MX` and `es-419` resources for the macOS interface
- Localized menus, panels, alerts, errors, accessibility labels, export, backup, and restore workflows
- Automatic, English, and Spanish screenplay-language profiles
- Unicode character cues such as `SOFÍA`, `ÍÑIGO`, and `DOÑA ÁNGELES`
- Spanish scene headings such as `INT. CASA - NOCHE` and `I/E. AUTO - CONTINUO`
- Spanish transitions such as `CORTE A:` and `FUNDIDO A NEGRO.`
- Spanish shots, title-page aliases, TODO tokens, parentheticals, and cue extensions
- Localized diagnostic message lookup using stable codes
- Screenplay-language preference persisted in project metadata
- Fountain, text, Markdown, JSON backup, FDX, and production PDF export
- Local package save, reopen, backup, and restore

## Localization Validation

```sh
python3 scripts/localization-check

CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache \
swift test \
  --filter LocalizationResourceTests \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterSwiftPM
```

The localization audit checks SwiftUI literals, missing translations, locale parity, duplicate keys, empty values, and `.strings` syntax across `es-MX` and `es-419`.

## Specifications

- `docs/milestones/`
- `docs/acceptance/`
- `docs/specs/`
- `docs/data-contracts/`
- `Tests/DreamJotterExecutableSpecs/`
- `Tests/DreamJotterMacTests/`

## Run

```sh
open Package.swift
```

Select the `DreamJotterMac` scheme and a macOS 14 or later destination.
