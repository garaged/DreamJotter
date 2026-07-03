# Milestone 12 — Writer Workflow Polish

Status: implemented pending local validation

## Goal

Complete the deferred writer workflows while preserving local-first storage, command-backed mutations, snapshot protection, Unicode safety, navigation stability, multilingual screenplay fidelity, and complete Spanish-language usability.

## Slice Status

### M12.1 Character and Location Management

Status: implemented.

Profile lifecycle, CRUD, detection conversion, search, filtering, merge, rename preview, snapshots, Unicode handling, and persistence are implemented.

### M12.2 Notes and TODO Workspace

Status: implemented.

Stored-note CRUD, targets, filters, Unicode search, localized TODO projection, navigation, bulk resolution, orphan handling, and persistence are implemented.

### M12.3 Scene Workflow Polish

Status: implemented pending local validation.

Scene metadata, search, filters, planning order, navigation, explicit screenplay reorder, snapshot protection, scene-block preservation, and persistence are implemented. Repeated identical scene headings remain a known limitation until stable scene identifiers are introduced.

### M12.4 Localization and Spanish Screenplay Support

Status: implemented pending local validation.

English and Spanish screenplay profiles, Unicode-safe bilingual parsing, Spanish screenplay constructs, diagnostics, project-language persistence, localized TODO projection, fixtures, and executable coverage are implemented.

### M12.5 Complete Spanish UI Localization

Status: implemented pending local validation.

Specification: `docs/specs/writer-workflow/m12-full-ui-localization.spec.md`

Implemented coverage:

- 293 translated keys for both `es-MX` and `es-419`;
- localized menus, Settings, panels, alerts, library, dashboard, editor, profiles, scenes, notes, review, health, export, backup, and restore;
- localized statuses, filters, target labels, findings, runtime errors, export feedback, and filename suggestions;
- localized accessibility labels for icon-only controls;
- Unicode-safe source audit for missing keys, locale parity, duplicates, and resource syntax;
- automated tests for table parity, critical workflow keys, regional naming, and preference persistence.

## Shared Guardrails

- `.dreamjotter` remains canonical storage.
- Localization never translates screenplay or user-entered project content.
- Application language and screenplay language remain independent.
- Semantic kinds, diagnostic codes, file formats, and identifiers remain stable.
- Metadata-only operations preserve screenplay order and editor navigation.
- Search normalization remains matching-only and non-destructive.

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run `python3 scripts/localization-check`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` with a clean scratch path.
- Complete full `es-MX` and `es-419` UI journeys.
- Verify minimum-window and accessibility-text layouts.
- Complete VoiceOver, export/restore, and native-speaker terminology review.

## Delivery Branches

- `feature/m12-profile-management`
- `feature/m12-notes-workspace`
- `feature/m12-scene-workflow`
- `feature/m12-localization-spanish`
- `feature/m12-full-ui-localization`
