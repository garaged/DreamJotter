# Changelog

All notable user-visible changes to DreamJotter are documented here.

## [1.0.0] — 2026-07-04

First public macOS release.

### Added

- Local-first `.dreamjotter` project packages.
- Native TextKit screenplay editor with semantic paragraph types.
- Undo and redo integration for typing, Smart Enter, and element-type changes.
- Grapheme-safe selection, normalized paste, and semantic screenplay block copy/cut.
- Scene planning, character profiles, location profiles, notes, review findings, and health reporting.
- Fountain, FDX, text, Markdown, JSON backup, and production PDF export.
- English, Mexican Spanish, and Latin American Spanish interface support.
- About, Help, onboarding, privacy statement, and support diagnostics.
- Universal Apple Silicon and Intel packaging.
- Developer ID signing, notarization, stapling, and Gatekeeper validation workflow.

### Changed

- Review, Scenes, Dashboard, Characters, Locations, and Health Report now load expensive derived data asynchronously.
- Large-project pane data is cached by project revision.
- Review uses a bounded screenplay preview and calculates layout numbering only when requested.
- Large collections use lazy rendering to avoid blocking navigation.
- Workspace restoration state is consumed once to prevent a previously restored project from repeatedly overriding explicit opens.
- GitHub Actions now validates with a Swift 6-capable macOS 15 runner.

### Fixed

- Sidebar selection rendering for large projects.
- Sticky project restoration after opening a large screenplay.
- Main-thread stalls when opening Review or Scenes.
- Eager layout-number rendering for long screenplays.
- Swift 6 actor isolation in TextKit undo callbacks and diagnostics UI.
- Deprecated macOS package-open filtering API.

### Security and privacy

- Diagnostics exclude screenplay content by default.
- Package recovery and migration policies avoid implicit source mutation.
- Failed guarded saves restore the previous package state.
- External package changes require an explicit user decision before replacement.
