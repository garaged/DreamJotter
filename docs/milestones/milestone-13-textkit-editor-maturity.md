# Milestone 13 — TextKit Editor Maturity

Status: implementation complete. Manual editor, persistence, accessibility, appearance, compatibility, and stress validation passed on 2026-07-04. Automated build and test results are tracked separately.

## Goal

Make the TextKit screenplay editor behave like a dependable native writing surface while keeping plain screenplay text and semantic project data authoritative.

## Implemented scope

### Undo and commands

Native typing undo/redo, Smart Enter, Tab type cycling, paste, cut, deletion, autocomplete, cursor restoration, and multi-element semantic edits use the expected undo boundaries. Saving preserves the current window's live undo history. Reopening starts a fresh session, and undo history is never serialized.

### Selection and formatting

Selections remain grapheme-safe across accented text, emoji, parser refreshes, navigation, partial lines, full lines, multi-line ranges, large selections, and select-all. Paste normalization and paragraph-based copy/cut remain canonical.

### Accessibility and appearance

The editor exposes a text-area role and meaningful element descriptions for scene headings, character cues, dialogue, parentheticals, transitions, and notes. Suggestions and warnings are keyboard reachable and VoiceOver readable. Increased Contrast, larger system text, light and dark appearance, and empty-script onboarding passed validation.

### Compatibility

The SwiftUI `TextEditor` remains a recovery-only fallback. Switching editors preserves canonical editable text. TextKit passed accented composition, marked-text/input-method behavior, large-screenplay use, prolonged sessions, large selections, repeated parser refreshes, and field testing on supported macOS versions used for M13 acceptance.

### Paragraph type engine

Editor styling, semantic parsing, and PDF layout share deterministic paragraph boundaries and explicit-marker precedence. Ambiguous prose defaults to Action, completed dialogue cannot leak into later prose, and mixed newline forms remain stable.

### Formatting guide

The paragraph inspector provides syntax, examples, concise guidance, and selected-type “How to use this type” help, including novice distinctions such as Action versus Dialogue, Synopsis versus Action, and Shot or Page Break versus normal layout.

### Character cues and autocomplete

Unicode names, combined cues, active-segment replacement, case/accent-insensitive matching, deterministic ranking, keyboard acceptance, and accessible selection are implemented. Empty paragraphs do not trigger character suggestions, and exact completed matches are suppressed.

## Manual acceptance record

The project owner confirmed all of the following as tested and working:

- typing undo/redo;
- Smart Enter and Tab cycling as named undo steps;
- paste, cut, delete, redo, and multi-element semantic edits;
- partial-line, full-line, multi-line, large, and select-all behavior;
- accented names and multi-scalar emoji;
- autocomplete for headings, cues, transitions, and parentheticals;
- cursor stability after parser refresh;
- TextEditor recovery mode;
- save/undo/redo/reopen lifecycle and nonserialized undo history;
- VoiceOver roles, element announcements, suggestion navigation, and warning labels;
- Increased Contrast, larger system text, light/dark appearance, and nonintercepting onboarding;
- accented composition, input methods, large screenplays, prolonged editing, repeated refreshes, and supported-macOS field testing.

Manual acceptance is closed. See `docs/acceptance/m13-manual-checklist.md` for the checked record.

## Remaining release evidence

Only automated build and test results remain to be recorded independently before final milestone closure.
