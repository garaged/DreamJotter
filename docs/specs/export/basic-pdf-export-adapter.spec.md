# Basic PDF Export Adapter Spec

Status: specified
Milestone: M9
Traceability ID: BASIC-PDF-EXPORT-ADAPTER

## User Goal

As a writer, I want a readable PDF copy of my screenplay even before production-perfect pagination exists.

## Scope

- Basic PDF output from semantic screenplay/plain screenplay text.
- Monospaced screenplay-style text.
- Scene headings visually distinguishable.
- Readable margins and page numbers if practical.

## Non-Goals

- No locked pages.
- No revision colors.
- No watermarking.
- No Final Draft-perfect layout.
- No TextKit styling as canonical data.

## Acceptance Criteria

- Given a simple screenplay, when exported as PDF, then a readable PDF file is produced.
- Given a multi-scene screenplay, then scenes appear in script order.
- Given Reader Copy or Contest Submission, internal notes are excluded unless explicitly included.
- Given PDF export fails, the app shows a friendly error.
- Given PDF export succeeds, dirty state is unchanged.

## Architecture Notes

The PDF adapter may be Apple-specific, but export requests/results and semantic source data must remain portable.

## Data Model Implications

Uses `ExportRequest` and `ExportResult`; may use adapter diagnostics.

## Testability Notes

Initial tests may validate nonempty PDF-like output or adapter result metadata rather than pixel-perfect rendering.

## Open Questions

- Should the first implementation use PDFKit/AppKit rendering or a pure text-to-PDF adapter?
