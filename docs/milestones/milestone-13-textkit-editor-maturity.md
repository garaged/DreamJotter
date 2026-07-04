# Milestone 13 — TextKit Editor Maturity

Status: implementation extended; deterministic regression validation pending before manual acceptance.

## Goal

Make the TextKit screenplay surface behave like a dependable native writing editor without moving canonical screenplay state into AppKit. Plain screenplay text and semantic project data remain authoritative; `NSTextView`, attributed styling, selection, and undo state remain adapter concerns.

## M13.1 Undo and command consistency

- Keep native typing undo and redo through `NSTextView`.
- Treat Smart Enter and element-kind cycling as named, atomic undo commands.
- Restore both text and grapheme-safe selection when undoing or redoing semantic editor commands.
- Treat one invoked semantic command as one command boundary, even when parsing changes multiple screenplay elements.
- Do not serialize undo history. Saving must not clear the live window's undo manager; reopening creates a fresh editor session with empty undo history.

## M13.2 Selection and formatting reliability

- Clamp external and parser-driven selections to complete Unicode grapheme clusters.
- Preserve multi-line ranges and expand partial composed-character ranges safely.
- Normalize pasted CRLF, CR, Unicode line separators, paragraph separators, and non-breaking spaces to canonical screenplay text.
- Copy and cut non-empty selections as complete paragraph-based screenplay blocks.
- Style scene headings, cues, dialogue, parentheticals, transitions, and note references without changing canonical text.
- Preserve the selection through parser refreshes and navigation requests.
- Autocomplete acceptance must publish a navigation request so the TextKit adapter restores the intended cursor.

## M13.3 Diagnostics and accessibility

- Expose the editor as an accessibility text area.
- Publish the current screenplay element type as accessibility custom content and help text.
- Keep suggestion actions accessible by descriptive labels and native keyboard focus.
- Scene headings, character cues, dialogue, parentheticals, transitions, and notes must have meaningful spoken element descriptions.
- Use semantic system colors and system font sizing so increased contrast and system text settings remain usable.
- Keep localized empty-script guidance visible without intercepting editor input.

## M13.4 Consolidation decision

Retain the SwiftUI `TextEditor` fallback as a documented recovery and compatibility mode for Milestone 13. It is not the default editor and must not receive screenplay-specific feature development. Remove it only after VoiceOver, input-method, large-document, undo/redo, and field-testing acceptance passes on supported macOS versions.

See `docs/editor/m13-textkit-consolidation-decision.md`.

## M13.5 Robust paragraph type engine

- Use one paragraph-boundary engine for editor selection, visual styling, parsing, and print/PDF semantics.
- Explicit paragraph markers always win over inference.
- Ambiguous unmarked paragraphs default to action rather than dialogue.
- A completed dialogue block cannot leak dialogue context into later action paragraphs.
- Mixed newline forms and runs of blank lines resolve to deterministic paragraph boundaries.
- PDF layout must consume the same resolved `ScreenplayParagraphType` used by the editor.
- The uploaded Print Script failure pattern is a required regression fixture: long prose after dialogue must remain body-width action.

## M13.6 Formatting guide UX

- Show contextual syntax and guidance for the paragraph at the cursor.
- Provide a discoverable in-editor formatting guide covering every editable paragraph type.
- Explain that markers are editor syntax and do not appear in rendered screenplay text or PDF output.
- Document dialogue-block boundaries and when explicit action/dialogue markers should be used.

## M13.7 Character cue and suggestion engine

- Parse Unicode character names and combined cues such as `SOFÍA / TOM`.
- Accept `/`, `&`, `+`, `AND`, and Spanish `Y` as input separators and emit ` / ` as the canonical separator.
- Register each member of a combined cue as an individual detected character.
- Suggest character names case- and accent-insensitively.
- Match full-name prefixes, individual word prefixes, and contained text with deterministic ranking.
- When editing a combined cue, replace only the active name segment and preserve existing speakers.
- Do not suggest a character already present in the cue.

## M13.8 Keyboard autocomplete

- Keep mouse acceptance available.
- Use Up and Down Arrow to move the active suggestion.
- Use Return or Tab to accept the active suggestion before Smart Enter or element-kind cycling.
- Use Escape to dismiss suggestions.
- Keep the cursor immediately after the accepted replacement.
- Expose selected suggestion state to accessibility.

## Acceptance gate

M13 is accepted when:

1. All M13 automated tests pass on macOS 14 and the current development macOS/Xcode toolchain.
2. Paragraph engine regressions prove that post-dialogue prose is action in parsing, editor styling, and PDF layout.
3. Combined cues parse, print, register individual characters, and autocomplete one active segment at a time.
4. Keyboard suggestion selection, acceptance, dismissal, and cursor restoration pass deterministic and manual checks.
5. Manual undo/redo checks pass for typing, Smart Enter, Tab cycling, paste, cut, autocomplete, and multi-element edits.
6. Unicode selection checks pass with accented Latin text and multi-scalar emoji.
7. VoiceOver identifies the editor, current screenplay element type, and selected suggestion.
8. Increased Contrast and larger system text checks remain legible.
9. Save leaves current-session undo behavior intact, while reopen starts a fresh undo session.
10. The compatibility editor decision is reflected in user-facing and architecture documentation.
