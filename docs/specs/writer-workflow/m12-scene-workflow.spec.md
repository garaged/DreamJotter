# M12.3 Scene Workflow Polish Specification

Status: implemented

## Canonical Boundaries

- Semantic screenplay order is canonical in `ScreenplayDocument.elements` and `ScreenplayDocument.scenes`.
- Scene-card summary, note, status, plotline tags, and planning order are canonical `SceneCard` metadata.
- Planning order is independent from screenplay order.

## Required Workflows

1. Edit summary, note, status, and Unicode plotline tags for each scene card.
2. Search scene title, location, time, characters, summary, note, and tags with Unicode-aware normalization.
3. Filter by status and plotline tag.
4. Reorder planning cards without changing screenplay elements, scenes, cursor range, or selected scene.
5. Jump from any scene card to the corresponding screenplay scene.
6. Preview which scenes change position before screenplay reorder.
7. Require explicit confirmation and a successful snapshot before screenplay reorder.
8. Reorder complete screenplay scene blocks while preserving pre-scene content and element order within each scene.
9. Preserve metadata, planning order, screenplay reorder, Unicode values, and snapshots across package save and reopen.

## Command Rules

- Metadata update, planning reorder, and screenplay reorder are command-backed.
- Metadata update and planning reorder are non-destructive metadata operations.
- Screenplay reorder is destructive, requires confirmation, and requires a pre-mutation snapshot.
- Snapshot failure leaves the project unchanged.
- Invalid or incomplete order permutations are rejected.

## Navigation Rules

- Metadata-only operations must preserve current editor cursor range and selected scene.
- Scene-card navigation resolves the card's screenplay scene by heading.
- After explicit screenplay reorder, navigation resolves against the new screenplay order.

## Unicode Rules

- Search and tag comparisons use `TextNormalization.key` only for matching.
- Original summary, note, and tag graphemes remain unchanged in canonical storage.
