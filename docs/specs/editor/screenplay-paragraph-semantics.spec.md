# Screenplay Paragraph Semantics

Status: Implemented in M13.1

## Problem

DreamJotter currently infers screenplay paragraph types from neighboring text. This is useful while typing, but it is not a safe source of truth. A character cue can leak dialogue context across a blank paragraph and cause later action prose to be rendered in the dialogue column. The editor and PDF renderer must agree on one semantic type for every screenplay paragraph.

## Goals

1. Give every parsed screenplay element an explicit paragraph semantic.
2. Preserve user-selected paragraph semantics across save, reopen, export, and PDF layout.
3. Keep automatic inference as a convenience only.
4. End dialogue context at blank paragraph boundaries and structural elements.
5. Expose the current paragraph type in the script editor and allow changing it.
6. Support the common screenplay paragraph set:
   - Scene Heading / Slugline
   - Action
   - Character Cue
   - Dialogue
   - Parenthetical
   - Transition
   - Shot
   - Section
   - Synopsis
   - Montage
   - Character Introduction
   - Note
   - Page Break

## Canonical model

`ScreenplayParagraphType` is the canonical semantic model. `ScriptElementKind` remains the lower-level compatibility/rendering kind.

Each `ScriptElement` stores an optional `paragraphType`. Older project files decode without it and derive a compatible type from `kind`.

## Explicit source markers

User-selected types are serialized into screenplay text with reversible markers:

| Paragraph type | Marker |
| --- | --- |
| Scene Heading | `.` |
| Action | `!` |
| Character Cue | `@` |
| Dialogue | `:` |
| Parenthetical | parentheses |
| Transition | `>` |
| Shot | `!!` |
| Section | `#` |
| Synopsis | `=` |
| Montage | `%%` |
| Character Introduction | `+` |
| Note | `[[...]]` |
| Page Break | `===` |

Markers are parser syntax. Rendered app text and PDF output use the marker-free element text.

## Inference rules

- Explicit markers always win.
- Blank lines terminate dialogue context.
- A parenthetical or unmarked dialogue line is dialogue only while an active character cue exists in the same contiguous dialogue block.
- Structural elements terminate dialogue context.
- Uppercase text may be inferred as a character cue only when the following non-empty line is a plausible dialogue/parenthetical line.
- Montage headings are recognized explicitly through `%%` and never inferred from arbitrary uppercase prose.
- Character introductions are explicit through `+` and render as action-width text.

## Editor behavior

The script editor shows a Paragraph Type inspector beside the editor. It displays the type at the current cursor paragraph and provides a picker for changing it. Changing the type rewrites only that paragraph using the canonical marker and keeps the cursor in the paragraph.

The inspector also shows a short formatting description so writers can distinguish semantic intent from typography.

## PDF behavior

- Scene headings use scene-heading styling.
- Character cues, dialogue, and parentheticals use screenplay dialogue-column positions.
- Action, character introductions, montage text, sections, synopsis, and notes use body-width layout unless a dedicated role already exists.
- Dialogue-column width is applied only when the canonical paragraph type is dialogue.
- Print Script includes page and paragraph numbers, never line numbers.

## Compatibility

- Existing projects with no paragraph type metadata remain readable.
- Existing Fountain-compatible markers continue to parse.
- New custom markers are preserved by DreamJotter export/import.
- Unknown text remains readable action/fallback content rather than causing export failure.

## Acceptance criteria

1. A blank line after a character cue/dialogue block prevents the next paragraph from becoming dialogue.
2. Explicit Action after a character cue remains action in the editor and PDF.
3. Explicit Dialogue remains dialogue even when inference would not select it.
4. All supported paragraph types round-trip through parse and export.
5. The editor inspector reports and changes the current paragraph type.
6. PDF layout uses the same semantic type as the editor.
7. Print Script emits page and paragraph numbering only.
