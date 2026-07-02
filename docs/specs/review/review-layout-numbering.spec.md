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

- Page appears as its own lightweight row above that page's screenplay blocks.
- Page numbering does not reserve any horizontal gutter in paragraph or line rows.
- Paragraph-only mode uses an intrinsic-width `P#` label beside the paragraph.
- Line-only mode uses an intrinsic-width line-number column.
- Paragraph-plus-line mode uses one intrinsic-width shared label column.
- In paragraph-plus-line mode, the first line label uses `P# · L#`; continuation lines use only `L#`.
- Paragraph labels use the same caption and secondary styling whether Line is enabled or disabled.
- Disabled numbering levels allocate zero horizontal space.
- No hard-coded paragraph or line gutter widths are used.
- When Line is disabled, planner lines are rejoined into one paragraph and SwiftUI wraps to the available width.
- Title-page blocks are excluded.

The Review pane keeps text left-aligned and does not reuse renderer-specific alignment or narrow PDF columns.

## Acceptance Criteria

- The Review tab exposes Page, Paragraph, and Line controls only.
- Page and Paragraph are enabled by default.
- Line is disabled by default.
- Page metadata is rendered independently from paragraph and line columns.
- Paragraph styling is consistent with Line on or off.
- Disabled numbering levels reserve no gutter width.
- Paragraph-only and line-only modes use only the space required by their visible labels.
- Paragraph-plus-line mode uses one shared intrinsic-width label column.
- Disabling the master toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
