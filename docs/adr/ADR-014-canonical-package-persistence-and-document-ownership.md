# ADR-014 — Canonical package persistence and document ownership

- Status: Proposed
- Date: 2026-07-04
- Milestone: M14 — Native document experience

## Context

A `.dreamjotter` package is the canonical representation of a DreamJotter project. The current macOS application owns an optional package URL inside a custom view model, presents a single generic window, and performs open/save operations through custom panels and notifications.

M14 adds native open events, multiple project windows, recent documents, autosave, external-change detection, file coordination, and restoration. These features increase the chance that two sessions write the same package, that a stale in-memory project overwrites a newer external version, or that a package is left partially updated.

The persistence design therefore has to be decided before autosave or file coordination is implemented.

## Decision

### 1. The package remains canonical storage

The in-memory project is a working representation. It does not become authoritative over a newer package generation merely because its window remains open.

### 2. One live writer owns one canonical package identity

DreamJotter will derive a `DocumentPackageIdentity` from a standardized, file-reference-aware URL where available. The application document-session registry will allow at most one writable session for that identity.

A repeated open request must activate the existing window. It must not load a second mutable copy.

### 3. Unsaved documents have session identity, not package identity

A new project receives a stable session identifier. It acquires package identity only after the first successful Save As. A failed or canceled Save As does not reserve the destination.

### 4. Package saves use staged complete output and replacement

Persistence must produce a complete package at a staging location before replacing canonical storage. The canonical package must never be mutated file-by-file in place.

The replacement operation must either leave the prior package valid or install the complete new package. Temporary staging artifacts may be cleaned up after failure, but failure must be reported and the document must remain dirty.

### 5. Every loaded and saved package has a generation fingerprint

A document session records a package fingerprint after open and after each successful save. The fingerprint may combine stable file identity and package metadata sufficient to detect replacement or modification. Exact representation is an implementation detail, but modification time alone is not considered a strong enough identity signal.

Before replacing canonical storage, the store compares the observed generation with the session's expected generation.

### 6. External changes require an explicit decision

When the package generation differs from the expected generation, DreamJotter must not autosave or silently overwrite it.

The document enters a conflict state and offers explicit choices appropriate to the situation, such as reopen the external version, save the in-memory project to another package, or deliberately replace after warning. Automatic semantic merge is outside M14.

### 7. Autosave is policy-controlled, not an unconditional timer

Autosave may run only when all of these are true:

- the document has a canonical package identity;
- the session owns that identity;
- the document is dirty;
- no save, import, restore, or replacement operation is active;
- no external-change conflict is unresolved;
- the package destination remains reachable and writable;
- the policy-selected debounce or lifecycle trigger has fired.

A new unsaved project never presents a Save As panel solely because an autosave timer fired.

### 8. File coordination is bounded to the persistence boundary

`NSFileCoordinator` may be used around canonical package reads, generation checks, and final replacement where coordination provides meaningful protection. Core models and command handling remain independent of AppKit/Foundation file-presenter behavior.

Coordination does not replace staged writes, generation validation, or explicit conflict handling.

### 9. Native overwrite confirmation remains authoritative

Save As uses the native save panel and its overwrite confirmation. DreamJotter must not pre-delete or silently replace an existing destination before the panel and persistence policy authorize replacement.

### 10. Restoration stores references, not project contents

Window restoration persists session/window metadata and a package reference sufficient to request reopening. It does not serialize an alternate canonical copy of the project. Missing or inaccessible packages are skipped or surfaced without reconstructing stale project data.

## Consequences

### Positive

- Autosave cannot normalize unsafe in-place package mutation.
- Duplicate windows cannot independently overwrite the same project.
- External replacement becomes visible instead of becoming data loss.
- Native open/recent/restoration events converge on one document-session registry.
- Persistence safety can be tested mostly through pure policy types and package-store integration tests.

### Costs

- Document opening becomes a registry-mediated operation rather than a direct view-model replacement.
- Package identity and generation detection require platform-aware adapters.
- Autosave implementation is deferred until staged replacement and conflict policy exist.
- Some native document APIs may need wrapping instead of direct adoption because the package format and current semantic core already have established persistence boundaries.

## Rejected alternatives

### Mutate package files in place

Rejected because interruption can leave canonical storage internally inconsistent.

### Allow one mutable model per window for the same URL

Rejected because last-writer-wins behavior would be silent and nondeterministic.

### Treat modification date as the only conflict signal

Rejected because timestamp granularity, copying, and replacement can produce false confidence.

### Autosave every edit immediately

Rejected because parser/editor changes may be frequent, new projects have no destination, and save eligibility depends on ownership and external generation.

### Let file coordination solve all conflicts

Rejected because coordination controls access timing but does not decide whether overwriting a newer external generation is correct.

## Required tests before acceptance

- canonical identity equality for standardized aliases and equivalent URLs;
- one-owner registry behavior and existing-window activation decision;
- unsaved session identity transitioning to package identity only after successful save;
- staged-write failure preserves the prior package;
- successful replacement updates the expected generation;
- generation mismatch blocks autosave and normal save replacement;
- autosave eligibility matrix;
- missing restoration/recent references do not create sessions;
- Save As cancellation and overwrite paths preserve ownership invariants.
