# Milestone 13 — TextKit Editor Maturity

Status: implemented pending build, automated, accessibility, and manual acceptance validation.

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

## Acceptance gate

M13 is accepted when:

1. All M13 automated tests pass on macOS 14 and the current development macOS/Xcode toolchain.
2. Manual undo/redo checks pass for typing, Smart Enter, Tab cycling, paste, cut, autocomplete, and multi-element edits.
3. Unicode selection checks pass with accented Latin text and multi-scalar emoji.
4. VoiceOver identifies the editor and current screenplay element type.
5. Increased Contrast and larger system text checks remain legible.
6. Save leaves current-session undo behavior intact, while reopen starts a fresh undo session.
7. The compatibility editor decision is reflected in user-facing and architecture documentation.
