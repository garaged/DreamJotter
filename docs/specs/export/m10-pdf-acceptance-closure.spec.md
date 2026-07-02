# M10 PDF Acceptance Closure

Status: accepted
Milestone: M10.1
Traceability ID: M10-PDF-ACCEPTANCE-CLOSURE

## Purpose

Close Milestone 10 after the layout planner, hierarchical numbering, production renderer, renderer hardening, and PDF-first preset migration have been implemented. This is a documentation and regression-hardening slice, not a renderer rewrite.

## Decisions

- `PDFLayoutPlanner` remains the adapter-neutral source of deterministic pagination and content numbering.
- `ProductionPDFRenderer` remains the production PDF implementation used by `ExportWorkflow`.
- `BasicPDFExportAdapter` is retained as a deprecated compatibility facade. It delegates directly to `ProductionPDFRenderer` and contains no independent rendering behavior.
- Regression protection uses stable structural layout snapshots rather than checked-in binary PDF files. Binary PDF offsets are implementation details; page, block, role, text, numbering, and renderer structure are the behavior contract.
- Registry extensions named `specs/registry*.yml` are first-class registry inputs and are validated and traced with the primary registry.
- `docs/acceptance/traceability-matrix-m10.md` is the accepted M10 extension to the project traceability surface.

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

## Documentation Integration

- README reports M10 as accepted and describes production PDF capabilities.
- TODO contains maintenance work rather than future/basic renderer implementation work.
- `specs/registry-m10-pdf-closure.yml` uses the canonical registry schema.
- `scripts/spec-check` validates the primary registry and registry extensions as one combined registry, including duplicate-ID detection.
- `scripts/spec-trace` displays items from the primary registry and registry extensions together.
- `docs/acceptance/traceability-matrix-m10.md` records accepted traceability for planning, numbering, rendering, hardening, preset migration, and closure.

## Acceptance

M10 is accepted. Future PDF changes must be incremental, separately specified, and covered by structural or executable regression tests; they must not reintroduce the removed single-page renderer or bypass `PDFLayoutPlanner`.
