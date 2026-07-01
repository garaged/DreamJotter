# Recent Projects Data Contract

Status: specified
Milestone: M6
Registry ID: APP-RECENT-PROJECTS

## Purpose

`RecentProjectEntry` describes app metadata used to present recently opened or saved `.dreamjotter` packages.

## Ownership

- Owned by the app shell or app-support layer.
- Stored as rebuildable app metadata, such as preferences or a local metadata file.
- Not canonical project storage.
- Not required to open or recover a `.dreamjotter` package.

## Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | string | yes | Stable entry ID. A normalized package URL string may be used if suitable. |
| `title` | string | yes | Last known project title for display. |
| `packageURLString` | string | yes | File URL or path string for the `.dreamjotter` package. |
| `lastOpenedAt` | ISO-8601 string | yes | Last successful open timestamp, or creation timestamp when first saved. |
| `lastSavedAt` | ISO-8601 string | no | Last successful save timestamp if known. |
| `projectFormatVersion` | string | no | Optional package/project format version detected during open/save. |
| `validityStatus` | enum string | no | `unknown`, `valid`, `missing`, `invalid`, or `permissionDenied`. |

## Invariants

- Duplicate package paths collapse to one latest entry.
- Successful open updates `lastOpenedAt` and moves the entry to the top.
- Successful Save As creates or refreshes the entry and may update `lastSavedAt`.
- Failed open must not corrupt or remove the current project.
- Missing entries may be marked invalid or removed by a deliberate app policy.

## Example

```json
{
  "id": "file:///Users/writer/Movies/Feature.dreamjotter",
  "title": "Feature",
  "packageURLString": "file:///Users/writer/Movies/Feature.dreamjotter",
  "lastOpenedAt": "2026-07-01T18:00:00Z",
  "lastSavedAt": "2026-07-01T18:05:00Z",
  "projectFormatVersion": "1",
  "validityStatus": "valid"
}
```
