# Milestone 9.5: Export UX and Release Readiness Polish

Status: implemented
Milestone: M9.5
Traceability ID: M9-5-EXPORT-UX-RELEASE-READINESS

## Goal

Make the existing Mac MVP export, review, backup, and restore workflows understandable and usable by a non-technical writer.

## Product Outcome

- A writer can choose export presets and formats without knowing file-format details.
- A writer can export Reader PDF, Fountain, Markdown, plain text, and JSON backup artifacts.
- A writer can create and validate backups while preserving local-first `.dreamjotter` ownership.
- A writer receives clear success, cancel, and failure feedback.
- Review Mode export uses the same workflow as the main workspace.

## Implemented Slice

- Adapter-neutral `ExportUIState` tracks selected preset, selected format, disabled format reasons, destination, progress, feedback, and source context.
- Adapter-neutral `ExportFeedback` represents success, warning, error, and canceled outcomes.
- SwiftUI export picker UI exposes presets, supported formats, destination selection, feedback, and Reveal in Finder.
- Workspace export and Review Mode export use the same picker and M9 export workflow.
- JSON Backup creation uses the same picker, and Restore Backup validates backup data through M9 restore logic.
- Restore protects dirty current projects by returning confirmation-required feedback instead of replacing state.
- Export, backup, cancel, feedback, and restore validation do not mark the project dirty.

## Scope

- Export format picker UI specification.
- Export preset picker UI specification.
- Export destination, cancel, success, failure, and reveal-in-Finder feedback.
- Review Mode export UX.
- Backup and restore UI behavior.
- Export UI state and feedback data contracts.
- Mac MVP manual QA checklist.
- Preservation criteria for Milestones 6, 7, 8, and 9.

## Non-Goals

- No iOS or iPadOS targets.
- No iCloud or collaboration.
- No real AI providers.
- No plugin runtime.
- No FDX import/export.
- No production-grade pagination.
- No rewrite of Milestone 9 export/review/health core.

## Architecture Rules

- SwiftUI views remain thin and call view-model/app-support services.
- Portable core remains the source for export presets, formats, backup validation, and review findings.
- `.dreamjotter` package remains canonical storage.
- SwiftData must not become canonical project storage.
- Export actions must not mutate project content or dirty state.
- Backup restore must protect unsaved current work before replacing state.
- Reader-facing presets must exclude internal metadata by default.

## Feature Areas

### A. Export Format Picker UI

The app presents Fountain, PDF, Markdown, plain text, and JSON backup as user-facing choices with plain-language descriptions.

### B. Export Preset Picker UI

The app presents Reader Copy, Contest Submission, Print Script, Writer Backup, and Plain Text Archive. Presets constrain compatible formats and communicate metadata/privacy behavior.

### C. Export Destination and Feedback

The app lets the user pick a destination, treats cancel as non-error feedback, shows success/failure messages, and can reveal successful exports in Finder where practical.

### D. Review Mode Export UX

Review Mode export uses the same picker state and result feedback while keeping the script preview read-only.

### E. Backup/Restore UI

Create Backup and Restore Backup actions use existing M9 backup/restore services, validate restore input, and protect dirty current work.

### F. Release Readiness QA

Manual QA covers launch, writing, saving, reopening, editor behavior, project-object workflows, review, exports, backup/restore, dirty state, and recent projects.

## Data Contracts

- `docs/data-contracts/export-ui-state.md`
- `docs/data-contracts/export-feedback.md`

## Related Specs

- `docs/specs/export/export-picker-ui.spec.md`
- `docs/specs/export/export-preset-picker-ui.spec.md`
- `docs/specs/export/export-destination-feedback.spec.md`
- `docs/specs/export/review-mode-export-ux.spec.md`
- `docs/specs/export/backup-restore-ui.spec.md`
- `docs/specs/release/mac-mvp-manual-qa-checklist.spec.md`

## Executable Spec Plan

- Export UI lists all supported formats.
- Export UI lists all supported presets.
- Preset selection constrains compatible formats.
- Reader Copy and Contest Submission exclude internal metadata.
- Print Script defaults to PDF.
- Writer Backup defaults to JSON backup.
- Export success produces success feedback.
- Export cancel produces canceled feedback and no dirty change.
- Export failure produces friendly feedback.
- Reveal in Finder availability is represented when output path exists.
- Review Mode export uses the same export state.
- Backup success and restore validation produce feedback.
- Restore invalid backup preserves current project.
- Restore while dirty requires protection.

## Deferred Work

- Full native document browser behavior for exported files.
- Production pagination and page locking.
- Export history.
- Batch export.
- FDX import/export.
- Share links and collaboration packages.

## Open Questions

- Should export picker state persist per project or reset per session?
- Should Restore Backup be exposed from Project Library, Review Mode, or both?
- Should backup files use `.json`, `.dreamjotter-backup`, or a later zipped-package extension?
