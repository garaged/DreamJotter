# TODO

This file tracks future implementation and maintenance work. It is not a substitute for specs, traceability, acceptance criteria, or executable specs.

## Accepted Foundations

Milestones 1 through 4 are accepted portable-core foundations. Milestones 5 through 9.6 are implemented app, editor, workspace, export, review, and restore foundations. Milestone 10 production PDF export is accepted. Milestone 11 FDX interoperability foundation is implemented. Milestone 12 writer workflow polish is in progress.

Maintain the following cross-cutting guardrails:

- Keep `.dreamjotter` as canonical local-first storage.
- Keep SwiftData derived-only if introduced.
- Keep commands as the safe mutation boundary.
- Keep Apple UI adapters thin over portable core behavior.
- Keep real AI providers, cloud sync, plugin runtime, arbitrary scripting, and third-party code loading deferred until separately specified and accepted.
- Preserve Unicode, dirty-state safety, save/reopen behavior, and non-destructive export behavior across later milestones.

## Document Lifecycle

Status: implemented.

- Maintain Save, Save As, cancel, failure, recent-project, and Save / Discard / Cancel regression coverage.
- Decide whether reopen-last-project is automatic, prompted, or deferred to native document behavior.
- Keep recent-project storage as app metadata only.
- Add autosave only after document ownership and snapshot policy are specified.

## Screenplay Editor

Status: implemented with ongoing hardening.

- Maintain Smart Enter, Tab cycling, suggestions, scene navigation, cursor sync, TextKit keyboard handling, and passive empty-state guidance.
- Keep TextKit and future UIKit implementations as adapters over semantic screenplay state.
- Preserve the SwiftUI `TextEditor` fallback until selection, undo, formatting, and accessibility behavior are mature.
- Add grapheme-safe cursor tests and accessibility exposure for current element kind and diagnostics.

## M12.1 Character and Location Management

Status: portable core implemented.

- Maintain command-backed archive and restore.
- Maintain explicit confirmation for profile removal and duplicate merge.
- Maintain snapshot protection for removal, merge, and bulk rename.
- Maintain deterministic rename previews and stale-preview rejection.
- Preserve Unicode names, semantic screenplay references, linked notes, scene-card metadata, ignored-detection keys, and package persistence.
- Add focused macOS management presentation for preview, confirmation, archive lists, and duplicate merge selection in a later adapter slice.

## M12.2 Notes and TODO Workspace

Status: planned.

- Add note state and target filters, Unicode-aware search, unresolved TODO projection, direct navigation, resolve/reopen, bulk resolve, and orphan repair.
- Keep bulk operations command-backed and snapshot-protected.
- Keep search and dashboard counts correct after mutation and reopen.

## M12.3 Scene Workflow Polish

Status: planned.

- Add richer editable scene cards and status, plotline, and tag filters.
- Keep planning order separate from screenplay order.
- Add scene-card navigation and an explicit snapshot-protected screenplay reorder command.
- Preserve cursor and scene-navigation state for metadata-only changes.

## Milestone 10 Production PDF Export

Status: accepted.

- Maintain deterministic `PDFLayoutPlanner` output and hierarchical numbering.
- Preserve title-page behavior, screenplay page numbers, margins, wrapped blocks, dialogue columns, character cues, transitions, privacy rules, diagnostics, and regression coverage.
- Retain `BasicPDFExportAdapter` only as a deprecated compatibility facade.

## Milestone 11 FDX Interoperability

Status: implemented foundation.

- Maintain supported semantic mapping, Unicode-safe XML, unknown paragraph warnings, malformed-input protection, and canonical `.dreamjotter` ownership.
- Add title pages, revision metadata, dual dialogue, styled text, UI integration, and wider compatibility fixtures only in separately specified slices.

## Apple UI

- Maintain the SwiftPM-generated `DreamJotterMac` app scheme.
- Add document-based native package behavior only after ownership rules are settled.
- Polish recent projects with availability indicators and missing-package repair.
- Add iPadOS after the macOS workflow is stable and separately specified.
- Add iPhone only after the iPad workflow is specified.
- Preserve Simple Mode as the first-run experience.

## Future Integrations

### iCloud and Sync

- Add an ADR before implementation.
- Define conflict resolution, offline behavior, and local ownership guarantees.
- Ensure projects remain openable without cloud services.

### Real AI Provider

- Add privacy, consent, retention, prompt-context, offline, and disable-control specs before implementation.
- Keep `FakeAIProvider` as the only current executable-spec provider.
- Preserve accepted-only mutation and snapshot-before-rewrite behavior.

### Plugin Runtime

- Add architecture, permissions, sandboxing, signing, trust, compatibility, and distribution ADRs first.
- Require approved commands rather than direct project mutation.
- Keep projects readable without plugins.

### Windows, Linux, and Android

- Preserve portable-core assumptions and non-Apple package compatibility.
- Avoid Apple-only types in canonical data contracts.
- Define platform adapters only after Apple-first foundations stabilize.
