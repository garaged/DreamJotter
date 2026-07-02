# Review Layout Numbering Spec

Status: implementation-in-progress
Milestone: M10
Traceability ID: REVIEW-LAYOUT-NUMBERING

## Purpose

Expose M10 PDF layout numbering in the macOS Review tab as read-only review coordinates.

## Behavior

- Review Mode shows a `Show layout numbering` toggle.
- The master toggle is enabled by default.
- Enabled mode shows a configurable numbered screenplay preview.
- Disabled mode shows the existing plain Fountain preview.
- Generating or toggling numbering must not dirty the project.

## Numbering Level Controls

The numbered preview exposes independent checkbox controls for Page, Paragraph, Block, Source element, and Line.

Defaults:

- Page: enabled.
- Paragraph: enabled.
- Block: disabled.
- Source element: disabled.
- Line: disabled.

Paragraph numbering is the primary default coordinate. Block, source-element, and line numbering are opt-in diagnostic detail.

## Display

- Page appears once as a page header, not on every screenplay block.
- Paragraph, block, and source identifiers appear in a compact fixed-width gutter.
- When line numbering is disabled, planner-wrapped lines are rejoined into one logical paragraph and SwiftUI wraps the paragraph to the available Review pane width.
- When line numbering is enabled, planner lines are shown separately with paragraph-local line numbers.
- Title-page blocks are excluded.
- Renderer role labels are not shown in the default Review address.

The Review pane must keep screenplay text left-aligned and readable. It must not reuse PDF renderer centering, right-alignment, or fixed screenplay column widths.

Review numbering is derived from `PDFLayoutPlanner` with the built-in Reader Copy preset. It is plan-local metadata, not persistent identity across edits.

## Fallback

An empty screenplay shows `No script text yet.` If Reader Copy cannot be resolved, Review Mode uses the plain preview.

## Acceptance Criteria

- The Review tab exposes the master toggle and numbering is visible by default.
- Independent checkboxes control page, paragraph, block, source-element, and line numbering.
- Page and paragraph are enabled by default.
- Block, source-element, and line numbering are disabled by default.
- Page metadata is not repeated for every block.
- Paragraph text uses the available pane width when line numbering is disabled.
- Disabling all address levels removes the gutter without hiding screenplay content.
- Numbered Review text remains left-aligned regardless of PDF layout role.
- Disabling the master toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
- Existing findings and export controls remain available.

## Tests

- Numbering option defaults match the specified low-noise configuration.
- Review rows contain expected hierarchical numbers.
- Reading review numbering preserves clean state.
- Reading review numbering preserves an already-dirty state.
