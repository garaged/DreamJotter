# TODO

This file tracks future implementation and maintenance work. It is not a substitute for specs, traceability, acceptance criteria, or executable specs.

## Accepted Foundations

Milestones 1 through 4 are accepted portable-core foundations. Milestones 5 through 9.6 are implemented app, editor, workspace, export, review, and restore foundations. Milestone 10 production PDF export is accepted. Milestone 11 FDX interoperability foundation is implemented.

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

## Character, Location, Notes, Scenes, and Search

Status: implemented with deferred polish.

- Maintain create/edit/save/reopen, detection resolution, Unicode duplicate collapse, dirty-state, and package persistence coverage.
- Preserve the distinction between derived screenplay facts and user-authored metadata.
- Defer archive/delete UI, richer profile fields, bulk merge/rename, and advanced filtering until separately specified.

## Export, Review, Backup, and Restore

Status: implemented.

- Maintain Fountain, Markdown, plain text, JSON backup, and production PDF exports without dirty-state mutation.
- Maintain Reader Copy, Contest Submission, Print Script, Writer Backup, and Plain Text Archive preset validation.
- Maintain read-only Review Mode, script health, formatting warnings, and review findings.
- Maintain backup validation and Save / Discard / Cancel restore protection.
- Defer export history, batch export, and richer overwrite/restore presentation until separately specified.

## Milestone 10 Production PDF Export

Status: accepted.

- Maintain deterministic `PDFLayoutPlanner` output and hierarchical document, screenplay-page, block, paragraph, line, and source-element numbering.
- Maintain title-page behavior, screenplay page numbers, margins, wrapped blocks, dialogue and parenthetical columns, character cues, and right-aligned transitions.
- Preserve Reader Copy, Print Script, and Contest Submission privacy and metadata rules.
- Exclude notes, TODOs, and internal metadata from reader-facing PDFs by default.
- Maintain Windows-1252 encoding, unsupported-character fallback, deterministic diagnostics, and warning propagation through `ExportResult`.
- Maintain stable structural snapshots, empty-project PDF coverage, and very-long-screenplay pagination coverage.
- Retain `BasicPDFExportAdapter` only as a deprecated compatibility facade over `ProductionPDFRenderer`; new code must use `ProductionPDFRenderer` directly.
- Keep PDF artifacts as exports rather than canonical storage.
- Prefer structural layout snapshots over binary PDF fixtures unless byte-level compatibility becomes an explicit product requirement.

## Milestone 11 FDX Interoperability

Status: implemented foundation.

- Maintain deterministic mapping for scene headings, action, character cues, parentheticals, dialogue, transitions, and shots.
- Maintain Unicode-safe UTF-8 XML and escaping for XML-sensitive characters.
- Keep unknown FDX paragraph types visible as `.unknown` elements with warnings.
- Keep DreamJotter-only notes, explicit page breaks, and unsupported elements out of exported FDX with deterministic diagnostics.
- Keep network and external-resource lookup disabled while parsing.
- Keep FDX as interchange only; `.dreamjotter` remains canonical storage.
- Add title-page, revision metadata, dual-dialogue, styled-text, and cross-version compatibility fixtures only in later separately specified slices.
- Add application-level import and export presentation only after replacement, merge, and save semantics are specified.

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
