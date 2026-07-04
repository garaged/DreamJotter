# M13 Editor Hardening Traceability

| Requirement | Implementation | Regression coverage |
| --- | --- | --- |
| Shared paragraph boundaries | `ScreenplayParagraphTypeEngine` | `M13ParagraphTypeEngineRegressionSpecs` |
| Editor selection and styling consistency | `ScreenplayParagraphTypeControl`, `ScreenplayParagraphTypeStyling` | editor selection/style range test |
| Post-dialogue action protection | parser-safe paragraph preparation | parser and PDF body-width tests |
| Formatting guide | `ScreenplayFormattingGuide`, `ScreenplayParagraphInspectorView` | formatting guide model and UI tests |
| Combined character cues | `CharacterCueEngine`, `CharacterCueParsingNormalizer` | combined cue parsing and PDF tests |
| Segment-aware cue suggestions | `CharacterCueEngine.suggestionContext` | active segment and ranking tests |
| Keyboard suggestion acceptance | `ScriptEditorView` | keyboard wiring tests |
