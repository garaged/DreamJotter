# DreamJotter Release Notes

Release notes are maintained in descending version order. Every public build must include a dated section containing user-visible changes, compatibility notes, migration requirements, known limitations, and the accepted commit SHA.

## 1.0.0 — Release candidate

Status: in development

### Highlights

- Local-first semantic screenplay editing on macOS.
- Native `.dreamjotter` document opening, recent documents, autosave, and restoration.
- Production PDF, Fountain, FDX, text, Markdown, and JSON backup export.
- English, Mexican Spanish, and Latin American Spanish interface support.
- About, Help, onboarding, privacy, and support diagnostics surfaces.
- Universal Apple Silicon and Intel release packaging.

### Reliability and recovery

- Guarded package saves preserve the previous package after failed writes.
- External package changes require an explicit reload, Save As, replace, or cancel choice.
- Unsupported future package major versions are rejected without mutation.
- Support diagnostics exclude screenplay content by default.

### Compatibility

- Requires macOS 14 Sonoma or later.
- Supports Apple Silicon and Intel Macs.
- Historical package migrations require backup-first validation before 1.0 acceptance.

### Known limitations

- Final M15 manual accessibility, long-script, migration-fixture, signing, notarization, and clean-machine QA evidence must be completed before this section is marked released.

### Release metadata

- Commit SHA: pending
- Notarization submission: pending
- QA matrix: `docs/acceptance/milestone-15-acceptance.md`
