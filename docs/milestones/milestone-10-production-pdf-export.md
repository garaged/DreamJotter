# Milestone 10: Production PDF Export

Status: specified
Milestone: M10
Traceability ID: M10-PRODUCTION-PDF-EXPORT

## Goal

Replace the intentionally basic M9 PDF export adapter with a production-oriented screenplay PDF export path that is suitable for reader copies, print review, and contest-style submissions.

## Product Outcome

- A writer can export a screenplay-like PDF with predictable pages.
- Reader Copy and Print Script outputs are visually credible.
- Contest Submission can suppress metadata according to preset policy.
- PDF export remains an artifact, not canonical storage.
- Layout rules are specified and testable before renderer-specific polish expands.

## Scope

- PDF layout contract for screenplay elements.
- Pagination rules for page size, margins, line wrapping, page breaks, and page numbers.
- Title page behavior for Reader Copy, Print Script, and Contest Submission.
- Header/footer policy.
- Scene heading, action, character, parenthetical, dialogue, transition, note-exclusion, and page-break behavior.
- Renderer adapter boundary for macOS PDF generation.
- Tests for layout planning and export-result diagnostics.

## Non-Goals

- No FDX import/export.
- No cloud sharing.
- No collaborative review links.
- No locked production pages or revision-colored production pages in this milestone.
- No plugin renderer API.
- No iOS/iPadOS PDF UI unless the macOS contract naturally supports it later.

## Architecture Rules

- Core layout planning must be adapter-neutral where practical.
- Platform PDF rendering belongs in an adapter.
- PDF files are export artifacts only.
- Export must not dirty the project.
- Presets must control metadata inclusion/exclusion.
- Unsupported renderer capabilities must return friendly diagnostics.
- Canonical screenplay text and project metadata must remain in `.dreamjotter` package storage, not inside PDF state.

## Feature Areas

### A. PDF Layout Contract

Define a screenplay PDF layout plan that can be generated from parsed screenplay elements and export preset settings.

The layout contract should represent:

- Page setup.
- Margins.
- Text style roles.
- Element blocks.
- Wrapped lines.
- Page numbers.
- Optional title page.
- Warnings or unsupported capabilities.

### B. Screenplay Element Formatting

Specify formatting for:

- Scene headings.
- Action.
- Character cues.
- Parentheticals.
- Dialogue.
- Transitions.
- Notes and TODOs.
- Unknown or malformed elements.

Notes and TODOs should be excluded from reader-facing outputs unless a future debug/review preset explicitly includes them.

### C. Pagination

Define deterministic pagination rules:

- Page size default.
- Margins default.
- Monospaced screenplay body style default.
- Line wrapping by element role.
- Keep-with-next behavior for character cue + dialogue.
- Widows/orphans policy where simple enough for MVP.
- Explicit page break support if present in screenplay data.

### D. Title Page

Define title page behavior:

- Reader Copy may include title, author, logline/synopsis policy as decided by preset.
- Print Script may include title and author/project metadata.
- Contest Submission must suppress identifying metadata unless explicitly allowed by preset.

### E. Export Preset Integration

M10 should preserve the M9/M9.5 preset names while making PDF output better.

Expected defaults:

- Reader Copy: PDF, readable title page, no internal metadata.
- Print Script: PDF, print-friendly page numbers and title page.
- Contest Submission: PDF, identity-safe metadata suppression.

### F. Diagnostics

Export results should report non-fatal warnings such as:

- Unsupported style detail.
- Missing title metadata.
- Malformed screenplay element fallback.
- Renderer capability unavailable.

## Acceptance Criteria

- PDF export produces deterministic page planning for the same project and preset.
- PDF export does not dirty the project.
- Reader Copy PDF excludes internal metadata by default.
- Contest Submission PDF suppresses identifying metadata according to preset policy.
- Print Script PDF includes page numbers.
- Character cues stay with following dialogue where practical.
- Notes/TODOs are excluded from reader-facing PDFs by default.
- Basic malformed input still exports a readable PDF with diagnostics instead of crashing.
- Existing Fountain, Markdown, plain text, and JSON backup export behavior remains unchanged.
- Existing M9.5 export picker can launch the production PDF path without UI rewrite.

## Related Specs

- `docs/specs/export/production-pdf-export.spec.md`
- `docs/specs/export/export-workflow-v1.spec.md`
- `docs/specs/export/export-presets-v1.spec.md`
- `docs/specs/export/basic-pdf-export-adapter.spec.md`
- `docs/data-contracts/export-request.md`
- `docs/data-contracts/export-result.md`
- `docs/data-contracts/export-preset.md`

## Executable Spec Plan

- Layout planner creates page blocks from a simple screenplay.
- Character cue and dialogue remain grouped across page boundaries when possible.
- Reader Copy excludes internal metadata.
- Contest Submission excludes identifying metadata.
- Print Script includes page numbers.
- Notes/TODOs are excluded from default PDF output.
- Malformed text produces readable fallback output and warning diagnostics.
- Export result includes output path and warnings without dirtying the project.

## Deferred Work

- Industry-perfect pagination parity with Final Draft.
- Locked production pages.
- Revision color pages.
- Watermarks.
- Batch export.
- FDX interoperability.
