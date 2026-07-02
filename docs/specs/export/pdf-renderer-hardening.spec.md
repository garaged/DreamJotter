# PDF Renderer Hardening Spec

Status: implementation-in-progress
Milestone: M10
Traceability ID: PDF-RENDERER-HARDENING

## Purpose

Harden the production PDF renderer without changing the existing export workflow or reader-facing screenplay layout.

## Scope

This slice adds:

- deterministic renderer diagnostics
- propagation of non-fatal PDF warnings through `ExportResult`
- Windows-1252-safe literal-string encoding for built-in Courier fonts
- graceful fallback for unsupported Unicode characters
- regression coverage for accented Latin text and warning behavior

A4 selection, embedded fonts, precise typographic metrics, and advanced revision-page locking remain deferred.

## Renderer Output Contract

`ProductionPDFRenderer` exposes a detailed output containing:

- rendered PDF `Data`
- ordered, de-duplicated renderer diagnostics

The existing `render(project:preset:) -> Data` and `render(plan:) -> Data` entry points remain source-compatible and delegate to the detailed output path.

## Diagnostics

Diagnostics are non-fatal unless PDF assembly fails.

Required diagnostic categories:

- layout warning forwarded from `PDFLayoutPlan`
- unsupported character replaced during PDF encoding

Diagnostics must be deterministic for the same project and preset. Repeated unsupported characters produce one diagnostic per distinct character.

## Text Encoding

- PDF content streams remain ASCII-safe.
- Printable ASCII is emitted directly with PDF escaping for backslash and parentheses.
- Characters representable in Windows-1252 are emitted using three-digit PDF octal escapes.
- Common Western European text such as `café`, `señor`, curly quotes, and em dashes must not be replaced with `?`.
- Characters not representable in Windows-1252 are replaced with `?` and reported as warnings.
- Newlines, carriage returns, and tabs inside literal strings are normalized to spaces.

## Export Workflow Integration

- Successful PDF export with no warnings keeps `userMessage == "Export complete."`.
- Successful PDF export with warnings keeps status `.success` and uses `userMessage == "Export complete with warnings."`.
- Warning details are joined into `ExportResult.technicalDetail`.
- Warnings do not change dirty state.
- Non-PDF export behavior remains unchanged.

## Acceptance Criteria

- Existing PDF renderer APIs continue compiling.
- Accented Windows-1252 text is preserved in PDF bytes through octal escapes.
- Unsupported Unicode is replaced and reported.
- Duplicate unsupported characters do not duplicate diagnostics.
- Planner warnings are forwarded by the renderer.
- Export workflow surfaces warnings as successful export feedback.
- Deterministic input produces deterministic PDF bytes and diagnostics.

## Tests

- Windows-1252 accented text encoding.
- PDF escaping for backslash and parentheses.
- Unsupported emoji fallback and diagnostic.
- Duplicate unsupported-character de-duplication.
- Planner warning forwarding.
- ExportResult warning propagation and dirty-state preservation.
- Existing production renderer tests remain green.
