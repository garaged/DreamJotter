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

Status: implemented.

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

The macOS workspace exposes persisted profile create, read, update, and confirmed delete flows. Archive, restore, merge, and rename-preview presentation may continue as later UI refinements without changing the accepted command contract.

## M12.2 Notes and TODO Workspace

Status: implemented.

Executable and adapter coverage includes:

- filtering stored notes by state and target kind;
- Unicode-aware search across title and body;
- unresolved parsed-script TODO projection kept separate from canonical stored notes;
- valid linked-target resolution and macOS navigation to project, script scene, screenplay element, character, or location workspace;
- stored-note create, read, update, resolve, reopen, and confirmed delete;
- explicit confirmation and snapshot protection for bulk resolve;
- no mutation when snapshot creation fails;
- orphan-link detection and snapshot-protected unlinking that preserves note content;
- search and dashboard projections rebuilt from canonical state;
- Unicode note mutation and `.dreamjotter` save/reopen persistence.

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
