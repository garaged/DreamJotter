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

## Apple UI

- Create Xcode project only after portable core executable specs are passing.
- Build macOS app shell first.
- Add iPadOS/iOS app shell after macOS foundations are stable.
- Keep Apple UI adapters thin over portable core behavior.
- Do not make SwiftData canonical storage.
- Preserve Simple Mode as the first-run experience.

## TextKit Editor

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
