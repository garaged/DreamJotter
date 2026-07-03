# Milestone 12 Acceptance — Writer Workflow Polish

Status: in progress

## Shared Acceptance

Milestone 12 acceptance requires:

- command-backed project changes;
- snapshots for high-impact changes;
- unchanged project state when snapshot creation fails;
- Unicode-safe mutation and persistence;
- correct search and dashboard projections;
- stable editor navigation for metadata-only changes;
- save and reopen coverage for persisted fields;
- application localization that does not rewrite screenplay content;
- parser behavior that is independent from the current application UI locale.

## M12.1 Character and Location Management

Status: implemented.

Coverage includes profile archive and restore, confirmed removal, duplicate merge, rename previews, Unicode rename, detection cleanup, linked metadata updates, snapshot failure handling, package persistence, macOS CRUD adapters, and Unicode-aware profile/detection search.

## M12.2 Notes and TODO Workspace

Status: implemented.

Coverage includes stored-note CRUD, target assignment and reassignment, state and target filters, Unicode search, parsed TODO separation, linked-target navigation, bulk resolution, orphan handling, projection updates, and package persistence.

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

## M12.4 Localization and Spanish Screenplay Support

Status: specified.

Implementation acceptance requires:

- English, `es-MX`, and `es-419` application localization resources;
- system-language following plus an optional app-language override;
- independent application-language and project screenplay-language settings;
- backward-compatible project decoding with `automatic` screenplay language as the default;
- language-neutral semantic screenplay kinds;
- Unicode-safe recognition of cues such as `SOFÍA`, `ÍÑIGO`, and `DOÑA ÁNGELES`;
- recognition of English and Spanish scene headings, transitions, shots, parentheticals, title-page aliases, TODO tokens, and cue extensions;
- preservation of original screenplay wording, accents, punctuation, capitalization, and spacing;
- deterministic automatic and mixed-language parsing;
- Unicode-aware title-page labels and custom-field preservation;
- stable diagnostic codes with English and Spanish presentation messages;
- localized editor suggestions, empty states, dialogs, menus, filters, result counts, accessibility labels, and help text;
- locale-aware pluralization and sentence construction without translated-fragment concatenation;
- unchanged English parser results for all existing fixtures;
- paired English, Spanish, mixed-language, normalization, title-page, transition, and malformed-input fixtures;
- UTF-8 and accent preservation through `.dreamjotter`, Fountain, FDX, PDF, JSON backup, Markdown, and plain-text workflows;
- search and navigation resolving the same semantic targets under English and Spanish UI locales;
- Spanish UI smoke coverage with no visible localization keys or unintended English fallback;
- native-speaker review of Spanish terminology before release.

Required screenplay examples include:

```text
Título: El corazón de Sofía

INT. CASA DE SOFÍA - NOCHE

SOFÍA
No sé qué decir.

(susurrando)
Tal vez mañana.

CORTE A:

EXT. PARQUE - DÍA

[[PENDIENTE: revisar diálogo de ÍÑIGO]]
```

The example must parse into language-neutral title-page, scene-heading, character-cue, dialogue, parenthetical, transition, scene-heading, and note-reference elements while preserving the original Spanish text.

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` using a clean scratch path.
- Verify Unicode metadata after save and reopen.
- Verify planning-order changes do not move screenplay text.
- Verify applying planning order moves complete scene blocks.
- Verify search and navigation across Characters, Locations, Scenes, Notes, Script, and Review.
- Implement M12.4 and run English and Spanish parser, localization, persistence, export, accessibility, and UI smoke suites before accepting Milestone 12.
