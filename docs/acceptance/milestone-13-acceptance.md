# Milestone 13 Acceptance — TextKit Editor Maturity

Status: implementation extended; automated build/test validation and manual acceptance pending.

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

## Paragraph type engine

### A-M13-PARAGRAPH-001: Shared semantic ownership

Given screenplay source text, when the editor resolves selection and style runs and the parser builds screenplay elements, then all consumers use the same paragraph boundaries and explicit-marker precedence.

### A-M13-PARAGRAPH-002: Dialogue context boundary

Given a completed character cue and dialogue block followed by a blank paragraph and prose, when the screenplay is parsed and printed, then the prose is Action and uses body-width PDF layout rather than the dialogue column.

### A-M13-PARAGRAPH-003: Deterministic separators

Given CRLF, CR, Unicode separators, or runs of blank lines, when paragraph boundaries are resolved, then the same ordered paragraphs and source ranges are produced.

## Formatting guide UX

### A-M13-GUIDE-001: Contextual help

Given the cursor is in a screenplay paragraph, when the paragraph inspector is visible, then it shows the current paragraph type, syntax example, and concise formatting guidance.

### A-M13-GUIDE-002: Complete guide

Given the writer expands Formatting Guide, then every editable paragraph type appears exactly once with its marker, example, and explanation that markers do not print.

## Character cue engine

### A-M13-CUE-001: Combined cue parsing

Given a cue such as `SOFÍA / TOM`, `ÍÑIGO & DOÑA ÁNGELES`, `MARA Y ELENA`, or `MARA AND ELENA`, when it is parsed, then it remains one Character Cue while each speaker is registered individually.

### A-M13-CUE-002: Segment-aware suggestions

Given the writer types `SOFÍA / TO`, when character suggestions appear, then matching suggestions replace only `TO`, preserve `SOFÍA /`, and exclude SOFÍA from the candidates.

### A-M13-CUE-003: Robust ranking

Given stored characters differ by case or accents, when a cue query is typed, then exact, full-prefix, word-prefix, and contained matches are ranked deterministically and duplicate suggestions are removed.

### A-M13-CUE-004: Printing consistency

Given a combined cue and following dialogue, when PDF layout is planned, then the cue uses Character Cue layout and the following text uses Dialogue layout.

## Keyboard autocomplete

### A-M13-AUTOCOMPLETE-001: Keyboard acceptance

Given suggestions are visible, when the writer presses Return or Tab, then the active suggestion is accepted before Smart Enter or element-kind cycling and the cursor lands after the replacement.

### A-M13-AUTOCOMPLETE-002: Keyboard selection and dismissal

Given multiple suggestions are visible, when the writer presses Up or Down Arrow, then the active suggestion changes. When Escape is pressed, suggestions close without changing screenplay text.

### A-M13-AUTOCOMPLETE-003: Accessible selected state

Given a suggestion is active, when VoiceOver inspects the suggestion list, then the active suggestion exposes a selected accessibility value and the keyboard controls are visible in the panel.

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

## Deterministic automated matrix

| Area | Automated evidence |
|---|---|
| Paragraph ownership | Shared selection/style ranges, marker precedence, mixed-separator boundaries |
| PDF regression | Post-dialogue prose remains body-width Action |
| Formatting guide | All editable types covered once; contextual guide wired into inspector |
| Combined cues | Separator parsing, canonicalization, individual character registration, PDF roles |
| Cue suggestions | Active segment replacement, accent-insensitive ranking, duplicate/existing-name filtering |
| Keyboard autocomplete | Return/Tab acceptance, arrow selection, Escape dismissal, selected accessibility state |

## Manual matrix

| Area | Scenario | Expected result |
|---|---|---|
| Undo | Type, Smart Enter, Tab cycle, paste, cut, autocomplete | One logical operation per undo step |
| Unicode | Accented names, combined cues, and composed emoji sequences | No split graphemes or cursor jumps |
| Selection | Partial line, full line, multi-line, all text | Stable selection after parse refresh |
| Autocomplete | Accept heading and single/combined character cue suggestions with keyboard | Correct segment replaced; cursor lands after inserted value |
| Accessibility | Navigate heading, cue, dialogue, note, and suggestions | VoiceOver announces meaningful type and active suggestion |
| Appearance | Increased Contrast and larger text | Semantic distinctions and guide remain readable |
| Persistence | Save, undo, redo; close and reopen | Save preserves live session; reopen resets history |
| Recovery | Switch to TextEditor mode | Same canonical text remains editable |
