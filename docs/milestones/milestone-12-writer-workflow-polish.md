# Milestone 12 — Writer Workflow Polish

Status: specified

## Goal

Complete the highest-value writer workflows intentionally deferred from Milestone 8 while preserving the local-first package model, command-backed destructive mutations, snapshot protection, Unicode safety, search correctness, dashboard correctness, and editor navigation stability.

Milestone 12 is delivered in three independently reviewable slices.

## M12.1 Character and Location Management

- Archive and restore character and location profiles.
- Delete profiles only after explicit confirmation.
- Merge duplicate profiles into a selected surviving profile.
- Rename a character or location across the semantic screenplay.
- Preview affected screenplay elements before applying a bulk rename.
- Route archive, restore, delete, merge, and bulk rename through `CommandEngine`.
- Require a snapshot before delete, merge, or bulk screenplay rename.
- Preserve Unicode names and detected-profile resolution state.
- Preserve changes across `.dreamjotter` save and reopen.

## M12.2 Notes and TODO Workspace

- Filter notes by state and target.
- Search note title and body text using Unicode-aware normalization.
- Show unresolved parsed-script TODOs separately from manual notes.
- Navigate from a linked note to its screenplay element or owning object.
- Resolve and reopen TODOs.
- Bulk resolve selected notes through `CommandEngine` with snapshot protection.
- Identify orphaned note links and expose safe repair or unlink behavior.
- Keep search indexes and dashboard counts correct after mutations.

## M12.3 Scene Workflow Polish

- Enrich scene cards with editable summary, note, status, plotline tags, and planning order.
- Reorder planning metadata without changing screenplay element order.
- Filter scene cards by status, plotline, and tag.
- Jump from a scene card to the corresponding editor scene.
- Provide a separate explicit command for screenplay scene reordering.
- Require a snapshot before screenplay scene reorder.
- Keep editor cursor and scene navigation stable after metadata-only changes.

## Shared Guardrails

- `.dreamjotter` remains canonical storage.
- All destructive operations are command-backed.
- Bulk destructive operations require snapshot creation before mutation.
- A failed snapshot blocks the mutation and leaves project state unchanged.
- Preview operations are read-only and deterministic.
- Unicode and grapheme content must not be narrowed or lossy-normalized.
- Detected character and location resolution must remain consistent after archive, restore, merge, rename, save, and reopen.
- Search indexes and dashboard summaries are rebuildable projections, not canonical data.
- Planning order and screenplay order remain separate until the writer invokes the explicit screenplay-reorder command.
- Metadata-only operations must not move the editor cursor or alter scene-navigation selection.

## Delivery Branches

- `feature/m12-profile-management`
- `feature/m12-notes-workspace`
- `feature/m12-scene-workflow`
