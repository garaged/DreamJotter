# Element Kind Cycling Spec

Status: specified
Milestone: M7
Registry ID: EDITOR-ELEMENT-KIND-CYCLING

## User Goal

A writer can use Tab to quickly cycle the current line into the intended screenplay element kind without corrupting text.

## Scope

- Cycle current line through action, character, dialogue, parenthetical, transition, shot, and note.
- Scene headings may be inferred from heading syntax.
- Preserve original text, including Unicode.
- Update semantic parse after cycling.

## Non-Goals

- No custom keyboard shortcut editor.
- No production revision styling.
- No canonical rich text.

## Behavior

Tab changes the current line's intended element kind using a deterministic cycle. The implementation may use Fountain-compatible markers or another reversible plain-text representation as long as semantic parse, save, reopen, and export remain consistent.

## Given/When/Then Examples

- Given a line selected as action, when Tab is pressed, then the element kind changes to the next supported kind.
- Given a cycled line, when saved and reopened, then screenplay text and semantic element remain consistent.
- Given text with Spanish or Unicode characters, cycling preserves characters.

## Data Model Implications

Cycling may produce an `EditorSuggestion` of type `elementKind` or a direct editor text operation. Canonical storage remains screenplay text plus semantic model, not TextKit attributes.

## Testability Notes

Tests should verify cycle order, Unicode preservation, semantic parse update, and save/reopen consistency.

## Open Questions

- Should scene headings be included in the Tab cycle or only triggered by scene-heading syntax?
- Should cycling use Fountain forced markers for ambiguous element kinds?
