# Milestone 13 Acceptance — TextKit Editor Maturity

Status: implementation complete; validation pending.

## Undo and command consistency

### A-M13-UNDO-001: Native typing undo

Given the TextKit editor is active, when the writer types, pastes, cuts, or deletes text, then macOS Undo and Redo restore the expected text and selection using the editor's native undo manager.

### A-M13-UNDO-002: Semantic command grouping

Given the cursor is in a screenplay element, when Smart Enter or element-kind cycling changes text and parser state, then the complete command is represented by one named undo step and undo restores both text and cursor position.

### A-M13-UNDO-003: Save and reopen expectations

Given an open project has live undo history, when the project is saved, then the current editor session keeps its undo expectations. When the package is closed and reopened, then the new editor session starts without serialized undo history.

## Selection and formatting reliability

### A-M13-SELECTION-001: Grapheme-safe selection

Given screenplay text contains composed Unicode characters, accented names, or emoji, when parser refresh, navigation, or external binding updates restore a range, then the range never splits a grapheme cluster.

### A-M13-SELECTION-002: Multi-line semantic block copy and cut

Given a non-empty selection spans screenplay lines, when the writer copies or cuts, then DreamJotter transfers complete paragraph-based screenplay blocks as plain canonical text.

### A-M13-PASTE-001: Canonical paste

Given text copied from another application contains mixed newline formats, Unicode line separators, paragraph separators, or non-breaking spaces, when it is pasted, then DreamJotter normalizes it to LF newlines and ordinary spaces before parsing.

### A-M13-CURSOR-001: Parser and autocomplete stability

Given parser refresh or autocomplete updates screenplay text, when the TextKit view reconciles the new value, then the cursor or selection is restored to a valid grapheme-safe range and requested navigation is applied once.

### A-M13-STYLE-001: Screenplay visual hierarchy

Given parsed style runs are available, when the editor renders, then scene headings, character cues, dialogue, parentheticals, transitions, and note references have distinguishable system-color and system-font styling without changing canonical text.

## Diagnostics and accessibility

### A-M13-A11Y-001: Current element exposure

Given VoiceOver or another accessibility client inspects the editor, when the selection moves, then the editor exposes a text-area role and the current screenplay element type as accessibility help and custom content.

### A-M13-A11Y-002: Suggestions and warnings

Given suggestions or formatting warnings are visible, when the writer uses keyboard navigation or VoiceOver, then each action has a meaningful localized label and can be reached without a pointing device.

### A-M13-A11Y-003: Contrast, type, and onboarding

Given Increased Contrast or system text changes are enabled, when the editor and empty-script onboarding render, then content remains legible, uses semantic system colors, and onboarding does not intercept editing input.

## Consolidation

### A-M13-CONSOLIDATION-001: Compatibility fallback

Given TextKit is the default editor, when a platform-specific TextKit issue prevents editing, then the writer may switch to the documented TextEditor compatibility mode. The fallback is recovery-only and receives no screenplay-specific feature development.

## Manual matrix

| Area | Scenario | Expected result |
|---|---|---|
| Undo | Type, Smart Enter, Tab cycle, paste, cut | One logical operation per undo step |
| Unicode | Accented names and composed emoji sequences | No split graphemes or cursor jumps |
| Selection | Partial line, full line, multi-line, all text | Stable selection after parse refresh |
| Autocomplete | Accept heading, cue, transition, parenthetical | Cursor lands after inserted value |
| Accessibility | Navigate heading, cue, dialogue, note | VoiceOver announces meaningful type |
| Appearance | Increased Contrast and larger text | Semantic distinctions remain readable |
| Persistence | Save, undo, redo; close and reopen | Save preserves live session; reopen resets history |
| Recovery | Switch to TextEditor mode | Same canonical text remains editable |
