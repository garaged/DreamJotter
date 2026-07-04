# Milestone 14 — Native document experience

## Status

Accepted on 2026-07-05.

## Outcome

DreamJotter now behaves as a native macOS package-document application for its current workspace architecture. `.dreamjotter` packages can be opened through Finder and Open With, successful opens and saves integrate with macOS Recent Documents, autosave is policy-controlled, external package changes are detected before overwrite, failed saves preserve canonical storage, and the last valid workspace can be restored safely.

## Delivered scope

### M14.1 — Document ownership and native opening

- Registered `.dreamjotter` as a macOS package document type.
- Added native application-open routing for Finder, Dock, and Open With events.
- Added canonical package identity based on standardized and symlink-resolved URLs.
- Added one-owner session policy and duplicate-open decisions.
- Added sequential launch-time and runtime open request handling.
- Added project-specific window titles and unsaved-state markers.
- Added missing and duplicate recent-project repair.
- Integrated successful opens and saves with macOS Recent Documents.
- Added an explicit and tested reopen policy.

### M14.2 — Autosave and persistence safety

- Added generation fingerprints for required package content.
- Added generation comparison before explicit save and autosave.
- Added explicit external-conflict choices:
  - reload the external version;
  - Save As to another package;
  - deliberately replace the external version;
  - cancel.
- Added debounced autosave for saved, dirty, owned, reachable, writable, conflict-free projects.
- Prevented autosave from presenting Save As for unsaved projects.
- Suppressed autosave during save, replacement, and restore operations.
- Added guarded package writes that restore the previous package after failure.
- Added cleanup of incomplete packages after failed first save.
- Kept native Save As overwrite confirmation authoritative.

### M14.3 — Workspace restoration

- Persisted canonical package references rather than project contents.
- Restored the last valid active project after relaunch.
- Gave native open requests precedence over restoration.
- Skipped missing or inaccessible restoration references safely.
- Avoided restoring transient sheets, alerts, and conflict UI state.

## Accepted decisions

ADR-014 is accepted. DreamJotter uses a bounded custom document-session and persistence layer around the existing semantic core rather than adopting `DocumentGroup` or `NSDocument` in this milestone.

The canonical `.dreamjotter` package remains authoritative. Autosave and explicit save require a matching expected generation. Conflicts are surfaced rather than merged or overwritten silently.

## Acceptance criteria

1. Finder double-click and Open With open `.dreamjotter` packages in DreamJotter — accepted.
2. Equivalent package identities are deduplicated by the ownership and routing policies — accepted.
3. The active package has stable canonical identity and a project-specific title — accepted.
4. Missing recent entries are removed or skipped without repeated launch failures — accepted.
5. New, Open, Save, Save As, Close, and recent-document behavior follows the current native macOS workflow — accepted.
6. Save As relies on native overwrite confirmation — accepted.
7. Failed saves preserve the previous package or remove an incomplete new package — accepted.
8. External changes cannot be silently overwritten by explicit save or autosave — accepted.
9. Relaunch follows the documented native-open-first restoration policy — accepted.
10. Missing restoration references are handled safely — accepted.
11. Automated coverage exists for identity, ownership, routing, recent repair, save recovery, autosave policy, generation conflicts, and restoration repair — accepted.
12. Manual macOS acceptance for Finder/Open With, Recent Documents, autosave, conflict choices, overwrite confirmation, and quit/relaunch passed — accepted.

## Verification completed

- `swift build`
- `swift test`
- packaged application script validation
- Finder and Open With package opening
- package selection through the native Open panel
- Recent Documents registration
- autosave of saved projects
- no automatic Save As for unsaved projects
- external-generation conflict handling
- reload, Save As, and deliberate replacement conflict paths
- failed-save recovery
- quit and relaunch workspace restoration
- safe startup after a restoration package is moved or deleted

## Non-goals retained

- Replacing the canonical `.dreamjotter` package format.
- Cloud synchronization.
- Multi-user editing.
- Automatic semantic merge of conflicting screenplay edits.
- Full independent multi-window document sessions.
