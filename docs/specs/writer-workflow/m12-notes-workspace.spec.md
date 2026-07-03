# M12.2 Notes and TODO Workspace Specification

Status: implemented

## Canonical Data

Manual and imported notes are stored as `ProjectNote` records in the `.dreamjotter` package. Parsed-script TODO notes are rebuildable projections and are never silently copied into canonical storage.

## Required Workflows

1. Create, read, update, resolve/reopen, and delete stored notes.
2. Filter stored notes by state and linked target kind.
3. Search title and body with Unicode-aware normalization.
4. Present unresolved parsed-script TODOs separately from stored notes.
5. Resolve or reopen a stored note without changing screenplay text or editor navigation.
6. Bulk resolve selected stored notes only after explicit confirmation and a successful snapshot.
7. Detect links whose project, scene, character, location, or screenplay-element target no longer exists.
8. Allow confirmed, snapshot-protected unlinking of orphan targets without deleting note content.
9. Resolve a valid navigation target for linked notes.
10. Preserve accepted mutations across package save and reopen.

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

## Unicode Rules

- Search uses `TextNormalization.key` for matching only.
- Original titles, bodies, and links remain byte-preserving Codable values.
- Accented and composed grapheme content must survive edit and save/reopen.
