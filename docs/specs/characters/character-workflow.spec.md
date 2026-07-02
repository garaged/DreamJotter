# Character Workflow Spec

Status: specified
Milestone: 8
Registry ID: CHARACTER-PROFILE-WORKFLOW

## User Goal

Writers can manage characters as project objects, not only as uppercase cues parsed from the script.

## Scope

- Create, edit, archive, and search character profiles.
- Use active character profiles in editor autocomplete.
- Derive script appearances from semantic screenplay data.
- Preserve character profiles through `.dreamjotter` save/open.

## Non-Goals

- No AI-generated character profiles.
- No relationship graph.
- No production casting workflow.
- No automatic profile creation for every uppercase line.

## Beginner Behavior

The Characters pane shows active profiles, detected unresolved names, and a clear create/edit flow. Archived characters are hidden from primary suggestions by default.

## Pro Behavior

Future Pro Mode may expose aliases, draft-specific appearances, relationship metadata, and custom fields. Milestone 8 only specifies the beginner-safe profile workflow.

## User-Facing Behavior

- A writer creates `ELENA` as a character profile.
- Typing `ELE` in a character cue context suggests `ELENA`.
- Editing profile fields marks the project dirty.
- Saving and reopening restores the profile.
- Appearances are derived from script cues and do not need manual maintenance.

## Acceptance Criteria

- `A-M8-CHARACTER-001`
- `A-M8-CHARACTER-002`
- `A-M8-CHARACTER-003`
- `A-M8-CHARACTER-004`
- `A-M8-CHARACTER-005`

## Given/When/Then Examples

Given a project has no character profiles, when the user creates `ELENA`, then the Characters pane shows `ELENA` as active.

Given `ELENA` is active, when the user types `ELE` in a character line, then `ELENA` is suggested without mutating text until accepted.

Given `ELENA` appears in dialogue cues, when the character profile opens, then appearances can be listed from parsed screenplay elements.

## Edge Cases

- Duplicate names should resolve by normalized name while preserving display spelling.
- Unicode names must be preserved.
- Archived profiles should remain searchable but not primary autocomplete suggestions.
- Alias collisions should surface a friendly validation warning instead of silently merging.

## Data Model Implications

Uses `CharacterProfile` for user-authored profiles and derived appearance references from semantic screenplay elements.

## Storage Implications

Character profiles are canonical project metadata in the `.dreamjotter` package. Derived appearances are rebuildable and should not be the only source of user-authored profile data.

## Command Implications

Future implementation should route create, update, archive, and restore through command-style app/core services so dirty state and snapshots remain consistent.

## UI Implications

SwiftUI views stay thin and bind to a character workflow view model. The editor suggestion panel consumes profile-derived suggestions but does not own profile logic.

## Testability Notes

Executable specs should cover create, edit-dirties, save/reopen, autocomplete from profiles, archived-profile filtering, and derived appearances.

## Platform Implications

The workflow must be portable. macOS UI is first, but profile data and matching rules must not depend on AppKit, SwiftUI, or SwiftData.

## Future Cross-Platform Implications

iPadOS, iOS, and future non-Apple apps should read the same character profile data from package storage.

## Security and Privacy Notes

Character profiles stay local in the project package. No external service receives profile text in this milestone.

## Open Questions

- Should aliases be suggested with the canonical name or as their own visible suggestions?
- Should archived characters appear in autocomplete behind a per-project toggle?
