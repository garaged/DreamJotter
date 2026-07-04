# DreamJotter

DreamJotter is a local-first macOS screenplay-writing app built with Swift, SwiftUI, AppKit, and a portable semantic core.

## Build and run locally

DreamJotter is available as source code and can be compiled locally on Apple Silicon or Intel Macs. A prebuilt macOS binary is not required.

```sh
git clone https://github.com/garaged/DreamJotter.git
cd DreamJotter
open Package.swift
```

In Xcode, select the `DreamJotterMac` scheme, choose `My Mac`, and press `Command-R`.

To build and run from Terminal:

```sh
swift build --product DreamJotterMac
swift run DreamJotterMac
```

For complete setup, architecture-specific builds, testing, localization validation, `.app` packaging, and troubleshooting, see [`BUILDING.md`](BUILDING.md).

## Requirements

- macOS 14 Sonoma or later
- Swift 6 through Xcode or Swift Package Manager
- Apple Silicon or Intel Mac

## Current Status

Milestones 1 through 11 are implemented or accepted. Milestone 12 writer workflow and localization work is merged. Milestone 13 TextKit editor maturity is implemented and merged, with final local macOS, accessibility, input-method, large-script, save/reopen, and manual undo/redo validation still required before formal acceptance.

Milestone 13 includes:

- native undo/redo command grouping for Smart Enter and element-type changes
- grapheme-safe cursor and selection restoration
- normalized paste behavior and semantic paragraph copy/cut
- stable cursor behavior across parser refresh and navigation
- expanded screenplay line styling and explicit paragraph semantics
- current screenplay element accessibility exposure
- retained `TextEditor` recovery/compatibility mode pending full acceptance evidence

Specifications and acceptance records:

```text
docs/milestones/milestone-13-textkit-editor-maturity.md
docs/acceptance/milestone-13-acceptance.md
docs/editor/m13-textkit-consolidation-decision.md
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

## Architecture Builds

DreamJotter supports both Apple Silicon (`arm64`) and Intel (`x86_64`) on macOS 14 or later.

Build only the Intel binary:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache-x86_64 \
xcrun --sdk macosx swift build \
  --product DreamJotterMac \
  --configuration release \
  --triple x86_64-apple-macosx14.0 \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterSwiftPM-x86_64
```

Build a universal binary containing both architectures:

```sh
bash scripts/build-universal-macos
```

The universal output is written to:

```text
dist/DreamJotterMac-universal/
```

The directory contains the universal `DreamJotterMac` executable and the SwiftPM resource bundle required for localization and other packaged resources. Verify the binary with:

```sh
lipo -archs dist/DreamJotterMac-universal/DreamJotterMac
```

Expected output includes:

```text
arm64 x86_64
```

## Localization Validation

```sh
python3 scripts/normalize-spanish-copy
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
