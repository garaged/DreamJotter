# Project Dashboard Workflow Spec

Status: specified
Milestone: 8
Registry IDs: DASHBOARD-WORKSPACE-SUMMARY, PROJECT-OBJECT-SEARCH-INTEGRATION, M8-DOCUMENT-WORKFLOW-PRESERVATION

## User Goal

Writers can see the current project state at a glance and find characters, locations, notes, and scene metadata through search.

## Scope

- Summarize project title, logline, synopsis, scene count, profile counts, unresolved detection counts, open notes, TODOs, dirty state, and last saved information.
- Include character profiles, location profiles, notes, and scene card metadata in search.
- Preserve document lifecycle behavior while adding project object workflows.
- Keep Fountain export based on screenplay text.

## Non-Goals

- No analytics dashboard.
- No cloud status.
- No collaboration activity feed.
- No metadata injection into Fountain export.

## Beginner Behavior

Dashboard highlights useful next steps: keep writing, clean up unresolved detected characters or locations, and resolve open notes.

## Pro Behavior

Future Pro Mode may expose production counts, revision state, or custom-field summaries. Milestone 8 keeps the dashboard writer-focused.

## User-Facing Behavior

- Dashboard shows scene count from the parsed script.
- Unresolved detected character/location counts are visible.
- Open note and TODO counts are visible.
- Search finds profiles, locations, notes, and scene metadata.
- Export does not include internal metadata.

## Acceptance Criteria

- `A-M8-DASHBOARD-001`
- `A-M8-DASHBOARD-002`
- `A-M8-DASHBOARD-003`
- `A-M8-DASHBOARD-004`
- `A-M8-DASHBOARD-005`
- `A-M8-SEARCH-001`
- `A-M8-SEARCH-002`
- `A-M8-SEARCH-003`
- `A-M8-PRESERVE-001`
- `A-M8-PRESERVE-002`
- `A-M8-PRESERVE-003`
- `A-M8-PRESERVE-004`

## Given/When/Then Examples

Given a project has two scenes, when the dashboard opens, then scene count is `2`.

Given unresolved characters exist, when the dashboard opens, then the unresolved character count is shown.

Given a note contains `rewrite`, when the user searches `rewrite`, then the note appears.

Given project metadata exists, when Fountain export runs, then export contains screenplay text and no profile metadata.

## Edge Cases

- Empty projects should show zero counts without warnings.
- Missing last saved timestamp should display as unknown or unsaved.
- Search should be case-insensitive.
- Search indexes are rebuildable and must not become canonical storage.

## Data Model Implications

Uses `ProjectWorkspaceSummary` for dashboard data. Search results may reference `CharacterProfile`, `LocationProfile`, `ProjectNote`, and `SceneCard`.

## Storage Implications

Dashboard summaries and search indexes are derived from canonical project package data and may be rebuilt.

## Command Implications

Dashboard itself is read-only. Search result actions may navigate or open editors but should not mutate data unless the user explicitly edits.

## UI Implications

Dashboard views should be thin and receive summary state from a view model or service.

## Testability Notes

Executable specs should cover counts, search result inclusion, metadata preservation through save/open, and export exclusion of project-object metadata.

## Platform Implications

Summary and search services should be portable or app-support code that does not depend on SwiftUI, AppKit, SwiftData, or CloudKit.

## Future Cross-Platform Implications

Future iPad/iPhone dashboards should consume the same summary contract.

## Security and Privacy Notes

Dashboard and search operate on local project package data.

## Open Questions

- Should dashboard cleanup counts link directly into filtered Characters/Locations panes in Milestone 8 implementation?
