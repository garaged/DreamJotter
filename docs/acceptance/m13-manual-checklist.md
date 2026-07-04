# M13 Manual Validation Checklist

Status: completed and accepted by the project owner on 2026-07-04.

## Editor behavior

- [x] Native typing undo and redo work as expected.
- [x] Smart Enter is represented by one named undo step.
- [x] Tab element-type cycling is represented by one named undo step.
- [x] Paste, cut, delete, undo, and redo preserve the expected text and selection.
- [x] Multi-element semantic edits undo and redo as one logical operation where required.
- [x] Partial-line, full-line, multi-line, and select-all operations remain stable.
- [x] Accented names and multi-scalar emoji preserve grapheme-safe selection.
- [x] Heading, character cue, transition, and parenthetical autocomplete works.
- [x] Up and Down Arrow change the active suggestion while TextKit is focused.
- [x] Return and Tab accept the active suggestion without requiring a click.
- [x] Escape dismisses suggestions without changing screenplay text.
- [x] Combined cues such as `SOFÍA / TOM` autocomplete and print correctly.
- [x] Parser refresh preserves cursor and selection stability.
- [x] Switching to TextEditor recovery mode preserves canonical editable text.

## Persistence and undo lifecycle

- [x] Saving preserves the current window's live undo history.
- [x] Undo and redo continue working after Save.
- [x] Closing and reopening a package starts a new session with empty undo history.
- [x] Undo history is not serialized into the project package.

## Accessibility

- [x] VoiceOver identifies the editor as a text area.
- [x] VoiceOver announces the current screenplay element type.
- [x] Scene headings, character cues, dialogue, parentheticals, transitions, and notes have meaningful announcements.
- [x] Suggestions can be navigated and accepted without a pointing device.
- [x] Active suggestions expose a meaningful selected state and label.
- [x] Formatting warnings and suggestion actions have meaningful accessible labels.

## Appearance

- [x] Increased Contrast remains legible.
- [x] Larger system text settings remain usable.
- [x] Light and dark appearances remain readable.
- [x] Empty-script onboarding is visible when appropriate.
- [x] Empty-script onboarding does not intercept typing or selection.

## Compatibility and stress

- [x] Accented-character composition works.
- [x] Marked-text and input-method behavior remains stable.
- [x] Large screenplays remain usable.
- [x] Prolonged editing sessions remain stable.
- [x] Large selections remain stable.
- [x] Repeated parser refreshes do not destabilize the cursor or editor.
- [x] Field testing passed on the supported macOS versions used for M13 acceptance.

## Acceptance record

The project owner confirmed that the complete manual editor, persistence, accessibility, appearance, compatibility, and stress matrix above has been executed successfully. These items are no longer pending acceptance work.
