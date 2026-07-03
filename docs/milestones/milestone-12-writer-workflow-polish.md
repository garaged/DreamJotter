# Milestone 12 — Writer Workflow Polish

Status: implemented pending local validation

## Goal

Complete the highest-value writer workflows intentionally deferred from Milestone 8 while preserving the local-first package model, command-backed mutations, snapshot protection, Unicode safety, search correctness, dashboard correctness, and editor navigation stability.

Milestone 12 is delivered in three independently reviewable slices and a shared cross-workspace search/navigation polish pass.

## Platform Baseline

- The macOS app minimum deployment target is macOS 14 Sonoma.
- Milestone 12 SwiftUI adapters may use APIs available from macOS 14 onward.
- Portable-core behavior remains independent from SwiftUI and AppKit.

## M12.1 Character and Location Management

Status: implemented.

- Archive and restore character and location profiles.
- Remove profiles only after explicit confirmation.
- Merge duplicate profiles into a selected surviving profile.
- Rename a character or location across the semantic screenplay.
- Preview affected screenplay elements before applying a bulk rename.
- Route lifecycle and bulk mutations through `CommandEngine`.
- Require a snapshot before removal, merge, or bulk screenplay rename.
- Preserve Unicode names and detected-profile resolution behavior.
- Preserve changes across `.dreamjotter` save and reopen.
- Provide macOS create, read, update, and confirmed delete adapters for stored profiles.
- Search profile names, profile notes, and unresolved detected entities.
- Filter the workspace by All, Profiles, and Detected scope.

## M12.2 Notes and TODO Workspace

Status: implemented.

- Filter notes by state and target.
- Search note title and body text using Unicode-aware normalization.
- Show unresolved parsed-script TODOs separately from manual notes.
- Apply text search to stored notes and parsed TODO projections.
- Assign project, scene, character, or location targets during note creation.
- Reassign note targets during editing.
- Navigate from a linked note to its screenplay scene, screenplay element, project, character, or location workspace.
- Create, read, update, resolve, reopen, and delete stored notes.
- Bulk resolve selected notes through `CommandEngine` with snapshot protection.
- Identify orphaned note links and expose safe confirmed unlink behavior.
- Keep search indexes and dashboard counts correct after mutations.
- Preserve Unicode note content, targets, and accepted mutations across `.dreamjotter` save and reopen.

## M12.3 Scene Workflow Polish

Status: implemented pending local validation.

- Enrich scene cards with editable summary, note, status, plotline tags, and planning order.
- Reorder planning metadata without changing screenplay element order.
- Filter scene cards by text, status, and plotline tag.
- Jump from a scene card to the corresponding editor scene.
- Provide a separate explicit command for screenplay scene reordering.
- Require confirmation and a snapshot before screenplay scene reorder.
- Preserve pre-scene content and element order within every reordered scene block.
- Rebuild script text from the reordered semantic screenplay.
- Keep editor cursor and scene navigation stable after metadata-only changes.
- Preserve scene metadata, planning order, screenplay order, Unicode values, and snapshots across save and reopen.
- Treat scene headings as the current scene identity; identical repeated headings remain a known limitation until stable scene IDs are introduced.

## Shared Search and Navigation Polish

Milestone 12 also standardizes search and navigation across the writer workspace:

- Character search covers names, notes, and unresolved detections.
- Location search covers names, notes, and unresolved detections.
- Scene search covers headings, locations, time, characters, summaries, notes, and tags.
- Notes search covers stored-note title/body and parsed TODO text.
- Script search provides case-insensitive and diacritic-insensitive match navigation with previous, next, wraparound, count, and clear behavior.
- Review search covers finding title, message, suggested action, source, and linked identifier.
- Review filters cover severity and source.
- Filtered surfaces show result counts, clear actions, and explicit no-match states.
- Review findings and linked notes provide direct navigation to the relevant workspace or script location.

## Shared Guardrails

- `.dreamjotter` remains canonical storage.
- All destructive operations are command-backed.
- Bulk destructive operations require snapshot creation before mutation.
- A failed snapshot blocks the mutation and leaves project state unchanged.
- Preview operations are read-only and deterministic.
- Unicode and grapheme content must not be narrowed or lossy-normalized.
- Search normalization is used only for matching and filtering.
- Detected character and location resolution must remain consistent after archive, restore, merge, rename, save, and reopen.
- Search indexes and dashboard summaries are rebuildable projections, not canonical data.
- Planning order and screenplay order remain separate until the writer invokes the explicit screenplay-reorder command.
- Metadata-only operations must not move the editor cursor or alter scene-navigation selection.

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` with a clean scratch path on macOS 14 or later.
- Verify Unicode search and persistence.
- Verify all search filters, counts, clear actions, and empty states.
- Verify linked-note, scene-card, script-search, and Review navigation.
- Verify planning-order changes do not alter screenplay text.
- Verify screenplay-order application moves complete scene blocks and records a snapshot.

## Delivery Branches

- `feature/m12-profile-management`
- `feature/m12-notes-workspace`
- `feature/m12-scene-workflow`
