# Milestone 12 — Writer Workflow Polish

Status: implemented pending local validation

## Goal

Complete the highest-value writer workflows intentionally deferred from Milestone 8 while preserving the local-first package model, command-backed mutations, snapshot protection, Unicode safety, search correctness, dashboard correctness, editor navigation stability, and multilingual screenplay fidelity.

Milestone 12 is delivered in four slices plus a shared cross-workspace search/navigation polish pass.

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
- Apply text search to stored notes and localized parsed TODO projections.
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

## M12.4 Localization and Spanish Screenplay Support

Status: implemented pending local validation.

Specification: `docs/specs/writer-workflow/m12-localization-spanish.spec.md`

- Localize the macOS application in English, Spanish for Mexico, and Latin American Spanish fallback.
- Follow the system language and provide a persisted application-language override.
- Keep application language independent from screenplay language.
- Add project screenplay-language profiles for Automatic, English, and Latin American Spanish.
- Preserve the existing language-neutral semantic screenplay model.
- Recognize Spanish and English screenplay constructs without translating source text.
- Support Unicode character cues such as `SOFÍA`, `ÍÑIGO`, and `DOÑA ÁNGELES`.
- Support shared scene prefixes such as `INT.`, `EXT.`, `INT./EXT.`, and Spanish `I/E.` aliasing.
- Support Spanish time-of-day values, transitions, shots, title-page fields, TODO tokens, parentheticals, and cue extensions.
- Replace ASCII-only title-page-field recognition with Unicode-aware aliases and custom-field preservation.
- Keep Fountain control markers language-neutral and interoperable.
- Localize diagnostics through stable codes and runtime message resolution.
- Preserve accents and original wording through semantic recognition and package persistence.
- Add English, Spanish, mixed-language, and invalid-input fixture files.
- Apply the selected screenplay language during editor parsing, suggestions, smart-enter, tab cycling, and manual refresh.
- Require export round-trip, accessibility, native-speaker, and Spanish UI smoke validation before release.

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
- Search and navigation semantics remain identical under English and Spanish application locales.

## Shared Guardrails

- `.dreamjotter` remains canonical storage.
- All destructive operations are command-backed.
- Bulk destructive operations require snapshot creation before mutation.
- A failed snapshot blocks the mutation and leaves project state unchanged.
- Preview operations are read-only and deterministic.
- Unicode and grapheme content must not be narrowed or lossy-normalized.
- Search normalization is used only for matching and filtering.
- Application localization must never translate or rewrite screenplay content.
- Screenplay-language parsing must not depend on the current application UI locale.
- Stable semantic kinds, diagnostic codes, file formats, and internal identifiers are not localized.
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
- Verify application-language override behavior.
- Verify project-language parsing during editing and save/reopen.
- Run export round-trip, accessibility, Spanish UI smoke, and native-speaker terminology review before Milestone 12 is accepted.

## Delivery Branches

- `feature/m12-profile-management`
- `feature/m12-notes-workspace`
- `feature/m12-scene-workflow`
- `feature/m12-localization-spanish`
