# Review Layout Numbering Spec

Status: implementation-in-progress
Milestone: M10
Traceability ID: REVIEW-LAYOUT-NUMBERING

## Purpose

Expose M10 PDF layout numbering in the macOS Review tab as read-only review coordinates.

## Behavior

- Review Mode shows a `Show layout numbering` toggle.
- The toggle is enabled by default.
- Enabled mode shows numbered screenplay blocks and wrapped lines.
- Disabled mode shows the existing plain Fountain preview.
- Generating or toggling numbering must not dirty the project.

## Display

Each block shows screenplay page, paragraph, page-local block, and source-element numbers. Each wrapped line shows its paragraph-local line number. Title-page blocks are excluded.

Review numbering is derived from `PDFLayoutPlanner` with the built-in Reader Copy preset. It is plan-local metadata, not persistent identity across edits.

## Fallback

An empty screenplay shows `No script text yet.` If Reader Copy cannot be resolved, Review Mode uses the plain preview.

## Acceptance Criteria

- The Review tab exposes the toggle and numbering is visible by default.
- Page, paragraph, block, source-element, and line numbers are displayed.
- Disabling the toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
- Existing findings and export controls remain available.

## Tests

- Review rows contain expected hierarchical numbers.
- Reading review numbering preserves clean state.
- Reading review numbering preserves an already-dirty state.
