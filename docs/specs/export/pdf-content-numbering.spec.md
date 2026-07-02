# PDF Content Numbering Spec

Status: implementation-in-progress
Milestone: M10
Traceability ID: PDF-CONTENT-NUMBERING

## Purpose

Define deterministic adapter-neutral numbering for PDF layout plans down to wrapped lines without changing canonical screenplay storage.

## Numbering Layers

1. `documentPageNumber`: one-based physical PDF page number, including an optional title page.
2. `screenplayPageNumber`: one-based screenplay content page number, excluding the title page; `nil` on title pages.
3. `blockNumber`: one-based page-local block number that resets on each page.
4. `paragraphNumber`: one-based document-wide screenplay paragraph number.
5. `lineNumber`: one-based wrapped-line number inside a paragraph.
6. `sourceElementIndex`: zero-based source screenplay element position used to create the plan.

## Paragraph Semantics

- One included screenplay element is one logical paragraph.
- Scene headings, action, character cues, parentheticals, dialogue, transitions, and readable fallback elements each consume a paragraph number.
- Wrapping produces multiple line numbers inside the same paragraph.
- Title-page blocks do not consume screenplay paragraph numbers.
- Page-break elements do not consume paragraph numbers.
- Notes and TODO elements omitted by preset policy do not consume paragraph numbers.
- Character cues and following dialogue remain separate paragraphs even when kept together during pagination.

## Stability

For identical project data, preset, and layout settings, all numbering is deterministic.

- Paragraph numbering is independent of visual wrapping.
- Block numbering may change when pagination changes because it is page-local.
- Line numbering may change when wrapping settings change.
- Source indexes may change after screenplay insertions or deletions.

Persistent cross-edit identity is deferred until canonical screenplay elements have stable IDs.

## Content Address

`PDFContentAddress` identifies a wrapped line using document page, screenplay page, block, paragraph, line, and source element numbers.

## Rendering Policy

The layout plan always carries numbering. Presets separately decide whether page numbers or any diagnostic numbering are visible in the rendered PDF. Paragraph and line numbers are not reader-facing by default.

## Acceptance Criteria

- Physical and screenplay page numbers are represented separately.
- Block numbers reset per page.
- Paragraph numbers remain document-wide and contiguous for included elements.
- Line numbers reset per paragraph.
- Page breaks and omitted notes do not consume paragraph numbers.
- Source element indexes retain plan-local traceability, including gaps for omitted elements.
- A line-level content address can be resolved from a plan.
- Identical inputs produce identical numbering.

## Tests

- Title page plus screenplay page numbering.
- Multi-line paragraph line numbering.
- Explicit page break with block reset and paragraph continuity.
- Omitted note with contiguous paragraph numbering and source-index gap.
- Line-level content-address lookup.
