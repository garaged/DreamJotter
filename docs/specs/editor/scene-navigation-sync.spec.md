# Scene Navigation Sync Spec

Status: specified
Milestone: M7
Registry ID: EDITOR-SCENE-NAVIGATION-SYNC

## User Goal

A writer can move between the scene list and screenplay editor without losing their place.

## Scope

- Scene list selection requests editor navigation.
- Editor cursor position can update selected scene where practical.
- Selection survives parse refresh when scene identity can be matched.
- Deleted and duplicate scenes fall back safely.

## Non-Goals

- No full outline navigator.
- No multi-window synchronization.
- No production page number navigation.

## Behavior

Scene navigation uses semantic scene identity, parsed position, and text range when available. Clicking a scene requests a scroll or cursor move. Cursor changes update selected scene after parse/navigation state settles.

## Given/When/Then Examples

- Given a multi-scene screenplay, when the user clicks Scene 2 in the scene list, then the editor scrolls or moves to Scene 2.
- Given the cursor is inside Scene 3, when selection sync runs, then Scene 3 becomes selected.
- Given a scene is deleted, then selected scene falls back safely.
- Given duplicate scene headings exist, then scene identity uses stable parsed position or ID strategy.

## Data Model Implications

Uses `EditorNavigationState` with selected scene ID, selected script element ID, cursor text range, scroll target, last parse revision, and sync status.

## UI Implications

Scene list views should request navigation through a view model or editor coordination service instead of directly manipulating TextKit internals.

## Testability Notes

Tests should validate scene selection to text range resolution, cursor-to-scene mapping, deletion fallback, and duplicate heading disambiguation.

## Open Questions

- Should scene identity use generated IDs from parse positions or persistent IDs stored in the screenplay model?
- How should navigation behave when the fallback TextEditor cannot scroll precisely?
