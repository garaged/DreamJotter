# M10 PDF Acceptance Closure

Status: accepted
Milestone: M10.1
Traceability ID: M10-PDF-ACCEPTANCE-CLOSURE

## Purpose

Close Milestone 10 after the layout planner, hierarchical numbering, production renderer, renderer hardening, and PDF-first preset migration have been implemented. This is a documentation and regression-hardening slice, not a renderer rewrite.

## Decisions

- `PDFLayoutPlanner` remains the adapter-neutral source of deterministic pagination and content numbering.
- `ProductionPDFRenderer` remains the production PDF implementation used by `ExportWorkflow`.
- `BasicPDFExportAdapter` is retained as a deprecated compatibility facade. It must delegate directly to `ProductionPDFRenderer` and must not contain independent rendering behavior.
- Regression protection uses stable structural layout snapshots rather than checked-in binary PDF files. Binary PDF offsets are implementation details; page, block, role, text, numbering, and renderer structure are the behavior contract.

## Required Regression Coverage

- A representative screenplay has a stable structural layout snapshot.
- An empty project produces valid PDF data and a deterministic page tree.
- A very long screenplay paginates deterministically across many pages without explicit page breaks.
- The renderer page-tree count matches the planner page count.
- The final content from a long screenplay is present in the PDF artifact.
- Existing tests continue to cover title pages, screenplay page numbers, dialogue and parenthetical columns, transition alignment, privacy rules, diagnostics, and export dirty-state preservation.

## Manual Verification Record

The M10 renderer command structure and exported artifacts were reviewed for:

- title page separation and centered title treatment;
- screenplay page numbers on Print Script and Contest Submission, and suppression on Reader Copy;
- character, parenthetical, and dialogue column indentation;
- right-aligned transitions;
- title-page exclusion from screenplay page numbering;
- omission of notes, TODOs, and identifying metadata where preset policy requires it.

Manual verification complements executable tests and does not replace them.

## Compatibility Policy

`BasicPDFExportAdapter` remains public for compatibility with callers compiled against the M9 API. It is deprecated and may be removed only in a future breaking release after migration guidance is documented.

## Acceptance

M10 is accepted when registry and traceability statuses are updated, stale basic/future PDF wording is removed, regression tests pass, and the macOS app target builds successfully.
