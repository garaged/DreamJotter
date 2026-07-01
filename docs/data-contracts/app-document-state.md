# App Document State Data Contract

Status: specified
Milestone: M6
Registry IDs: APP-DOCUMENT-LIFECYCLE, APP-DIRTY-STATE, APP-UNSAVED-CHANGES-PROTECTION

## Purpose

`AppDocumentState` describes macOS app-shell workflow state around the currently open project. It is app metadata and view-model state, not canonical project storage.

## Ownership

- Owned by the macOS app shell or app-support module.
- Derived from, and writes back through, the canonical `.dreamjotter` package.
- Must not replace portable core project models.
- Must not require SwiftData to recover project data.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `currentProjectID` | string | no | Stable project ID from the portable project when available. |
| `currentProjectTitle` | string | yes | Title displayed in the window and Project Library. |
| `packageURLString` | string | no | File URL or path string for the current `.dreamjotter` package. Missing means unsaved. |
| `isDirty` | boolean | yes | True when app state has user edits not successfully saved to the package. |
| `lastSavedAt` | ISO-8601 string | no | Timestamp of the most recent successful save. |
| `screenplayText` | string | yes | Current editable screenplay text feeding the semantic parser. |
| `selectedSidebarSection` | enum string | no | `dashboard`, `script`, `scenes`, `characters`, `notes`, or `healthReport`. |
| `selectedSceneID` | string | no | Selected semantic scene ID, if applicable. |
| `pendingConfirmation` | object | no | Confirmation-required state for dirty replacement, close, or open workflows. |

## Pending Confirmation Shape

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `kind` | enum string | yes | `newProject`, `openProject`, `returnToLibrary`, `closeProject`, or `closeWindow`. |
| `targetURLString` | string | no | Package URL/path involved in the pending operation, if any. |
| `message` | string | yes | Human-readable prompt text. |
| `createdAt` | ISO-8601 string | yes | Timestamp when the confirmation became active. |

## Invariants

- `isDirty == true` means closing or replacing requires confirmation or a save-first workflow.
- Successful Save or Save As sets `isDirty` to false and updates `lastSavedAt`.
- Failed Save or Save As preserves `isDirty`.
- Export does not change `isDirty`.
- `screenplayText` feeds parsing but the semantic screenplay model remains canonical project data.

## Serialization

This state may be serialized for app restoration later, but Milestone 6 does not require canonical persistence of this record. If serialized, it must tolerate missing fields and stale package URLs.

## Example

```json
{
  "currentProjectID": "project-123",
  "currentProjectTitle": "Untitled Screenplay",
  "packageURLString": null,
  "isDirty": true,
  "lastSavedAt": null,
  "screenplayText": "INT. ROOM - DAY\n\nA writer starts typing.",
  "selectedSidebarSection": "script",
  "selectedSceneID": null,
  "pendingConfirmation": null
}
```
