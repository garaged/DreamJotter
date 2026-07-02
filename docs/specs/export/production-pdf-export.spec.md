# Production PDF Export Spec

Status: specified
Milestone: M10
Traceability ID: PRODUCTION-PDF-EXPORT

## Purpose

Define the production-oriented PDF export behavior that supersedes the basic M9 PDF adapter while preserving the existing export workflow and picker UX.

## User Stories

- As a beginner writer, I want a PDF that looks like a real screenplay without configuring technical options.
- As a reviewer, I want page numbers and readable formatting.
- As a contest submitter, I want identifying metadata omitted by default.
- As a developer, I want layout planning to be testable without depending on a platform renderer.

## Inputs

- Canonical `Project` data.
- Parsed screenplay elements.
- Export request.
- Export preset.
- PDF renderer capability information.

## Outputs

- PDF file artifact.
- Export result with output path, format, warnings, and failure diagnostics when applicable.
- Optional layout plan for tests or debug diagnostics.

## Layout Defaults

The first production pass should prefer deterministic, boring defaults over clever formatting.

Recommended defaults:

- US Letter page size for MVP unless a later setting selects A4.
- Monospaced body font where available.
- One screenplay line maps to predictable wrapped layout lines.
- Page numbers appear after title page where preset requires them.
- Internal notes and TODOs are excluded from reader-facing output.

Exact numeric margins and font metrics should be captured in implementation-facing tests once the renderer is selected.

## Element Formatting Rules

### Scene Heading

- Uppercase or preserve existing casing according to parser/export policy.
- Visually distinct from action.
- Starts a new block with spacing before when not at top of page.

### Action

- Left-aligned prose block.
- Wraps according to body width.

### Character Cue

- Centered or screenplay-cue aligned according to layout constants.
- Kept with following dialogue/parenthetical where practical.

### Parenthetical

- Narrower dialogue-adjacent block.
- Kept near surrounding dialogue where practical.

### Dialogue

- Narrower than action.
- Wraps deterministically.
- Should not orphan a character cue at the bottom of a page when avoidable.

### Transition

- Right-aligned or transition-aligned according to layout constants.

### Notes and TODOs

- Excluded from Reader Copy, Print Script, and Contest Submission by default.
- May produce non-fatal diagnostics if omitted notes exist and the user selected a reader-facing preset.

### Unknown or Malformed Elements

- Export as readable fallback text.
- Add warning diagnostics instead of failing the whole export.

## Pagination Rules

Pagination must be deterministic for the same input and settings.

Minimum rules:

- Content must not overlap page margins.
- Page numbers must not collide with body content.
- Character cue should stay with first dialogue line when possible.
- Explicit page break markers, if represented by the core model, should force a page break.
- Oversized blocks may split if they cannot fit on one page.
- Title page should not count as screenplay page 1 unless preset policy says otherwise.

## Preset Policy

### Reader Copy

- Defaults to PDF.
- Includes readable title information.
- Excludes internal metadata, notes, diagnostics, ignored detections, and implementation details.

### Print Script

- Defaults to PDF.
- Includes page numbers.
- May include title/author/project metadata appropriate for local printing.

### Contest Submission

- Defaults to PDF.
- Suppresses author-identifying metadata unless an explicit future option allows it.
- Excludes internal metadata and notes.

## Renderer Boundary

The production PDF exporter should be split into:

1. Layout planning.
2. Platform rendering.
3. File writing/export result mapping.

The layout planner should be testable without AppKit/SwiftUI where practical. The macOS renderer may use Apple PDF APIs behind an adapter.

## Failure and Diagnostics

Hard failures:

- Destination not writable.
- Renderer unavailable.
- Export request invalid.
- Project cannot be parsed enough to produce fallback output.

Warnings:

- Missing title metadata.
- Notes/TODOs omitted.
- Malformed element fallback.
- Unsupported layout feature.
- Font fallback used.

## Acceptance Criteria

- Production PDF export uses the existing export workflow entry point.
- Export picker does not need a new PDF-only UI to produce the improved output.
- Exporting PDF does not dirty the project.
- Page planning is deterministic under tests.
- Preset metadata privacy rules are respected.
- Notes/TODOs are excluded from reader-facing PDFs by default.
- Malformed text produces readable fallback output and warnings.
- Basic PDF adapter limitations are either removed or explicitly replaced by production diagnostics.

## Test Plan

Add executable coverage for:

- Simple one-scene screenplay PDF layout plan.
- Multi-scene page numbering.
- Character/dialogue keep-with-next behavior.
- Contest submission metadata suppression.
- Notes/TODO exclusion.
- Malformed element fallback warning.
- Export result dirty-state preservation.

## Open Questions

- Should M10 support A4 selection or defer it?
- Should title page content include logline/synopsis for Reader Copy?
- Should missing title metadata block Contest Submission or warn only?
- Should PDF layout planning live in `DreamJotterCore` or a new adapter-neutral layout module?
