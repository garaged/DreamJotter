# Smart Enter Spec

Status: specified
Milestone: M7
Registry ID: EDITOR-SMART-ENTER

## User Goal

A writer can press Enter and continue in the likely next screenplay element without manually choosing formatting every time.

## Scope

- Predict next element kind from the current line context.
- Support scene heading, action, character, dialogue, parenthetical, and transition flows.
- Keep behavior deterministic and testable outside TextKit where practical.
- Preserve malformed text and editor usability.

## Non-Goals

- No AI-generated writing.
- No production pagination.
- No rich-text canonical model.
- No plugin-provided behavior.

## Behavior

- Scene heading followed by Enter suggests or creates action.
- Action followed by Enter continues action unless a deterministic local rule says otherwise.
- Character followed by Enter suggests or creates dialogue.
- Dialogue followed by Enter can continue dialogue, suggest character, or return to action according to the chosen rule.
- Parenthetical followed by Enter returns to dialogue.
- Transition followed by Enter suggests a scene heading.
- Malformed text falls back safely to action or plain continuation.

## Given/When/Then Examples

- Given the cursor is at the end of a scene heading, when Enter is pressed, then the next element kind is action.
- Given the cursor is at the end of a character name, when Enter is pressed, then the next element kind is dialogue.
- Given the cursor is at the end of dialogue, when Enter is pressed twice or according to the chosen rule, then the editor can return to action.
- Given malformed text, when Enter is pressed, then the editor should not crash.

## Data Model Implications

Smart Enter may use `EditorNavigationState`, `EditorParseState`, and semantic screenplay elements. It must not store canonical editor behavior in TextKit-specific state.

## UI Implications

TextKit and fallback editor may trigger the same behavior through a shared editor behavior service or view model. UI adapters should only pass cursor/text context and apply the returned text operation.

## Testability Notes

Tests should call a platform-neutral smart-enter policy with current text, cursor range, and parse state.

## Open Questions

- Should dialogue Enter require one blank line or two Enter presses to return to action?
- Should Smart Enter insert explicit Fountain markers or rely on line context?
