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

The Review UI exposes only three user-facing numbering levels:

- Page
- Paragraph
- Line

Defaults:

- Page: enabled.
- Paragraph: enabled.
- Line: disabled.

Block and source-element numbering remain available in the internal layout plan for diagnostics and tests, but are not exposed as Review UI controls because they overlap with paragraph numbering for normal review workflows.

## Display

- Page appears once as a page header.
- Paragraph appears in a compact gutter when line numbering is disabled.
- When line numbering is disabled, planner-wrapped lines are rejoined into one logical paragraph and SwiftUI wraps to the available pane width.
- When line numbering is enabled, Review Mode uses wider desktop-oriented planner wrapping rather than the narrower production-PDF body width.
- Paragraph and line numbers share one compact gutter in line mode.
- The paragraph marker appears only on the first wrapped line of its paragraph.
- Continuation lines do not reserve a separate empty paragraph column.
- Title-page blocks are excluded.
- Renderer role labels are not shown in the Review address.

The Review pane must keep screenplay text left-aligned and readable. It must not reuse PDF renderer centering, right-alignment, or narrow fixed screenplay column widths.

Review numbering is derived from `PDFLayoutPlanner` with the built-in Reader Copy preset and explicit Review layout settings. It is plan-local metadata, not persistent identity across edits.

## Acceptance Criteria

- The Review tab exposes Page, Paragraph, and Line controls only.
- Page and Paragraph are enabled by default.
- Line is disabled by default.
- Block and Source remain internal and are not shown as controls.
- Page metadata is not repeated for every paragraph.
- Paragraph text uses the available pane width when line numbering is disabled.
- Enabling Line uses a wider Review wrapping width than production PDF defaults.
- Line mode does not reserve separate paragraph and line gutters.
- Disabling the master toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
