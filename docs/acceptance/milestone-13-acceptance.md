# Milestone 13 Acceptance — TextKit Editor Maturity

Status: manual acceptance completed on 2026-07-04. Automated build and test results are tracked separately.

## Acceptance results

### Undo and command consistency

- Native typing undo/redo: passed.
- Smart Enter as one named undo step: passed.
- Tab element-type cycling as one named undo step: passed.
- Paste, cut, delete, redo, and autocomplete behavior: passed.
- Multi-element semantic edits: passed.

### Selection and cursor reliability

- Partial-line, full-line, multi-line, large, and select-all behavior: passed.
- Accented names and multi-scalar emoji remain grapheme safe: passed.
- Cursor and selection stability after parser refresh: passed.
- Repeated parser refreshes: passed.

### Autocomplete

- Scene headings: passed.
- Character cues and combined speakers: passed.
- Transitions: passed.
- Parentheticals: passed.
- Up/Down selection, Return/Tab acceptance, and Escape dismissal: passed.
- Empty paragraphs do not trigger character suggestions: passed.
- Exact completed matches do not remain visible as redundant suggestions: passed.

### Persistence and undo lifecycle

- Save preserves the current window's live undo history: passed.
- Undo and redo continue working after Save: passed.
- Closing and reopening starts a fresh undo session: passed.
- Undo history is not serialized into the project package: passed.

### Accessibility

- Editor is identified as a text area: passed.
- Current element type announcements: passed.
- Scene heading, character cue, dialogue, parenthetical, transition, and note announcements: passed.
- Keyboard navigation through suggestions: passed.
- Meaningful labels for suggestions and formatting warnings: passed.
- Suggestions and warnings are reachable without a pointing device: passed.

### Appearance

- Increased Contrast: passed.
- Larger system text settings: passed.
- Light appearance: passed.
- Dark appearance: passed.
- Empty-script onboarding visibility: passed.
- Onboarding does not intercept typing or selection: passed.

### Compatibility and stress

- Accented-character composition: passed.
- Marked-text and input-method behavior: passed.
- Large screenplays: passed.
- Prolonged editing sessions: passed.
- Large selections: passed.
- Repeated parser refreshes: passed.
- TextEditor recovery mode: passed.
- Field testing on supported macOS versions used for M13 acceptance: passed.

## Automated evidence

The implementation includes deterministic coverage for paragraph ownership, PDF dialogue/action boundaries, formatting guide completeness, combined cue parsing, autocomplete segment replacement, exact-match suppression, empty-row suppression, keyboard command routing, and accessibility selected state.

Automated build and test execution remains an independent release record and is not part of the completed manual matrix.

## Acceptance decision

The project owner confirmed that the complete manual editor, persistence, accessibility, appearance, compatibility, and stress matrix has been executed successfully. These items are accepted and are no longer pending.

See `docs/acceptance/m13-manual-checklist.md` for the detailed checked record.
