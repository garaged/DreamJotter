# Location Workflow Spec

Status: specified
Milestone: 8
Registry ID: LOCATION-PROFILE-WORKFLOW

## User Goal

Writers can manage locations as project objects and use them while writing scene headings.

## Scope

- Create, edit, archive, and search location profiles.
- Use active location profiles in scene-heading autocomplete.
- Show scene appearances derived from parsed headings.
- Preserve profiles through save/open.

## Non-Goals

- No map/geocoding integration.
- No production location scouting workflow.
- No external data lookup.

## Beginner Behavior

The Locations pane lists active locations, detected unresolved locations, and a straightforward profile editor.

## Pro Behavior

Future Pro Mode may add custom fields, shooting logistics, and production breakdown links. Milestone 8 keeps location profiles writer-focused.

## User-Facing Behavior

- Creating `COFFEE SHOP` makes it available when typing `INT. COF`.
- Editing a location marks the project dirty.
- Scene appearances derive from scene headings.
- Archived locations are not primary suggestions by default.

## Acceptance Criteria

- `A-M8-LOCATION-001`
- `A-M8-LOCATION-002`
- `A-M8-LOCATION-003`
- `A-M8-LOCATION-004`

## Given/When/Then Examples

Given a location profile named `COFFEE SHOP`, when the user starts `INT. COF`, then `COFFEE SHOP` is suggested.

Given a profile appears in scene headings, when the location profile opens, then scene appearances can be listed.

## Edge Cases

- Aliases must not silently overwrite another location.
- Unicode and Spanish location names must be preserved.
- Archived locations remain recoverable and searchable.

## Data Model Implications

Uses `LocationProfile` for user-authored profiles and derived appearances from scene headings.

## Storage Implications

Location profiles are canonical project metadata in `.dreamjotter` storage. Appearance indexes are rebuildable.

## Command Implications

Create, update, archive, and restore should route through workflow services that mark dirty consistently.

## UI Implications

SwiftUI views bind to location workflow state. Editor suggestions consume profile data but do not own it.

## Testability Notes

Executable specs should cover create, edit-dirties, save/reopen, profile autocomplete, archived filtering, and scene appearance derivation.

## Platform Implications

Location workflow logic must remain portable and Apple-framework-free.

## Future Cross-Platform Implications

All future platforms read and write the same location profile records.

## Security and Privacy Notes

Location names remain local project data.

## Open Questions

- Should locations support nested areas such as `HOUSE / KITCHEN` in Milestone 8 or later?
