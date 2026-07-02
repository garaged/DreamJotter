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

The numbered preview exposes independent checkbox controls for:

- Page
- Paragraph
- Block
- Source element
- Line

Defaults:

- Page: enabled.
- Paragraph: enabled.
- Block: enabled.
- Source element: disabled.
- Line: disabled.

Line numbering is disabled by default to avoid visual noise. Source-element numbering is also disabled by default because it is mainly diagnostic metadata. Users can enable either level when more atomic review coordinates are needed.

## Display

Enabled address levels are joined into one compact block label. Each wrapped line displays its paragraph-local line number only when the Line checkbox is enabled. Title-page blocks are excluded.

The Review pane must keep screenplay text left-aligned and readable. It must not reuse renderer-specific centering or right-alignment rules from `PDFTextAlignment`; those rules belong to eventual PDF output, not the review UI.

Review numbering is derived from `PDFLayoutPlanner` with the built-in Reader Copy preset. It is plan-local metadata, not persistent identity across edits.

## Fallback

An empty screenplay shows `No script text yet.` If Reader Copy cannot be resolved, Review Mode uses the plain preview.

## Acceptance Criteria

- The Review tab exposes the master toggle and numbering is visible by default.
- Independent checkboxes control page, paragraph, block, source-element, and line numbering.
- Page, paragraph, and block are enabled by default.
- Source-element and line numbering are disabled by default.
- Disabling all address levels removes the block address label without hiding screenplay content.
- Numbered Review text remains left-aligned regardless of PDF layout role.
- Disabling the master toggle restores plain Fountain text.
- Reading numbering preserves project data and dirty state.
- Existing findings and export controls remain available.

## Tests

- Numbering option defaults match the specified low-noise configuration.
- Review rows contain expected hierarchical numbers.
- Reading review numbering preserves clean state.
- Reading review numbering preserves an already-dirty state.
