# Milestone 12 Acceptance — Writer Workflow Polish

Status: in progress

## Shared Acceptance

Milestone 12 is accepted only when:

- every destructive operation is represented by a command request and executed through `CommandEngine`;
- removal, merge, bulk resolve, bulk rename, and screenplay scene reorder require a snapshot;
- failed snapshot creation leaves project state unchanged;
- save and reopen preserve all accepted mutations;
- Unicode profile names, note text, scene summaries, and tags survive mutation and persistence;
- search results and dashboard counts reflect updated canonical project state;
- metadata-only actions do not change screenplay order, editor cursor, or selected scene;
- explicit screenplay reorder updates semantic screenplay order and reports affected elements.

## M12.1 Character and Location Management

Status: implemented in portable core.

Executable coverage includes:

- archive and restore of character and location profiles;
- explicit user confirmation before profile removal;
- merge into a selected surviving profile;
- deterministic bulk-rename preview listing affected screenplay elements;
- snapshot-protected bulk rename that changes only matching semantic character cues or scene-heading locations;
- no partial mutation when snapshot creation fails;
- ignored-detection state cleanup so renamed or merged profiles can match derived detections;
- duplicate collapse using Unicode-aware normalized keys;
- linked-note and scene-card metadata remapping;
- `.dreamjotter` save and reopen persistence for archive markers, snapshots, merges, and rename results.

Focused macOS presentation for archive lists, confirmation, preview, and merge selection remains deferred to an adapter slice.

## M12.2 Notes and TODO Workspace

Status: planned.

Executable coverage must include filtering, Unicode-aware search, unresolved parsed-script TODO projection, navigation-target resolution, resolve and reopen, snapshot-protected bulk resolve, orphan handling, and search/dashboard updates.

## M12.3 Scene Workflow Polish

Status: planned.

Executable coverage must include editable scene-card metadata, planning-order separation, filters, navigation targets, explicit snapshot-protected screenplay reorder, persistence, and editor navigation stability.

## Manual Acceptance

Before each UI-bearing slice is merged:

- open an existing `.dreamjotter` package containing Unicode names and linked notes;
- perform the slice's primary workflow;
- save, close, and reopen the package;
- confirm dashboard and search projections are correct;
- confirm the screenplay editor remains at the expected scene after metadata-only actions.
