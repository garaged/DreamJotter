# Milestone 13.1 — Screenplay Paragraph Semantics

## Objective

Replace fragile neighbor-only paragraph inference with explicit, writer-controlled screenplay semantics shared by parsing, editor presentation, persistence, and PDF export.

## Delivery slices

### 13.1.1 Canonical semantic model

- Add `ScreenplayParagraphType`.
- Store paragraph semantics on `ScriptElement` with backward-compatible decoding.
- Define compatibility mapping to `ScriptElementKind`.

### 13.1.2 Parser and round-trip rules

- Reset dialogue context at blank paragraph boundaries.
- Add explicit markers for dialogue, montage, character introduction, shot, and existing paragraph types.
- Preserve explicit types through Fountain export/import.
- Keep inference only for unmarked text.

### 13.1.3 Editor paragraph inspector

- Track the paragraph under the TextKit cursor.
- Display its semantic type and formatting description.
- Allow changing the paragraph type through a picker.
- Rewrite only the selected paragraph and preserve navigation.

### 13.1.4 Rendering alignment

- Make PDF planning consume canonical paragraph semantics.
- Restrict dialogue width to canonical dialogue.
- Render character introduction and montage at body width.
- Keep Print Script page and paragraph numbering without line labels.

### 13.1.5 Regression hardening

- Add parser context-boundary tests.
- Add round-trip tests for all paragraph types.
- Add editor type-change tests.
- Add PDF role and width tests.

## Out of scope

- Dual dialogue columns.
- Production revision colors and locked-page revision marks.
- Rich-text storage replacing Fountain text.
- Automatic screenplay rewriting.

## Acceptance

M13.1 is accepted when the editor and PDF export report/render the same paragraph type, explicit writer choices survive round trips, and prose after a completed dialogue block can no longer inherit dialogue formatting.
