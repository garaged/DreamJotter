# Milestone 12 — Writer Workflow Polish

Status: in progress

## Goal

Complete the highest-value writer workflows intentionally deferred from Milestone 8 while preserving the local-first package model, command-backed mutations, snapshot protection, Unicode safety, search correctness, dashboard correctness, editor navigation stability, multilingual screenplay fidelity, and complete Spanish-language usability.

Milestone 12 is delivered in five slices plus a shared cross-workspace search and navigation pass.

## Platform Baseline

- The macOS app minimum deployment target is macOS 14 Sonoma.
- Milestone 12 SwiftUI adapters may use APIs available from macOS 14 onward.
- Portable-core behavior remains independent from SwiftUI and AppKit.

## M12.1 Character and Location Management

Status: implemented.

Profile lifecycle, CRUD, detection conversion, search, filtering, merge, rename preview, command routing, snapshots, Unicode handling, and package persistence are implemented.

## M12.2 Notes and TODO Workspace

Status: implemented.

Stored-note CRUD, target assignment, filters, Unicode search, localized TODO projection, linked navigation, bulk resolution, orphan handling, dashboard updates, and package persistence are implemented.

## M12.3 Scene Workflow Polish

Status: implemented pending local validation.

Scene metadata, search, filters, planning order, script navigation, explicit screenplay reorder, snapshot protection, scene-block preservation, and persistence are implemented.

Repeated identical scene headings remain a known limitation until stable scene identifiers are introduced.

## M12.4 Localization and Spanish Screenplay Support

Status: implemented pending local validation.

Specification: `docs/specs/writer-workflow/m12-localization-spanish.spec.md`

M12.4 provides:

- English, `es-MX`, and `es-419` localization resources;
- application-language and screenplay-language separation;
- Automatic, English, and Latin American Spanish screenplay profiles;
- Unicode-safe English and Spanish screenplay parsing;
- Spanish scene headings, transitions, shots, title-page labels, TODO tokens, parentheticals, and cue extensions;
- localized parser diagnostics;
- project-language persistence;
- localized TODO projection;
- parser fixtures and executable coverage.

## M12.5 Complete Spanish UI Localization

Status: specified.

Specification: `docs/specs/writer-workflow/m12-full-ui-localization.spec.md`

M12.5 completes the entire macOS interface for Spanish-speaking users:

- audit every user-facing string in `Apps/DreamJotterMac` and displayed core messages;
- localize menus, project library, dashboard, editor, profiles, scenes, notes, review, health, export, backup, restore, settings, alerts, panels, tooltips, and accessibility text;
- provide comprehensive `es-MX` and `es-419` translations;
- migrate toward stable semantic localization keys;
- add locale-aware pluralization, lists, dates, numbers, and dynamic messages;
- prohibit untranslated enum values, implementation identifiers, and accidental English fallback;
- validate Spanish layouts at minimum window width and accessibility text sizes;
- add a localization audit command and full Spanish UI smoke journey;
- require native-speaker terminology approval before acceptance.

## Shared Search and Navigation Polish

- Character and location search covers profiles, notes, and detections.
- Scene search covers headings, location, time, characters, summary, notes, and tags.
- Notes search covers stored notes and parsed TODOs.
- Script search supports diacritic-insensitive previous and next match navigation.
- Review search and filtering covers title, message, action, source, severity, and linked identifiers.
- Filtered views expose counts, clear actions, and explicit empty states.
- Search and navigation semantics remain identical under English and Spanish locales.

## Shared Guardrails

- `.dreamjotter` remains canonical storage.
- Destructive and bulk operations retain command and snapshot protection.
- Unicode and grapheme content is never narrowed or destructively normalized.
- Application localization never translates screenplay or project content.
- Screenplay parsing does not depend on application UI locale.
- Semantic kinds, diagnostic codes, file formats, and internal identifiers are not localized.
- Metadata-only operations preserve screenplay order and editor navigation.
- Localization keys and translated strings are presentation data, never canonical project data.

## Validation Before Merge

- Run `python3 scripts/spec-check`.
- Run `python3 scripts/spec-trace`.
- Run the complete Swift test suite.
- Build `DreamJotterMac` with a clean scratch path.
- Validate M12.3 scene workflow manually.
- Validate M12.4 parsing, persistence, fixtures, and export round trips.
- Implement M12.5 and run the localization audit with zero missing Spanish keys.
- Complete the full manual project workflow in `es-MX` and `es-419`.
- Complete accessibility, layout, and native-speaker terminology review.

## Delivery Branches

- `feature/m12-profile-management`
- `feature/m12-notes-workspace`
- `feature/m12-scene-workflow`
- `feature/m12-localization-spanish`
- `feature/m12-full-ui-localization`
