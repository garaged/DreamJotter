# ADR-014 — Canonical package persistence and document ownership

- Status: Accepted
- Date: 2026-07-04
- Accepted: 2026-07-05
- Milestone: M14 — Native document experience

## Context

A `.dreamjotter` package is the canonical representation of a DreamJotter project. The current macOS application owns an optional package URL inside a custom view model, presents a single generic window, and performs open/save operations through custom panels and notifications.

M14 adds native open events, recent documents, autosave, external-change detection, guarded persistence, and restoration. These features increase the chance that two sessions write the same package, that a stale in-memory project overwrites a newer external version, or that a package is left partially updated.

The persistence design therefore had to be decided before autosave and conflict handling were implemented.

## Decision

### 1. The package remains canonical storage

The in-memory project is a working representation. It does not become authoritative over a newer package generation merely because its window remains open.

### 2. One live writer owns one canonical package identity

DreamJotter derives a `DocumentPackageIdentity` from a standardized and symlink-resolved URL where available. The document-session policy allows at most one writable session for that identity.

A repeated open request must activate or reuse the existing owner. It must not load a second mutable copy.

### 3. Unsaved documents have session identity, not package identity

A new project acquires package identity only after the first successful Save As. A failed or canceled Save As does not reserve the destination.

### 4. Package saves preserve the prior canonical package on failure

DreamJotter guards canonical writes with a recoverable backup boundary. If a save fails, the previous package is restored. If the first save of a new package fails, the incomplete package is removed.

The user must never be left with a partially updated canonical package after a reported save failure.

### 5. Every loaded and saved package has a generation fingerprint

A document session records a package fingerprint after open and after each successful save. The fingerprint combines canonical identity with digests of required package content.

Before replacing canonical storage, DreamJotter compares the observed generation with the session's expected generation.

### 6. External changes require an explicit decision

When the package generation differs from the expected generation, DreamJotter does not autosave or silently overwrite it.

The document enters a conflict state and offers explicit choices: reload the external version, save the in-memory project to another package, deliberately replace after warning, or cancel. Automatic semantic merge is outside M14.

### 7. Autosave is policy-controlled, not an unconditional timer

Autosave may run only when all of these are true:

- the document has a canonical package identity;
- the session owns that identity;
- the document is dirty;
- no save, import, restore, or replacement operation is active;
- no external-change conflict is unresolved;
- the package destination remains reachable and writable;
- the debounce trigger has fired.

A new unsaved project never presents a Save As panel solely because autosave fired.

### 8. File coordination remains bounded to the persistence boundary

Platform coordination may be added around canonical package reads and final replacement where it provides additional value. Core models and command handling remain independent of file-presenter behavior.

Coordination does not replace guarded writes, generation validation, or explicit conflict handling.

### 9. Native overwrite confirmation remains authoritative

Save As uses the native save panel and its overwrite confirmation. DreamJotter does not pre-delete or silently replace an existing destination before the panel authorizes replacement.

### 10. Restoration stores references, not project contents

Workspace restoration persists canonical package references. It does not serialize an alternate canonical copy of the project. Missing or inaccessible packages are skipped without reconstructing stale project data.

## Consequences

### Positive

- Autosave no longer normalizes unsafe unconditional writes.
- Duplicate ownership is represented by an explicit tested policy.
- External replacement becomes visible instead of becoming silent data loss.
- Native open, recent-document, and restoration events converge on canonical package identity.
- Persistence safety is covered by pure policy tests and failure-recovery tests.

### Costs

- Document opening is mediated by routing and ownership policies rather than being only direct view-model replacement.
- Package identity and generation detection require platform-aware adapters.
- Guarded writes require temporary backup storage during saves.
- Full multi-window document sessions remain a future architectural expansion beyond the current restored-workspace model.

## Rejected alternatives

### Mutate package files without recovery

Rejected because interruption can leave canonical storage internally inconsistent.

### Allow one mutable model per window for the same URL

Rejected because last-writer-wins behavior would be silent and nondeterministic.

### Treat modification date as the only conflict signal

Rejected because timestamp granularity, copying, and replacement can produce false confidence.

### Autosave every edit immediately

Rejected because parser/editor changes may be frequent, new projects have no destination, and save eligibility depends on ownership and external generation.

### Let file coordination solve all conflicts

Rejected because coordination controls access timing but does not decide whether overwriting a newer external generation is correct.

## Acceptance evidence

The accepted implementation includes coverage for:

- canonical identity equality for standardized and symlinked URLs;
- one-owner registry behavior and duplicate-open decisions;
- failed-save recovery for existing and new packages;
- successful save generation refresh;
- generation mismatch blocking autosave and explicit save;
- autosave eligibility rules;
- missing restoration and recent references;
- Save As cancellation and native overwrite behavior;
- Finder/Open With routing and macOS Recent Documents integration.

Local build, automated tests, and manual macOS acceptance were reported passing on 2026-07-05.
