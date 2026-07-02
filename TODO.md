# TODO

This file tracks future implementation work after the Milestone 0-4 spec baseline. It is not a substitute for specs, traceability, acceptance criteria, or executable specs.

## Milestone 1 Implementation

Status: foundation complete.

- Maintain executable guardrails that keep core modules free of SwiftUI, AppKit, UIKit, SwiftData, and CloudKit.
- Expand parser fixtures only when new Milestone 1-compatible edge cases are discovered.
- Expand portable core data models as later milestones require persistent records beyond the first project/screenplay/editor/export foundation subset.
- Keep `.dreamjotter` package file I/O deferred to Milestone 2 storage implementation.
- Keep real PDF rendering deferred until export renderer acceptance specs are executable.

## Milestone 2 Implementation

Status: foundation complete.

- Maintain `.dreamjotter` package create/save/load validation against storage specs.
- Maintain storage diagnostics for missing manifests, missing required files, invalid JSON, invalid schema, and unsupported versions.
- Keep dashboard summaries derived from project/package metadata rather than canonical app cache.
- Keep scene cards, characters, notes, inbox items, search, snapshots, templates, health report, export presets, and mode policy covered by executable specs.
- Expand Milestone 2 data contracts only when later milestones require richer fields or command-backed mutation.
- Keep Simple Mode as the default and keep Pro Mode hidden or disabled.

## Milestone 3 Implementation

Status: foundation complete.

- Maintain guided story setup, logline, synopsis, and beat sheet executable specs.
- Maintain FakeAIProvider-only suggestion flows with AI-disabled behavior and no external calls.
- Maintain accepted-only mutation and snapshot-before-AI-rewrite behavior.
- Keep continuity analysis warnings read-only, advisory, friendly, and Unicode-aware.
- Keep table-read plan generation portable and free of text-to-speech dependencies.
- Keep story-development state persisted through `.dreamjotter` `story.json` package storage.
- Defer real AI providers, network calls, UI adapters, and full CommandEngine mutation routing.

## Milestone 4 Implementation

Status: foundation complete.

- Maintain revision color, draft version, semantic comparison, production breakdown, advanced export preset, and custom field executable specs.
- Maintain CommandEngine as the safe mutation boundary for routines and future automation.
- Maintain Routine System v1 as no-code command orchestration with logs and failure handling.
- Maintain snapshot-before-destructive-routine-action behavior.
- Keep Pro Mode authoring controls hidden in Simple Mode while preserving Pro metadata.
- Keep Pro metadata persisted through `.dreamjotter` `pro.json` package storage.
- Keep plugin runtime, marketplace, arbitrary scripting, and third-party code loading deferred.

## Milestone 6 Document Lifecycle

Status: implemented.

- Maintain executable specs for Save As cancel behavior, failed save preserving dirty state, recent-project duplicate collapse, storage-error to `AppError` mapping, and Save / Discard / Cancel protection.
- Decide whether reopen-last-project is automatic, prompted, or deferred to native document behavior.
- Keep recent-project storage as app metadata only.

## Milestone 7 Screenplay Editor Usability

Status: implemented.

- Maintain executable specs for Smart Enter behavior across scene heading, action, character, dialogue, parenthetical, transition, and malformed text contexts.
- Maintain adapter-neutral element-kind cycling that preserves Unicode text and remains consistent after save/reopen.
- Keep non-destructive character, location, scene heading, and time-of-day suggestions flowing through `EditorSuggestion`.
- Keep controlled/debounced parse state in `EditorParseState` without making typing unstable.
- Keep scene navigation sync in `EditorNavigationState` and keep duplicate/deleted scenes safe.
- Maintain TextKit keyboard handling for Smart Enter and Tab cycling.
- Maintain suggestions UI so suggestions do not mutate text until accepted.
- Maintain scene list clicks and editor cursor changes as visible TextKit selection/scroll behavior.
- Maintain basic TextKit line styling as adapter-only presentation while keeping SwiftUI TextEditor fallback functional.
- Maintain passive empty editor guidance that disappears or stops obstructing once typing starts.
- Preserve Milestone 6 dirty state, save/reopen, recent projects, and Fountain export in every editor path.

## Milestone 8 Character, Location, Notes, and Scene Workflow

Status: implemented with deferred polish.

- Maintain executable specs for character profile create/edit/save/reopen, detected character convert/ignore, generic-role suppression, duplicate collapse, malformed text safety, Unicode preservation, dirty state, and ignored-key package persistence.
- Maintain executable specs for location profile create/edit/save/reopen, detected location extraction from scene headings, time-of-day exclusion, convert/ignore, duplicate collapse, Unicode preservation, and ignored-key package persistence.
- Maintain scene card workflow that separates derived screenplay facts from user-authored status, summaries, tags, and links.
- Maintain notes workflow for project, scene, character, and location notes with open/resolved state and parsed script TODO notes that do not become canonical manual notes.
- Maintain dashboard workspace summary counts for scenes, profiles, unresolved detections, open notes, TODOs, dirty state, and saved information.
- Maintain search coverage for character profiles, location profiles, notes, and scene card metadata using rebuildable indexes.
- Preserve Milestone 6 document lifecycle and Milestone 7 editor behavior across all M8 metadata changes.
- Defer character/location archive and delete UI, richer profile fields, bulk merge/rename, and full note filtering/search polish.

## Apple UI

- Maintain the SwiftPM-generated `DreamJotterMac` macOS app scheme.
- Keep Project Library, temporary editor, editable title/logline/synopsis, notes, dashboard, scene/character lists, package save/open, Fountain export, and health report wired to portable core.
- Keep the Script pane editor switch available while TextKit matures.
- Add document-based app behavior for native package open/save lifecycle.
- Add autosave after document ownership and snapshot policy are specified.
- Polish recent projects with availability badges, missing-package repair, and clearer invalid-entry handling.
- Add reopen-last-project-on-launch once startup ownership rules are specified.
- Replace the current discard-only dirty replacement prompt with Save / Discard / Cancel.
- Add iPad app after macOS foundations are stable.
- Add iPhone app after the iPad workflow is specified.
- Keep Apple UI adapters thin over portable core behavior.
- Do not make SwiftData canonical storage.
- Preserve Simple Mode as the first-run experience.
- Defer visual polish until the document lifecycle and editor workflows are stable.

## TextKit Editor

- Maintain the initial TextKit/AppKit `NSTextView` adapter as UI-only editing infrastructure.
- Keep SwiftUI `TextEditor` available as fallback until TextKit selection, undo, and formatting behavior are mature.
- Design TextKit/AppKit adapter for macOS editor surface.
- Design TextKit/UIKit adapter for iPadOS/iOS editor surface.
- Bridge selection and cursor state to platform-neutral editor state.
- Keep TextKit as an adapter, not the canonical model.
- Verify Unicode and grapheme-safe cursor behavior.
- Add accessibility exposure for current element kind and diagnostics.

## iCloud/Sync

- Deferred beyond Milestone 4.
- Add ADR before any sync implementation.
- Preserve local-first `.dreamjotter` ownership.
- Define conflict resolution before implementation.
- Ensure projects remain openable without cloud services.

## Real PDF Adapter

- Deferred until export core and semantic screenplay layout contracts are stable.
- Add a real PDF adapter for macOS export after layout and pagination specs are executable.
- Define page layout and pagination rules before renderer implementation.
- Add platform adapter boundary for Apple PDF generation.
- Keep PDF artifacts as exports, not canonical storage.
- Add executable specs for unsupported renderer diagnostics.

## Real AI Provider

- Deferred beyond Milestone 4.
- Add ADR and privacy spec before implementation.
- Define user consent, data retention, prompt context limits, offline behavior, and disable controls.
- Keep FakeAIProvider as the only provider for current executable specs.
- Preserve accepted-only mutation and snapshot-before-rewrite rules.

## FDX Support

- Deferred beyond Milestone 4.
- Add import/export adapter spec before implementation.
- Map FDX to the semantic screenplay model.
- Do not make FDX canonical storage.
- Add compatibility tests with malformed and partial FDX inputs.

## Plugin Runtime

- Deferred beyond Milestone 4.
- Add ADRs for runtime architecture, permissions, sandboxing, signing, trust, compatibility, and distribution.
- Require future plugins to request approved commands only.
- Disallow arbitrary scripting until a separate security model is accepted.
- Keep canonical project data readable without plugins.

## Windows/Linux/Android Future Work

- Deferred beyond Apple-first implementation.
- Keep portable core platform-neutral to preserve this path.
- Validate `.dreamjotter` packages with non-Apple file assumptions.
- Avoid Apple-only types in canonical data contracts.
- Define platform-specific UI adapters only after Apple foundations and portable core stabilize.
