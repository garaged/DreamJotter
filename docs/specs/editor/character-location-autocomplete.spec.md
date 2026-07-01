# Character And Location Autocomplete Spec

Status: specified
Milestone: M7
Registry IDs: EDITOR-SCENE-HEADING-SUGGESTIONS, EDITOR-CHARACTER-AUTOCOMPLETE, EDITOR-LOCATION-AUTOCOMPLETE

## User Goal

A writer receives useful, non-destructive suggestions for characters, locations, scene heading prefixes, and times of day while typing screenplay text.

## Scope

- Scene heading prefix classification for `INT.`, `EXT.`, and `INT./EXT.`.
- Known location suggestions while typing scene headings.
- Common time-of-day suggestions: DAY, NIGHT, MORNING, EVENING, CONTINUOUS, LATER.
- Existing character suggestions while typing character lines.
- Case-insensitive matching with canonical spelling preservation.
- Accepted suggestions replace only the intended text range.
- Ignored suggestions do not mutate text.

## Non-Goals

- No AI-generated completions.
- No network lookup.
- No plugin suggestions.
- No requirement for explicit location models in Milestone 7.

## Behavior

Scene heading suggestions come from screenplay syntax, parsed locations, recent usage, and common times of day. Character suggestions come from project character records and parsed character cues. Suggestions are ranked deterministically and are only applied when accepted.

## Given/When/Then Examples

- Given the user types `INT.`, when the parser refreshes, then the current line is classified as a scene heading.
- Given known location `APARTMENT`, when the user starts a scene heading, then `APARTMENT` is suggested.
- Given project character `ELENA`, when the user types `ELE`, then `ELENA` is suggested.
- Given the user accepts `ELENA`, then the current line becomes `ELENA`.
- Given prior scene heading `INT. COFFEE SHOP - DAY`, when the user types `INT. COF`, then `COFFEE SHOP` is suggested.
- Given no matching character or location exists, then no suggestion is shown and no error occurs.
- Given Spanish or Unicode names and locations, suggestions preserve text.

## Data Model Implications

Suggestions use `EditorSuggestion`. Character suggestions may derive from project characters and parsed screenplay cues. Location suggestions may derive from parsed scene headings or future explicit location models.

## UI Implications

TextKit may present suggestions with native completion UI or a custom lightweight overlay. SwiftUI fallback may present fewer or no inline suggestions while preserving the workflow.

## Testability Notes

Tests should verify matching, canonical replacement text, ignored-suggestion non-mutation, Unicode preservation, and empty-result safety.

## Open Questions

- Should suggestions include recently used locations before alphabetic sorting?
- Should time-of-day suggestions be configurable in Pro Mode later?
