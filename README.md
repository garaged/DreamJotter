# DreamJotter

DreamJotter is a local-first macOS screenplay-writing app built with Swift, SwiftUI, AppKit, and a portable semantic core.

## DreamJotter 1.0.0

DreamJotter 1.0.0 is the first public macOS release. It supports Apple Silicon and Intel Macs running macOS 14 Sonoma or later.

The app provides semantic screenplay editing, project organization, review tools, local package storage, production export, English and Spanish interfaces, recovery workflows, and privacy-preserving diagnostics. DreamJotter works offline and does not require an account or cloud service.

Release information:

- [`RELEASE_NOTES.md`](RELEASE_NOTES.md)
- [`CHANGELOG.md`](CHANGELOG.md)
- [`PRIVACY.md`](PRIVACY.md)
- [`RELEASING.md`](RELEASING.md)

## Build and run locally

Clone the repository and open the Swift package:

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

## Current status

Version 1.0.0 is accepted for public release under Milestone 15. The release-readiness work includes:

- native macOS menus, shortcuts, About, Help, onboarding, privacy, and diagnostics surfaces
- universal Apple Silicon and Intel packaging
- Developer ID signing and notarization workflow
- guarded save, recovery, external-change handling, and package-version compatibility policies
- large-project performance improvements using asynchronous derived-data generation, revision-based caching, bounded previews, and lazy rendering
- Swift 6 CI for specification checks, localization validation, tests, and release compilation

Acceptance record:

```text
docs/acceptance/milestone-15-acceptance.md
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

## Capabilities

- Semantic screenplay editing with the native TextKit editor
- Native undo and redo for typing, Smart Enter, and element-type changes
- Grapheme-safe selection and cursor restoration
- Normalized paste and semantic screenplay block copy/cut
- Script find with previous and next match navigation
- Character and location profile workflows
- Targeted notes, localized TODO projection, filters, and linked navigation
- Scene summaries, notes, statuses, plotline tags, and planning order
- Optional application of planning order to complete screenplay scene blocks
- Review findings with filters and direct script navigation
- Asynchronous, cached large-project panes for Review, Scenes, Dashboard, Characters, Locations, and Health Report
- Complete `es-MX` and `es-419` resources for the macOS interface
- Automatic, English, and Spanish screenplay-language profiles
- Unicode character cues such as `SOFÍA`, `ÍÑIGO`, and `DOÑA ÁNGELES`
- Spanish scene headings such as `INT. CASA - NOCHE` and `I/E. AUTO - CONTINUO`
- Spanish transitions such as `CORTE A:` and `FUNDIDO A NEGRO.`
- Fountain, text, Markdown, JSON backup, FDX, and production PDF export
- Local package save, reopen, backup, restore, and external-change conflict handling
- Privacy-filtered support diagnostics that exclude screenplay content by default

## Architecture builds

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

Verify the binary with:

```sh
lipo -archs dist/DreamJotterMac-universal/DreamJotterMac
```

Expected output includes:

```text
arm64 x86_64
```

## Validation

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
python3 scripts/localization-check
swift test
swift build --configuration release --product DreamJotterMac
```

## License

DreamJotter is licensed under the [Mozilla Public License 2.0](LICENSE).

The MPL-2.0 keeps modifications to existing MPL-covered source files open while allowing separate files or modules to use different terms. That makes it suitable for an open core, optional paid distribution, voluntary contributions, and a possible future Pro edition implemented in separate proprietary modules.

The DreamJotter name, logo, and app icon are not granted for unrestricted use by the software license unless explicitly stated otherwise.

## Project documentation

- `docs/milestones/`
- `docs/acceptance/`
- `docs/specs/`
- `docs/data-contracts/`
- `Tests/DreamJotterExecutableSpecs/`
- `Tests/DreamJotterMacTests/`
