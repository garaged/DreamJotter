# M12.3 Scene Workflow Polish Specification

Status: implemented pending local validation

## Canonical Boundaries

- Semantic screenplay order is canonical in `ScreenplayDocument.elements` and `ScreenplayDocument.scenes`.
- Scene-card summary, note, status, plotline tags, and planning order are canonical `SceneCard` metadata.
- Planning order is independent from screenplay order.
- The current implementation resolves scene cards by scene heading. Repeated identical headings are therefore not independently addressable until the domain model gains stable scene identifiers.

## Required Workflows

1. Edit summary, note, status, and Unicode plotline tags for each scene card.
2. Search scene title, location, time, characters, summary, note, and tags with Unicode-aware normalization.
3. Filter by status and plotline tag.
4. Show visible result counts, a Clear action, and explicit no-match states.
5. Reorder planning cards without changing screenplay elements, scenes, cursor range, or selected scene.
6. Jump from any scene card to the corresponding screenplay scene.
7. Preview which scenes change position before screenplay reorder.
8. Require explicit confirmation and a successful snapshot before screenplay reorder.
9. Reorder complete screenplay scene blocks while preserving pre-scene content and element order within each scene.
10. Rebuild script text from the reordered semantic screenplay after screenplay-order application.
11. Preserve metadata, planning order, screenplay reorder, Unicode values, and snapshots across package save and reopen.

## Metadata Contract

Each scene card supports:

- summary;
- note;
- `SceneCardStatus`;
- comma-separated plotline-tag entry in the macOS adapter;
- normalized duplicate removal for plotline tags;
- independent planning-order position.

Metadata changes must not change semantic screenplay order or text.

## Search and Filter Contract

- Text matching includes heading, location, time of day, characters, summary, note, and plotline tags.
- Status filtering uses the canonical `SceneCardStatus` value.
- Plotline filtering uses Unicode-aware normalized equality.
- Search and filtering are projection-only and never mutate scene-card data.

## Planning Order Contract

- Moving a card earlier or later changes only `SceneCard.order` values.
- Planning-order requests contain every scene heading exactly once.
- Invalid or incomplete permutations are rejected.
- Planning-order changes do not create a snapshot because screenplay content is unchanged.
- The macOS workspace shows cards in planning order.

## Screenplay Reorder Contract

- Applying planning order to the screenplay is a separate explicit operation.
- The writer sees a confirmation dialog before application.
- A snapshot is created before screenplay content changes.
- Snapshot failure leaves the project unchanged.
- Title-page and other pre-scene elements remain before the first scene.
- Every scene heading moves with all screenplay elements that belong to that scene.
- Element order inside each scene remains unchanged.
- Scene-card planning metadata remains associated with its scene heading.

## Command Rules

- Metadata update, planning reorder, and screenplay reorder are command-backed.
- Metadata update and planning reorder are non-destructive metadata operations.
- Screenplay reorder requires confirmation and a pre-mutation snapshot.
- Invalid or incomplete order permutations are rejected.

## Navigation Rules

- Metadata-only operations must preserve current editor cursor range and selected scene.
- Scene-card navigation resolves the card's screenplay scene by heading.
- After explicit screenplay reorder, navigation resolves against the new screenplay order.
- Opening a scene card switches to Script and requests navigation to the matching scene.

## Unicode Rules

- Search and tag comparisons use `TextNormalization.key` only for matching.
- Original summary, note, and tag graphemes remain unchanged in canonical storage.

## Validation Boundary

The implementation remains pending local validation until the executable specs, complete Swift test suite, macOS app build, save/reopen checks, and editor-navigation checks pass on the supported macOS 14 baseline.
