# Basic Screenplay Line Styling Spec

Status: specified
Milestone: M7
Registry IDs: EDITOR-BASIC-LINE-STYLING, EDITOR-EMPTY-STATE-GUIDANCE, EDITOR-DOCUMENT-WORKFLOW-PRESERVATION

## User Goal

A writer can visually recognize screenplay structure while retaining plain text editing, reliable save/reopen, and clean Fountain export.

## Scope

- Basic TextKit visual distinction for scene headings, character names, transitions, and notes.
- Adapter-only styling.
- Functional unstyled SwiftUI TextEditor fallback.
- Passive empty-state guidance for blank scripts.
- Preservation of document lifecycle and export behavior.

## Non-Goals

- No canonical rich-text storage.
- No production pagination.
- No revision colors.
- No print layout.

## Behavior

TextKit may apply temporary attributes based on semantic parse results. Styling refresh must not alter canonical text. Fallback TextEditor may remain unstyled. Blank scripts may show guidance or placeholders that disappear or stop obstructing once typing begins.

## Given/When/Then Examples

- Given parsed scene headings, when TextKit styling refreshes, then scene headings are visually distinguished.
- Given character lines, when styling refreshes, then character lines are visually distinguished.
- Given text is saved, then styling metadata is not required to recover the screenplay.
- Given the fallback editor is used, then the app remains functional without styling.
- Given a new blank project, when opening the Script pane, then the user sees helpful guidance or placeholder text.
- Given the user starts typing, then guidance no longer obstructs writing.
- Given editor styling exists, then exported Fountain does not include styling artifacts.

## Data Model Implications

Styling is derived from semantic parse state and may use `EditorParseState`. It is not serialized into `.dreamjotter` as canonical data.

## UI Implications

TextKit styling should use temporary attributes or regenerated attributed text that preserves selection as much as reasonable. Empty guidance should be passive and non-blocking.

## Testability Notes

Tests should focus on canonical text preservation and editor-state decisions, not fragile pixel or UI automation checks.

## Open Questions

- Which exact font weights/colors should be used before visual polish?
- Should notes be styled as dimmed text or a badge-like line treatment?
