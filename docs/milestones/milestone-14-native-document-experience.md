# Milestone 14 — Native document experience

## Status

Specified. Implementation begins with document ownership and package safety.

## Problem

DreamJotter currently presents one generic application window and manages project replacement inside that window. New, open, save, recent-project, close, and unsaved-change behavior are routed through custom notifications and modal panels. This makes the application behave like a project manager rather than a native macOS document application.

The `.dreamjotter` package is canonical storage. M14 must improve native document behavior without introducing partial package writes, duplicate ownership of one package, silent overwrite, or data loss during external changes.

## Delivery slices

### M14.1 — Document ownership

Branch: `feature/m14-document-ownership`

- Register and open `.dreamjotter` packages through native application open events.
- Introduce a canonical package identity that resolves aliases, symlinks, and standardized paths where possible.
- Prevent two live DreamJotter document sessions from owning the same package.
- Give every project window stable document identity and a project-specific title.
- Repair or remove missing recent-project entries without failing the application launch.
- Integrate successfully opened and saved packages with macOS recent documents.
- Replace notification-driven menu commands where native scene/document commands are available.
- Define the reopen-last-project policy and make it explicit and testable.

### M14.2 — Autosave and coordinated persistence

Branch: `feature/m14-autosave-policy`

Prerequisite: the package persistence ADR must be accepted before implementation.

- Define when autosave is allowed, delayed, suppressed, retried, or surfaced as an error.
- Keep package replacement atomic from the user's perspective.
- Use file coordination only at the boundary where it protects canonical package ownership.
- Detect external replacement or modification without silently overwriting newer data.
- Use native overwrite confirmation for Save As and package replacement.
- Preserve explicit Save semantics even when autosave is enabled.

### M14.3 — Window restoration

Branch: `feature/m14-window-restoration`

- Restore project windows using stable package identity.
- Avoid restoring missing, inaccessible, or already-open packages twice.
- Preserve useful window state without restoring transient sheets or alerts.
- Reconcile restoration with the reopen-last-project policy.

## Decisions required

- Whether DreamJotter adopts `DocumentGroup`/`FileDocument`, an AppKit document controller, or a bounded custom document-session layer.
- Whether autosave is continuous, event-driven, or opt-in for this milestone.
- How package generations are identified for external-change conflict detection.
- Which project/window state belongs in the package and which belongs in application restoration data.

## Acceptance criteria

1. Double-clicking or using Finder Open With on a `.dreamjotter` package opens that package in DreamJotter.
2. Opening the same canonical package twice focuses the existing project window instead of creating a second owner.
3. Each open package has one document session and one stable window identity.
4. Missing recent entries are removed or marked unavailable without repeated errors.
5. New, Open, Save, Save As, Close, and recent-document commands follow native macOS expectations.
6. Save As never overwrites an existing package without native confirmation.
7. Autosave cannot partially write the canonical package.
8. An external package change cannot be silently overwritten by an older in-memory project.
9. Reopening the app follows a documented policy and never creates duplicate project windows.
10. Window restoration handles missing and moved packages safely.
11. Unit or executable-spec coverage exists for package identity, duplicate protection, reopen policy, recent repair, save policy, and external-change decisions.
12. Manual acceptance covers Finder Open With, recent documents, duplicate open, overwrite confirmation, quit/relaunch, window restoration, and external package replacement.

## Non-goals

- Replacing the canonical `.dreamjotter` package format.
- Cloud synchronization.
- Multi-user editing.
- Background merge of conflicting screenplay edits.
- Silently resolving external-write conflicts.

## Verification strategy

- Pure core policies for canonical identity, ownership decisions, reopen policy, autosave eligibility, and external-change conflict decisions.
- App-layer integration tests for application open events, menu routing, recent-document repair, and window identity.
- Package-store regression tests proving staging, replacement, and failure behavior.
- Manual macOS verification for Finder, Dock, recent documents, Save panels, window restoration, and system termination behavior.
