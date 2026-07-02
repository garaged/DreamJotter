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

The Review UI exposes only Page, Paragraph, and Line controls.

Defaults:

- Page: enabled.
- Paragraph: enabled.
- Line: disabled.

Block and source-element numbering remain internal for diagnostics and tests.

## Display

- Page does not appear as a standalone row.
- Page does not reserve a separate column.
- When Page and Paragraph are enabled, the gutter uses `page.paragraph`, such as `1.4`.
- When only Paragraph is enabled, the gutter uses `P4`.
- When only Page is enabled, the gutter uses the page number.
- When Line is disabled, planner lines are rejoined into one paragraph and SwiftUI wraps to the available width.
- When Line is enabled, page, paragraph, and line numbers share one compact gutter.
- The page and paragraph address appears only on the first wrapped line.
- Continuation lines show only their line number.
- Title-page blocks are excluded.

The Review pane keeps text left-aligned and does not reuse renderer-specific alignment or narrow PDF columns.

## Acceptance Criteria

- The Review tab exposes Page, Paragraph, and Line controls only.
- Page and Paragraph are enabled by default.
- Line is disabled by default.
- Page metadata creates no standalone row or dedicated column.
- Page and paragraph numbering share one compact gutter address.
- Line mode does not reserve separate page, paragraph, and line gutters.
- Disabling the master toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
