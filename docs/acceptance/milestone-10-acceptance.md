# Milestone 10 Acceptance: Production PDF Export

Status: accepted
Milestone: M10
Traceability ID: M10-PRODUCTION-PDF-EXPORT

## Acceptance Summary

Milestone 10 is accepted. DreamJotter produces deterministic, production-oriented screenplay PDF exports through the existing export workflow without mutating project state. M10.1 closes the milestone with stable structural regression snapshots, empty-project and very-long-screenplay coverage, documentation cleanup, and an explicit compatibility decision for the former M9 adapter name.

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
- Internal block, paragraph, source-element, and line numbers are never rendered into reader-facing PDFs.

### Renderer Hardening

- Printable ASCII remains directly readable in PDF content streams.
- Windows-1252 characters use PDF octal escapes and are preserved by built-in Courier fonts.
- Unsupported Unicode characters fall back to `?` without corrupting PDF structure.
- Unsupported-character diagnostics are deterministic and de-duplicated.
- Layout warnings are forwarded through detailed renderer output.
- Successful exports with warnings remain successful and expose warning detail through `ExportResult`.
- Renderer warnings do not change project dirty state.

### Pagination

- Content stays inside page margins.
- Page numbers do not collide with body content.
- Character cue and first dialogue line stay together where practical.
- Oversized blocks split safely.
- Title page numbering policy is deterministic.
- Multi-page plans produce matching PDF page-tree counts.
- A very long screenplay paginates deterministically across many pages.

### Preset Privacy and Metadata

- Reader Copy excludes internal metadata by default.
- Print Script includes print-friendly page numbers.
- Contest Submission suppresses identifying metadata by default.
- Notes and TODOs are excluded from reader-facing PDFs by default.
- Screenplay presets prefer PDF by stable preset identifier while preserving format compatibility.

### Export Workflow Preservation

- PDF export uses the existing M9 export workflow entry point.
- M9.5 export picker invokes production PDF export without a PDF-only UI rewrite.
- The previous single-page renderer is no longer used.
- `BasicPDFExportAdapter` remains only as a deprecated compatibility facade over `ProductionPDFRenderer`.
- New code uses `ProductionPDFRenderer` directly.
- Export does not dirty the project.
- Fountain, Markdown, plain text, and JSON backup exports remain unchanged.

### Diagnostics

- Missing optional title metadata warns instead of crashing.
- Omitted notes/TODOs may be reported as non-fatal diagnostics.
- Malformed screenplay fallback produces warning diagnostics.
- Empty screenplay projects produce valid PDF data.

## Required Tests

- Simple one-scene PDF layout plan.
- Deterministic document, screenplay-page, block, paragraph, and line numbering.
- Line-level content-address lookup.
- Explicit page break with block-number reset and paragraph-number continuity.
- Stable representative screenplay structural snapshot.
- Empty-project PDF export.
- Very-long-screenplay deterministic pagination.
- Multi-page PDF page-tree count.
- Title-page rendering.
- Role-specific font and horizontal-position commands.
- Reader Copy page-number suppression.
- Print Script and Contest Submission page-number rendering.
- Notes/TODO exclusion.
- PDF string escaping.
- Windows-1252 accented text preservation.
- Unsupported Unicode fallback and de-duplicated diagnostics.
- Planner-warning forwarding.
- Export-result warning propagation and dirty-state preservation.

## Manual Verification

Title pages, page numbers, dialogue/parenthetical columns, character cues, and right-aligned transitions were reviewed against the layout plan and renderer command output. Reader Copy, Print Script, and Contest Submission policies were also reviewed for title-page behavior, screenplay-page numbering, and identifying-metadata suppression.

## Related Specs

- `docs/specs/export/production-pdf-export.spec.md`
- `docs/specs/export/pdf-content-numbering.spec.md`
- `docs/specs/export/production-pdf-renderer.spec.md`
- `docs/specs/export/pdf-renderer-hardening.spec.md`
- `docs/specs/export/m10-pdf-acceptance-closure.spec.md`

## Validation Commands

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

## Acceptance Decision

M10 is `accepted`. Future PDF work should be incremental compatibility, typography, or platform-rendering improvements driven by new specs; it must not reintroduce the removed single-page renderer or bypass `PDFLayoutPlanner`.
