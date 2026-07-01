# Spec Review Notes

Status: specified
Review scope: specs through Milestone 4
Review date: 2026-06-30

## Purpose

This document records the consistency review as DreamJotter moves from specs into portable-core implementation. It captures contradictions found, corrections made, remaining open questions, implementation risks, and the recommended implementation order.

## Consistency Issues Found

### README Status Was Stale

Issue: `README.md` said no Swift package existed, but the repo now contains `Package.swift`, `Sources/SpecSupport`, and `Tests/DreamJotterExecutableSpecs` for executable documentation specs.

Impact: New contributors could mistake the executable spec package for production app implementation or assume the repository had not yet reached executable spec scaffolding.

Resolution: Updated `README.md` to state that the Swift package is an executable-spec skeleton and that no production app code, Xcode project, production UI, plugin runtime, real AI provider, cloud sync, or external service integration exists yet.

### README Repo Layout Was Stale

Issue: `README.md` described several existing folders as future folders, including `docs/data-contracts`, `docs/editor`, `docs/storage`, `docs/export`, `docs/routines`, `docs/ai`, and `docs/plugins`.

Impact: The documented layout no longer matched the actual repository structure.

Resolution: Updated the repo layout to include current docs folders, `Package.swift`, `Sources/SpecSupport`, `Tests/DreamJotterExecutableSpecs`, and `specs/fixtures`.

### Executable Spec Command Was Missing From README

Issue: `README.md` documented `spec-check`, `spec-trace`, and `spec-new`, but did not document the Swift executable spec command added by Prompt 13.

Impact: Contributors could skip the executable documentation checks.

Resolution: Added the SwiftPM test command used in this sandboxed environment.

## Consistency Areas Reviewed

### Apple-Native First vs Cross-Platform Later

Result: Consistent.

Decision: Apple-native UI remains first for macOS, iPadOS, and iOS. Portable core remains required so future Linux, Windows, and Android readers or apps can reuse domain behavior and `.dreamjotter` data.

### SwiftData Cache/Index Only vs Canonical Storage

Result: Consistent.

Decision: `.dreamjotter` remains canonical project storage. SwiftData may only be future recents, cache, app metadata, UI state, or rebuildable index storage.

### Plugins Deferred vs Routines In Milestone 4

Result: Consistent.

Decision: Routines are no-code command orchestration in Milestone 4. Plugin runtime, marketplace, arbitrary scripting, third-party code loading, and direct file mutation are deferred beyond Milestone 4.

### AI Abstraction vs Real AI Provider

Result: Consistent.

Decision: AI through Milestone 4 is provider-neutral abstraction and FakeAIProvider test behavior only. Real providers, network calls, API keys, and provider telemetry are out of scope.

### PDF Abstraction vs Real PDF Implementation

Result: Consistent.

Decision: PDF export is specified as an export intent and renderer boundary. Real PDF rendering, exact pagination, print dialogs, and platform renderers are future implementation work.

### Simple Mode vs Pro Mode

Result: Consistent.

Decision: Simple Mode is default and hides or disables advanced concepts. Pro Mode may expose revisions, production metadata, custom fields, routines, and advanced exports without changing the canonical project format.

### Semantic Screenplay Model vs Plain Rich Text

Result: Consistent.

Decision: Screenplay data is semantic. Text buffers, TextKit, formatting spans, rich text, and editor projections are adapters or views, not canonical storage.

### Local-First Package vs Cloud Sync

Result: Consistent.

Decision: `.dreamjotter` is local-first canonical storage. Cloud sync is deferred and must not become required to open or recover a project.

### Milestone 4 Scope vs Future Marketplace

Result: Consistent.

Decision: Milestone 4 documents future plugin extension points only. Plugin marketplace is explicitly out of scope.

### App UI Deferred vs Editor Behavior Specified

Result: Consistent.

Decision: Editor behavior is specified as platform-neutral state and reducer/controller behavior. TextKit/AppKit/UIKit wrappers and production UI are deferred.

## Corrections Made

- Updated `README.md` current status to acknowledge the executable spec Swift package while preserving the no-production-app-code boundary.
- Updated `README.md` repo layout to match current folders and executable spec structure.
- Added the executable spec command to `README.md`.
- Added this review note as the authoritative consistency pass record.

## Remaining Open Questions

- Milestone 1 parser expected-output fixtures now cover empty, simple, multi-scene, Spanish/Unicode, malformed, and advanced Fountain subset inputs; future fixtures are still needed for non-M1 formats such as FDX.
- Exact partial-reparse strategy for the editor is deferred until parser performance is measurable.
- Exact undo model for each command remains command-specific and needs executable specs before implementation.
- Snapshot storage retention and cleanup policy remains open.
- Production PDF layout, pagination, and screenplay formatting details are still abstraction-level only.
- Whether project-specific routine logs are canonical package data or bounded derived metadata needs a later decision.
- Cloud sync, if ever added, needs ADRs for conflict resolution and local-first guarantees.
- Real AI provider support, if ever added, needs privacy, consent, model, and data-retention specs.

## Implementation Risks

- Implementing UI before parser/storage contracts would risk making TextKit or rich text the de facto model.
- Implementing SwiftData too early could accidentally turn cache/index data into canonical state.
- Implementing routines before CommandEngine could bypass the intended mutation boundary.
- Implementing AI acceptance before snapshots could create unsafe rewrite behavior.
- Implementing PDF export before semantic pagination/export contracts could overfit to Apple renderer details.
- Implementing Pro Mode surfaces too early could complicate the beginner writing loop.
- Introducing plugin concepts before routines and commands are stable would increase security and compatibility risk.

## Recommended Implementation Order After Specs

1. Keep the accepted Milestone 1 and Milestone 2 portable-core foundations green as later work expands the model.
2. Implement CommandEngine skeleton with validation, CommandResult, CommandHistoryEntry, and snapshot policy.
3. Extend editor behavior into command-backed reducer/controller behavior without UI frameworks.
4. Implement Milestone 3 story setup, logline, synopsis, beat sheet, FakeAIProvider, continuity, character consistency, and table-read plan generation as portable modules.
5. Implement export core for Markdown, plain text, JSON backup, and later renderer handoff while preserving the accepted PDF intent boundary.
6. Add Apple app shell and TextKit adapters only after portable core contracts remain green.
7. Add Milestone 4 Pro Mode features, routines through CommandEngine, and advanced export/custom field surfaces.
8. Revisit deferred plugin and real AI provider work only after Milestone 4 foundations are implemented and accepted.

## Validation Expectations

After this review pass, run:

```bash
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```
