# Milestone 12 Acceptance — Writer Workflow Polish

Status: implemented pending local validation

## Shared Acceptance

Milestone 12 acceptance requires:

- command-backed project changes;
- snapshots for high-impact changes;
- unchanged project state when snapshot creation fails;
- Unicode-safe mutation and persistence;
- correct search and dashboard projections;
- stable editor navigation for metadata-only changes;
- save and reopen coverage for persisted fields.

## M12.1 Character and Location Management

Status: implemented.

Coverage includes profile archive and restore, confirmed removal, duplicate merge, rename previews, Unicode rename, detection cleanup, linked metadata updates, snapshot failure handling, package persistence, and macOS CRUD adapters.

## M12.2 Notes and TODO Workspace

Status: implemented.

Coverage includes stored-note CRUD, state and target filters, Unicode search, parsed TODO separation, linked-target navigation, bulk resolution, orphan handling, projection updates, and package persistence.

## M12.3 Scene Workflow Polish

Status: implemented pending local validation.

Coverage includes:

- editable scene summary, note, status, and plotline tags;
- Unicode-aware search across scene identity, participants, and metadata;
- status and plotline filtering;
- planning order independent from screenplay order;
- scene-card navigation to the corresponding script scene;
- deterministic screenplay-order preview;
- snapshot-protected screenplay-order application;
- unchanged state when snapshot creation fails;
- movement of complete scene blocks while preserving pre-scene content;
- scene metadata and planning-order save/reopen persistence.

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` using a clean scratch path.
- Verify Unicode metadata after save and reopen.
- Verify planning-order changes do not move screenplay text.
- Verify applying planning order moves complete scene blocks.
- Verify search and navigation across Characters, Locations, Scenes, Notes, Script, and Review.
