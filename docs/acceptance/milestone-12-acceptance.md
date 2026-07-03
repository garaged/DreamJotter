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
- application localization that never rewrites screenplay content;
- parser behavior independent from the current UI locale;
- complete Spanish usability for every required macOS workflow.

## M12.1 Character and Location Management

Status: implemented.

Coverage includes profile lifecycle, confirmed removal, duplicate merge, rename previews, Unicode handling, detection cleanup, linked metadata updates, snapshot failure handling, package persistence, CRUD adapters, and profile/detection search.

## M12.2 Notes and TODO Workspace

Status: implemented.

Coverage includes stored-note CRUD, target assignment, filters, Unicode search, localized TODO projection, linked navigation, bulk resolution, orphan handling, projection updates, and package persistence.

## M12.3 Scene Workflow Polish

Status: implemented pending local validation.

Coverage includes scene metadata, Unicode search, filters, independent planning order, script navigation, deterministic reorder preview, snapshot-protected screenplay reorder, complete scene-block movement, and save/reopen persistence.

## M12.4 Localization and Spanish Screenplay Support

Status: implemented pending local validation.

Coverage includes English, `es-MX`, and `es-419` resources; independent application and screenplay languages; Unicode English and Spanish screenplay parsing; Spanish scene headings, transitions, shots, title-page labels, TODOs, parentheticals, and cue extensions; localized diagnostics; project-language persistence; fixtures; and localized TODO projections.

## M12.5 Complete Spanish UI Localization

Status: specified.

Implementation acceptance requires:

- an inventory of every user-visible string in `Apps/DreamJotterMac` and every displayed core message;
- `es-MX` and `es-419` translations for every required key;
- localization of application menus, library, dashboard, script editor, profiles, scenes, notes, review, health, export, backup, restore, settings, alerts, panels, tooltips, and accessibility text;
- stable semantic localization keys or an explicitly documented compatibility mapping for existing literal keys;
- no raw enum value, internal identifier, localization key, or unintended English fallback in normal Spanish operation;
- locale-aware pluralization for counts, selections, findings, matches, and affected elements;
- localized dynamic errors and diagnostics generated from stable codes;
- localized accessibility labels and hints for every icon-only or ambiguous control;
- readable layouts at the minimum supported window size and accessibility text sizes;
- an automated localization audit with zero missing or incomplete Spanish entries;
- Spanish UI smoke tests covering every workspace and confirmation path;
- full manual project journey in `es-MX` and `es-419` without required English text;
- native-speaker terminology and tone approval.

The normative translation inventory, glossary, dynamic-message rules, UI surface matrix, audit requirements, and manual journey are defined in:

`docs/specs/writer-workflow/m12-full-ui-localization.spec.md`

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` using a clean scratch path.
- Verify M12.3 scene workflow behavior.
- Verify M12.4 parsing, persistence, and export round trips.
- Implement and run `scripts/localization-check` with zero missing `es-MX` or `es-419` entries.
- Complete the full UI smoke journey in English, `es-MX`, and `es-419`.
- Complete accessibility, layout, and native-speaker review before accepting Milestone 12.
