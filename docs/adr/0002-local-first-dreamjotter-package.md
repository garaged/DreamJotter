# ADR 0002: Local-First `.dreamjotter` Package

## Status

Accepted.

## Context

DreamJotter projects need to be owned by writers, portable across future platforms, and structured enough to support semantic editing, export, validation, and automation.

SwiftData can be useful inside an Apple app, but it is not an appropriate canonical cross-platform project format.

## Decision

The canonical project format is a local-first `.dreamjotter` document package. SwiftData may be used later for app metadata, cache, search indexes, recents, or other derived convenience data, but not as the source of truth for screenplay content or project state.

## Consequences

- Project specs must define the `.dreamjotter` package contract before implementation.
- Screenplay documents must be stored as semantic project data.
- App caches must be rebuildable from the `.dreamjotter` package.
- Cloud sync, if added later, transports project files rather than replacing them as the source of truth.
