# DreamJotter Constitution

This constitution defines non-negotiable rules for DreamJotter specs and implementation. It sits above individual milestone specs, ADRs, and feature specs. It encodes commands before routines before plugins as the required automation sequence.

## Non-Negotiable Rules

1. Apple-native UI first. The first product experience prioritizes macOS, then iPadOS and iOS, using native Apple interaction patterns where implementation later requires UI.
2. Portable core always. Screenplay model, parser, storage contracts, commands, routines, export intent, and AI boundaries must remain portable beyond Apple platforms.
3. Semantic screenplay model, not rich text only. A screenplay is made of meaningful elements such as scenes, action, character cues, dialogue, parentheticals, transitions, notes, and metadata. Styling is derived from meaning.
4. `.dreamjotter` package is canonical project storage. Local-first project packages are the source of truth for screenplay and project data.
5. SwiftData is not canonical storage. SwiftData may only be future cache, search index, recents, app metadata, or other derived convenience data.
6. Core modules must not depend on SwiftUI, AppKit, UIKit, SwiftData, or CloudKit. Platform adapters may use Apple frameworks, but core specs and modules must not require them.
7. Commands are the only safe mutation boundary. User-visible document changes should pass through explicit command concepts once implementation begins.
8. Routines execute commands, not direct state mutation. A routine is a repeatable sequence of approved commands and must not bypass command semantics.
9. Plugins are future work and must not drive Milestone 1-4 design. No arbitrary plugin runtime is allowed through Milestone 4.
10. AI suggestions never mutate user text until accepted. AI-assisted behavior, when later specified, must present suggestions or command proposals that require user acceptance before changing canonical text.
11. Destructive or major automated actions require snapshots. Actions that delete, rewrite, bulk transform, import over, or otherwise materially alter project content must define a snapshot or recovery expectation before implementation.

## Governance

Specs must be registered in `specs/registry.yml` before implementation work begins. Registry entries should identify milestone, status, source spec, acceptance path, related ADRs, related data contracts, planned modules, guardrails, and notes.

Architecture-changing decisions require ADRs. Persistent model changes require data contracts. Feature behavior requires acceptance criteria and Given/When/Then examples where behavior has state or branching outcomes.

## Current Scope Boundary

Through Milestone 4, DreamJotter remains documentation-first unless a later prompt explicitly asks for implementation scaffolding. Do not create production app code, app UI, an Xcode project, real AI provider integration, or plugin runtime as part of spec management work.
