# Editor Navigation State Data Contract

Status: specified
Milestone: M7
Registry ID: EDITOR-SCENE-NAVIGATION-SYNC

## Purpose

`EditorNavigationState` tracks app/editor coordination between semantic scenes, script elements, cursor position, and scroll requests. It is app/editor state, not canonical screenplay storage.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `selectedSceneID` | string | no | Selected semantic scene ID or generated parsed-position ID if known. |
| `selectedScriptElementID` | string | no | Selected script element ID if available. |
| `cursorTextRange` | object | no | Current cursor or selected text range in UTF-8/UTF-16 adapter-compatible coordinates. |
| `scrollTarget` | object | no | Requested scene, element, or text range to scroll into view. |
| `lastKnownParseRevision` | integer | no | Parse revision used to derive current navigation state. |
| `syncStatus` | enum string | yes | `idle`, `pendingEditorToScene`, `pendingSceneToEditor`, `resolved`, or `unresolved`. |

## Invariants

- Navigation state is rebuildable from current text and parse state.
- Missing scene/element IDs must fall back safely.
- Duplicate scene headings require parsed position or stable generated ID disambiguation.
- TextKit-specific selection objects are not canonical data.

## Example

```json
{
  "selectedSceneID": "scene-2",
  "selectedScriptElementID": "element-14",
  "cursorTextRange": { "location": 120, "length": 0 },
  "scrollTarget": { "kind": "scene", "id": "scene-2" },
  "lastKnownParseRevision": 5,
  "syncStatus": "pendingSceneToEditor"
}
```
