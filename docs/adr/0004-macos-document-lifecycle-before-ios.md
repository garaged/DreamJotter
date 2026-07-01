# ADR 0004: Stabilize macOS Document Lifecycle Before iOS Expansion

Status: accepted
Date: 2026-07-01

## Context

DreamJotter now has a portable core, a launchable macOS SwiftUI app shell, and a TextKit editor adapter foundation. The app can already create, edit, save, open, and export projects, but writer trust depends on predictable document ownership before more editor polish, AI, plugins, or iOS expansion.

## Decision

Milestone 6 prioritizes macOS document lifecycle and writer workflow stabilization before iPadOS/iOS targets and deeper TextKit polish.

The app will specify and implement reliable behavior for new projects, open, save, Save As, dirty state, recent projects, safe replacement, close protection, menu commands, and friendly errors. The `.dreamjotter` package remains canonical storage. Recent-project metadata remains app metadata and must not become required to recover project data.

## Rationale

Mac document lifecycle comes before iOS/iPadOS because the Mac app is the first serious writing surface and the first place users will trust DreamJotter with real project files.

Writer trust/save/reopen behavior is more important than additional editor features right now because advanced editing is risky if users cannot reliably preserve and recover work.

TextKit polish is deferred until document lifecycle stabilizes because TextKit is an adapter. The semantic screenplay model and `.dreamjotter` storage must remain the source of truth.

Recent-project metadata is not canonical storage because it is convenience UI state. A `.dreamjotter` package must remain readable without app recents, SwiftData, cache files, or search indexes.

## Consequences

- Milestone 6 may add app-support state machines and view-model tests before major visual polish.
- Save/open/export flows must be centralized instead of duplicated in SwiftUI views.
- iPadOS/iOS work waits until Mac project ownership behavior is clear.
- Future document-based app behavior, autosave, and reopen-last-project can build on these decisions.
- Users get safer workflows sooner, but advanced editor pagination, revision-color UI, and production polish remain deferred.
