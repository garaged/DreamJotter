# DreamJotter Release Notes

Release notes are maintained in descending version order. Every public build includes a dated section containing user-visible changes, compatibility notes, migration requirements, known limitations, and the accepted release commit.

## 1.0.0 — 2026-07-04

Status: released

DreamJotter 1.0.0 is the first public macOS release.

### Highlights

- Local-first semantic screenplay editing on macOS.
- Native `.dreamjotter` document opening, recent documents, autosave, and restoration.
- Native TextKit editor with undo/redo, Smart Enter, semantic element changes, grapheme-safe selection, normalized paste, and semantic block copy/cut.
- Scene, character, location, notes, review, and health-report workflows.
- Production PDF, Fountain, FDX, text, Markdown, and JSON backup export.
- English, Mexican Spanish, and Latin American Spanish interface support.
- About, Help, onboarding, privacy, and support diagnostics surfaces.
- Universal Apple Silicon and Intel release packaging.

### Large-project performance

- Review opens immediately and generates findings asynchronously.
- PDF layout numbering is calculated only when requested.
- Review, Scenes, Dashboard, Characters, Locations, and Health Report reuse revision-based cached derived data.
- Large text previews are bounded and large collections use lazy rendering.
- Background work is discarded when the document revision changes.

### Reliability and recovery

- Guarded package saves preserve the previous package after failed writes.
- External package changes require an explicit reload, Save As, replace, or cancel choice.
- Workspace restoration records are consumed once so a previous large project cannot override explicit opens.
- Unsupported future package major versions are rejected without mutation.
- Historical migrations follow backup-first policy.
- Support diagnostics exclude screenplay content by default.
- Error presentation is bounded and avoids exposing screenplay content.

### Accessibility and localization

- Screenplay semantic element types are exposed to accessibility.
- Primary workflows support keyboard navigation.
- English, `es-MX`, and `es-419` resources are validated in CI.
- Application language remains independent from screenplay language.

### Compatibility

- Requires macOS 14 Sonoma or later.
- Supports Apple Silicon and Intel Macs.
- Uses Swift 6 for development and CI validation.

### Known limitations

- No release-blocking limitations were identified during Milestone 15 acceptance.

### Release metadata

- Version: 1.0.0
- Acceptance: `docs/acceptance/milestone-15-acceptance.md`
- Changelog: `CHANGELOG.md`
