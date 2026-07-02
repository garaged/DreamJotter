# Milestone 12 Acceptance — Writer Workflow Polish

Status: specified

## Shared Acceptance

Milestone 12 is accepted only when:

- every destructive operation is represented by a `CommandRequest` and executed through `CommandEngine`;
- delete, merge, bulk resolve, bulk rename, and screenplay scene reorder require a snapshot;
- failed snapshot creation leaves project state unchanged;
- save and reopen preserve all accepted mutations;
- Unicode profile names, note text, scene summaries, and tags survive mutation and persistence;
- search results and dashboard counts reflect updated canonical project state;
- metadata-only actions do not change screenplay order, editor cursor, or selected scene;
- explicit screenplay reorder updates semantic screenplay order and reports affected elements.

## M12.1 Character and Location Management

Executable coverage must include:

- archive and restore of character and location profiles;
- explicit user confirmation before profile deletion;
- merge into a selected surviving profile;
- deterministic bulk-rename preview listing affected screenplay elements;
- snapshot-protected bulk rename that changes only matching semantic character cues or scene-heading locations;
- no partial mutation when snapshot creation fails;
- detected-profile resolution remaining matched to the surviving or renamed profile;
- duplicate collapse using Unicode-aware normalized keys;
- `.dreamjotter` save and reopen persistence for archived state, merges, and rename results.

## M12.2 Notes and TODO Workspace

Executable coverage must include:

- filtering by note status and target kind;
- Unicode-aware title and body search;
- unresolved parsed-script TODO projection separate from manual notes;
- navigation-target resolution for linked notes;
- resolve and reopen behavior;
- snapshot-protected bulk resolve;
- orphan detection, unlink, and repair candidates;
- search and dashboard count updates after mutations and reopen.

## M12.3 Scene Workflow Polish

Executable coverage must include:

- editing summary, note, status, and plotline tags;
- planning-order changes that leave screenplay order unchanged;
- status, plotline, and tag filters;
- scene-card-to-editor navigation-target resolution;
- explicit snapshot-protected screenplay scene reorder;
- save and reopen persistence;
- stable editor cursor and scene selection after metadata-only changes.

## Manual Acceptance

Before each slice is merged:

- open an existing `.dreamjotter` package containing Unicode names and linked notes;
- perform the slice's primary workflow;
- save, close, and reopen the package;
- confirm dashboard and search projections are correct;
- confirm the screenplay editor remains at the expected scene after metadata-only actions.
