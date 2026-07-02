# Milestone 10 Acceptance: Production PDF Export

Status: implementation-in-progress
Milestone: M10
Traceability ID: M10-PRODUCTION-PDF-EXPORT

## Acceptance Summary

Milestone 10 is accepted when DreamJotter can produce deterministic, production-oriented screenplay PDF exports through the existing export workflow without mutating project state.

## Required Acceptance Criteria

### Layout Planning

- PDF layout planning is deterministic for the same screenplay and preset.
- Layout planning is testable without requiring SwiftUI view state.
- Page setup, margins, body text roles, wrapped lines, and page numbers are represented explicitly enough for tests.

### Hierarchical Content Numbering

- Physical document page numbering is separate from screenplay content page numbering.
- Document page numbers are one-based and include an optional title page.
- Screenplay page numbers are one-based and exclude the title page.
- Block numbers are one-based and restart on each page.
- Paragraph numbers are one-based and continue across screenplay pages.
- Wrapped line numbers are one-based and restart inside each paragraph.
- Page-break elements do not consume paragraph numbers.
- Notes and TODO elements omitted by preset policy do not consume paragraph numbers.
- Source element indexes preserve plan-local traceability, including gaps for omitted elements.
- A line-level `PDFContentAddress` can be resolved from a page, block, and line position.
- Paragraph and line numbers are layout-plan metadata and are not rendered for readers by default.

### Production PDF Rendering

- One physical PDF page is emitted for every `PDFPagePlan`.
- Title-page and screenplay-page output are visually distinct.
- Scene headings and character cues use bold monospaced text.
- Action and fallback text use the body column.
- Parentheticals and dialogue use narrower indented columns.
- Transitions are right aligned.
- The renderer preserves planner page boundaries and wrapped lines.
- PDF control characters are escaped safely.
- Unsupported non-ASCII scalars fall back without corrupting the PDF structure.
- Internal block, paragraph, source-element, and line numbers are never rendered into reader-facing PDFs.

### Pagination

- Content stays inside page margins.
- Page numbers do not collide with body content.
- Character cue and first dialogue line stay together where practical.
- Oversized blocks split safely.
- Title page numbering policy is deterministic.
- Multi-page plans produce matching PDF page-tree counts.

### Preset Privacy and Metadata

- Reader Copy excludes internal metadata by default.
- Print Script includes print-friendly page numbers.
- Contest Submission suppresses identifying metadata by default.
- Notes and TODOs are excluded from reader-facing PDFs by default.

### Export Workflow Preservation

- PDF export uses the existing M9 export workflow entry point.
- M9.5 export picker can invoke production PDF export without a PDF-only UI rewrite.
- The previous single-page basic renderer is no longer used.
- `BasicPDFExportAdapter` may remain only as a compatibility facade over the production renderer.
- Export does not dirty the project.
- Fountain, Markdown, plain text, and JSON backup exports remain unchanged.

### Diagnostics

- Missing optional title metadata warns instead of crashing.
- Omitted notes/TODOs may be reported as non-fatal diagnostics.
- Malformed screenplay fallback produces warning diagnostics.
- Empty screenplay projects still produce valid PDF data.

## Required Tests

- Simple one-scene PDF layout plan.
- Deterministic document, screenplay-page, block, paragraph, and line numbering.
- Line-level content-address lookup.
- Explicit page break with block-number reset and paragraph-number continuity.
- Multi-page PDF page-tree count.
- Title-page rendering.
- Role-specific font and horizontal-position commands.
- Reader Copy page-number suppression.
- Print Script and Contest Submission page-number rendering.
- Notes/TODO exclusion.
- PDF string escaping and unsupported-character fallback.
- Existing export workflow integration.
- Export-result dirty-state preservation.

## Related Specs

- `docs/specs/export/production-pdf-export.spec.md`
- `docs/specs/export/pdf-content-numbering.spec.md`
- `docs/specs/export/production-pdf-renderer.spec.md`

## Validation Commands

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

## Acceptance Decision

M10 remains `implementation-in-progress` until the renderer branch passes package tests, macOS build validation, and manual PDF inspection from the app export workflow.
