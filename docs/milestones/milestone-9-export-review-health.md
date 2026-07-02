# Milestone 9: Export, Review, and Script Health v1

Status: specified
Milestone: M9
Traceability ID: M9-EXPORT-REVIEW-HEALTH

## Goal

Make DreamJotter useful for reviewing, sharing, exporting, backing up, and evaluating a screenplay project without compromising local-first ownership or prior writing workflows.

## Product Outcome

- Writers can export practical artifacts for readers, contests, print, archives, and backups.
- Writers can inspect script health without AI or destructive edits.
- Writers can enter a read-only Review Mode to inspect scenes, notes, TODOs, and findings.
- Writers can create and restore backup artifacts while protecting unsaved work.

## Scope

- Export workflow v1 for Fountain, plain text, Markdown, JSON backup, and basic PDF.
- Export presets v1.
- Basic PDF export adapter specification.
- Backup and restore workflow.
- Review Mode v1.
- Script Health Report v1.
- Formatting warnings and review findings.
- Search/navigation integration for review findings.
- Preservation of Milestones 6, 7, and 8 behavior.

## Non-Goals

- No iOS or iPadOS target.
- No iCloud, collaboration, or cloud share links.
- No real AI provider.
- No plugin runtime.
- No FDX import/export.
- No production-grade screenplay pagination, locked pages, revision-colored PDFs, or Final Draft-perfect layout.

## Architecture Rules

- Portable core remains source of truth for export/review/analysis decisions.
- TextKit remains an editor adapter only.
- Semantic screenplay model remains canonical.
- `.dreamjotter` package remains canonical storage.
- SwiftData is not canonical project storage.
- SwiftUI views stay thin and call view models/services.
- Export, review, and analysis must not mutate project state unless an explicit restore action is confirmed.
- Internal metadata is excluded from reader-facing exports by default.

## Feature Areas

### A. Export Workflow v1

Export supports Fountain, plain text, Markdown, JSON backup, and basic PDF. Exports are projections of current project state and do not mark a project dirty.

### B. Export Presets v1

Required presets are Reader Copy, Contest Submission, Print Script, Writer Backup, and Plain Text Archive. Presets define allowed formats, default format, metadata inclusion, privacy warnings, and filename suggestions.

### C. Basic PDF Export Adapter

PDF export should produce a readable screenplay-like document from semantic/plain screenplay text. Production pagination is deferred.

### D. Script Health Report v1

Health report summarizes scenes, elements, project objects, TODOs, dialogue/action balance, long scenes, scenes without dialogue, unresolved detections, formatting warnings, storage status, and saved status.

### E. Review Findings

Health warnings and review items are represented as structured findings with severity, source, links, optional script ranges, and suggested actions.

### F. Review Mode v1

Review Mode is read-only and surfaces script preview, scene navigation, notes/TODOs, health findings, export actions, and navigation back to the editor.

### G. Backup and Restore Workflow v1

Backup produces a restorable artifact from structured project/package data. Restore validates before replacing state and protects dirty current work.

### H. Formatting Warning v1

Formatting warnings are non-blocking and friendly. They help identify missing time of day, character cues without dialogue, dialogue without clear character, unusual transitions, empty scenes, TODOs, and unresolved detections.

### I. Search/Navigation Integration

Review findings should link to scenes, script ranges, project notes, characters, or locations where possible. Navigation is read-only and must not dirty the project.

### J. Preserve Previous Milestones

Milestone 9 must preserve document lifecycle, editor usability, and project-object workflows from Milestones 6 through 8.

## Data Contracts

- `docs/data-contracts/export-preset.md`
- `docs/data-contracts/export-request.md`
- `docs/data-contracts/export-result.md`
- `docs/data-contracts/backup-archive.md`
- `docs/data-contracts/restore-result.md`
- `docs/data-contracts/script-health-report.md`
- `docs/data-contracts/review-finding.md`
- `docs/data-contracts/review-mode-state.md`

## Related Specs

- `docs/specs/export/export-workflow-v1.spec.md`
- `docs/specs/export/export-presets-v1.spec.md`
- `docs/specs/export/basic-pdf-export-adapter.spec.md`
- `docs/specs/export/backup-restore-workflow.spec.md`
- `docs/specs/review/review-mode-v1.spec.md`
- `docs/specs/analysis/script-health-report-v1.spec.md`
- `docs/specs/analysis/formatting-warning-v1.spec.md`
- `docs/specs/analysis/review-findings.spec.md`

## Executable Spec Plan

- Export Fountain, Markdown, plain text, JSON backup, and PDF without changing dirty state.
- Validate Reader Copy, Contest Submission, Writer Backup, Print Script, and Plain Text Archive preset behavior.
- Validate unsupported preset/format combinations return friendly failures.
- Generate health report counts and formatting warnings without mutation.
- Generate review findings from health report signals.
- Select review finding and derive a navigation target without mutation.
- Verify Review Mode is read-only and can launch export actions.
- Backup M8 metadata and restore valid backups.
- Reject invalid restore while preserving current state.
- Require protection before restoring over dirty work.

## Deferred Work

- FDX import/export.
- Production-grade screenplay pagination.
- Revision-colored production PDFs.
- Collaboration/share links.
- Watermarks and locked shooting-script output.
- Full reviewer comment workflows.

## Open Questions

- Should backup artifacts be package folders, zipped packages, or both?
- Should Review Mode remember filter state per project or as app metadata?
- Which PDF renderer should become the first Apple adapter once production pagination specs exist?
