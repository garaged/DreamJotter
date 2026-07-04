# M13 Paragraph, Cue, and Autocomplete Acceptance

Status: deterministic coverage added; build/test validation pending; manual validation deferred to milestone owner.

## Implemented

- Shared paragraph type engine for editor selection, styling, parser safeguards, and PDF semantics.
- Regression protection for action prose following completed dialogue.
- Contextual and complete in-editor formatting guide.
- Combined Unicode character cues with canonical separator handling.
- Individual character registration from combined cues.
- Segment-aware, accent-insensitive cue suggestions with deterministic ranking.
- Return and Tab suggestion acceptance before Smart Enter and type cycling.
- Up/Down selection, Escape dismissal, mouse acceptance, and selected accessibility state.

## Deterministic coverage

- `M13ParagraphTypeEngineRegressionSpecs`
- `CharacterCueEngineExecutableSpecs`
- `ScreenplayFormattingGuideTests`
- `EditorSuggestionKeyboardTests`
- Existing `ScreenplayParagraphSemanticsExecutableSpecs`
- Existing `TextKitEditorMaturityTests`

## Validation commands

```bash
swift test
swift build --product DreamJotterMac
```

## Manual validation remaining

- Native Undo/Redo behavior for suggestion acceptance.
- Up/Down/Return/Tab/Escape behavior with the TextKit editor focused.
- VoiceOver announcements for active suggestions and combined cues.
- Increased Contrast and larger text rendering of the guide and suggestion panel.
- Save/reopen undo expectations.
- Input-method composition and large screenplay stress checks.
