# M12.2 Notes and TODO Workspace Specification

Status: implemented

## Canonical Data

Manual and imported notes are stored as `ProjectNote` records in the `.dreamjotter` package. Parsed-script TODO notes are rebuildable projections and are never silently copied into canonical storage.

## Required Workflows

1. Create, read, update, resolve/reopen, and delete stored notes.
2. Assign a valid target when creating a note.
3. Reassign the target when editing a note.
4. Support project, scene, character, and location targets in the macOS CRUD workflow.
5. Filter stored notes by state and linked target kind.
6. Search title and body with Unicode-aware normalization.
7. Present unresolved parsed-script TODOs separately from stored notes.
8. Apply the text search to both stored notes and parsed TODO projections.
9. Resolve or reopen a stored note without changing screenplay text or editor navigation.
10. Bulk resolve selected stored notes only after explicit confirmation and a successful snapshot.
11. Detect links whose project, scene, character, location, or screenplay-element target no longer exists.
12. Allow confirmed, snapshot-protected unlinking of orphan targets without deleting note content.
13. Resolve a valid navigation target for linked notes.
14. Navigate to Dashboard, Script, Characters, or Locations according to the selected note target.
15. Preserve accepted mutations across package save and reopen.

## Target Contract

- New stored notes default to the project target when the writer does not choose another valid target.
- The target picker is populated from canonical project, scene, character, and location data.
- Editing title, body, and target is one stored-note update operation.
- A selected target must still exist when the update is accepted.
- Orphaned links remain visible and can be unlinked safely.
- Parsed TODO navigation targets are derived from screenplay content and are not user-editable stored-note targets.

## Search and Filter Contract

The Notes workspace exposes:

- title/body search;
- All, Open, Resolved, and Archived state filters;
- Project, Scene, Character, Location, Screenplay Element, and Missing Target filters;
- visible result counts;
- a Clear action that resets text, state, and target filters;
- explicit empty and no-match states.

Search uses `TextNormalization.key` for matching only. Changing search or filter state does not mutate canonical note records.

## Command Rules

- Stored-note update, resolve, and reopen are command-backed metadata operations.
- Delete, bulk resolve, and orphan unlink require explicit confirmation.
- Delete, bulk resolve, and orphan unlink require a pre-mutation snapshot.
- Snapshot failure leaves the project unchanged.
- Parsed-script TODO projections are not directly deleted as stored notes.

## Projection Rules

- Search and filters are rebuilt from canonical note data.
- Dashboard open-note counts are rebuilt from canonical note status.
- Parsed TODO counts are rebuilt from screenplay content.
- Orphan status is derived and is not persisted separately.
- Selection state is pruned when a selected note is removed or no longer exists.

## Navigation Rules

- Project targets open Dashboard.
- Scene targets open Script at the matching scene.
- Screenplay-element targets open Script at the owning scene.
- Character targets open Characters.
- Location targets open Locations.
- Missing targets do not trigger invalid navigation.

## Unicode Rules

- Search uses `TextNormalization.key` for matching only.
- Original titles, bodies, and links remain byte-preserving Codable values.
- Accented and composed grapheme content must survive edit and save/reopen.
