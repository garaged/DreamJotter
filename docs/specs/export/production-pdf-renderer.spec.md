# Production PDF Renderer Spec

Status: implementation-in-progress
Milestone: M10
Traceability ID: PRODUCTION-PDF-RENDERER

## Purpose

Replace the M9 single-page basic PDF adapter with a deterministic multi-page renderer that consumes `PDFLayoutPlan` and remains independent from SwiftUI and AppKit.

## Inputs

- `PDFLayoutPlan`
- Renderer metadata such as producer name

## Output

- Valid PDF 1.4 data
- One physical PDF page per `PDFPagePlan`
- Standard embedded resource references for monospaced regular and bold fonts

## Rendering Rules

- Use the page size and margins from `PDFLayoutSettings`.
- Render title-page content centered vertically and horizontally when the preset includes a title page.
- Render scene headings in bold.
- Render action and fallback text left aligned.
- Render character cues and parentheticals with screenplay-style indentation.
- Render dialogue in a narrower indented column.
- Render transitions right aligned.
- Render screenplay page numbers only when `includePageNumbers` is true.
- Never render internal paragraph, block, source-element, or line numbering.
- Preserve the planner's page boundaries and wrapped lines.
- Escape PDF literal-string control characters.
- Replace unsupported non-ASCII scalar values with a readable fallback character rather than producing invalid PDF bytes.

## Built-In PDF Preset Policies

### Reader Copy

- Includes a title page.
- Omits visible screenplay page numbers.
- Keeps normal project-facing title metadata.

### Print Script

- Includes a title page.
- Includes visible screenplay page numbers.
- Keeps normal project-facing title metadata.

### Contest Submission

- Omits the title page in the current privacy-safe implementation.
- Includes visible screenplay page numbers.
- Suppresses identifying metadata.

These policies must produce distinct PDF byte artifacts for the same project. The difference must come from actual layout policy, not timestamps or nondeterministic metadata.

## Preset Catalog Migration

- The export UI must always present the current built-in preset catalog.
- Presets stored in older project packages must not hide newer built-in presets.
- Obsolete stored built-ins are replaced by the current built-in definition with the same role.
- Genuine project-specific custom presets remain available.
- Merely opening the export dialog must not mutate or dirty the project.

## Workflow Integration

- `ExportWorkflow.exportData` must route `.pdf` through the production renderer.
- The renderer must build its plan through `PDFLayoutPlanner` using the selected preset.
- PDF export must preserve dirty state.
- Existing non-PDF export formats must remain unchanged.
- `BasicPDFExportAdapter` may remain temporarily as an explicit fallback, but must no longer be the normal PDF path.

## Diagnostics

- Layout warnings remain available from the plan.
- Renderer failure returns a failed `ExportResult` with a friendly user message and technical detail.
- Empty screenplay projects still produce a valid PDF artifact.

## Acceptance Criteria

- Multi-page plans produce matching PDF page counts.
- Title pages and screenplay pages use distinct numbering policy.
- Scene headings use bold font commands.
- Dialogue and transitions use distinct horizontal placement.
- Print Script and Contest Submission render screenplay page numbers.
- Reader Copy suppresses visible screenplay page numbers.
- Reader Copy, Print Script, and Contest Submission produce distinct deterministic PDF bytes.
- Older projects show the current built-in export presets without requiring project mutation.
- Notes and TODOs excluded by the planner do not appear in PDF bytes.
- PDF export succeeds through the existing workflow and does not dirty the project.
- Fountain, plain text, Markdown, and JSON backup behavior remains unchanged.

## Tests

- PDF header and trailer structure.
- Multi-page page-tree count.
- Title-page rendering.
- Role-specific font and position commands.
- Visible page-number policy by preset.
- Distinct deterministic output across built-in PDF presets.
- Legacy stored-preset catalog merged with current built-ins.
- Notes/TODO omission.
- Parentheses and backslash escaping.
- Unsupported-character fallback.
- Existing export workflow integration and dirty-state result.
