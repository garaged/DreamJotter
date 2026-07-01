# Recent Projects Spec

Status: specified
Milestone: M6
Registry ID: APP-RECENT-PROJECTS

## User Goal

A writer can quickly return to recently opened or saved DreamJotter packages without making recent-project metadata part of canonical project storage.

## Scope

- Record recently opened `.dreamjotter` package URLs.
- Record projects after successful Save As.
- Display recent projects in the Project Library.
- Collapse duplicate paths into a single latest entry.
- Handle missing or invalid recent packages gracefully.
- Persist recent entries across relaunch if practical for the macOS app shell.

## Non-Goals

- No SwiftData canonical project storage.
- No cloud sync of recent projects.
- No search index or project content cache.
- No automatic migration of missing packages.

## Architecture Rules

- Recent projects are app metadata only.
- The `.dreamjotter` package remains the only canonical project source.
- Selecting a recent project uses the same open workflow as choosing a package manually.
- Invalid recent entries must not corrupt current document state.

## User-Facing Behavior

The Project Library shows a recent projects list. Successful opens and Save As operations add or refresh entries. Selecting an unavailable recent project shows a friendly error and leaves the current project safe.

## Given/When/Then Examples

- Given a project is opened, when open succeeds, then it appears in recent projects.
- Given a project is saved as a package, when Save As succeeds, then it appears in recent projects.
- Given a recent project path no longer exists, when selected, then the app shows a friendly error and does not crash.
- Given duplicate recent paths, then the app keeps a single latest entry.
- Given the app relaunches and persisted recents are available, when Project Library opens, then recent entries are shown.

## Edge Cases

- Package moved outside DreamJotter.
- Package renamed by Finder.
- Duplicate file URLs with different string forms.
- Permission denied on a recent path.
- Very long recent-project titles or paths.

## Data Model Implications

`RecentProjectEntry` includes stable ID, title, package path or URL string, last opened timestamp, last saved timestamp if known, optional project format version, and validity status if known.

## Storage Implications

Recent-project storage may use app preferences or app metadata. It must be rebuildable and must never be required to recover a `.dreamjotter` package.

## UI Implications

The Project Library should provide enough information for the writer to recognize a recent package. Missing or invalid entries should be removable or ignored in a later polish pass.

## Testability Notes

Tests should cover recording after open, recording after Save As, duplicate collapse, invalid path handling, and persistence serialization if a store abstraction exists.

## Open Questions

- Should invalid entries be removed automatically after a failed open or kept with a warning badge?
- How many recent projects should be retained by default?

## Executable Spec Plan

- Recent project recorded after open.
- Recent project recorded after Save As.
- Duplicate recent projects collapse to one entry.
- Invalid recent path returns a friendly error and preserves current project state.
