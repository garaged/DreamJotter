# Milestone 8: Character, Location, Notes, and Scene Workflow v1

Status: implemented with deferred polish
Milestone: M8
Traceability ID: M8-CHARACTER-LOCATION-NOTES-SCENE-WORKFLOW

## Goal

Turn parsed screenplay data into useful project objects the writer can manage, while preserving the current writing, editor, and document lifecycle.

Milestone 8 lets a writer type normally, then use detected characters, locations, scenes, and TODO notes as a bridge into real project objects. The app must keep parsed data and user-authored metadata separate so recalculating screenplay-derived information never destroys notes, profiles, scene status, or summaries.

## Product Outcome

- Writers can create, edit, archive, and search character profiles.
- Writers can review detected unresolved character cues and convert or ignore them.
- Writers can create, edit, archive, and search location profiles.
- Writers can review detected unresolved locations from scene headings and convert or ignore them.
- Scene cards show screenplay order, derived scene facts, user-authored status, and notes.
- Notes can be project, scene, character, or location linked.
- Script TODO notes are detected from screenplay text.
- Dashboard shows object counts and unresolved cleanup work.

## Scope

- Character profile workflow.
- Detected character resolution workflow.
- Location profile workflow.
- Detected location resolution workflow.
- Scene card workflow.
- Notes workflow, including parsed TODO detection.
- Dashboard workspace summary.
- Search integration for profiles, locations, notes, and scene metadata.
- Save/open/export preservation for all Milestone 8 metadata.

## Non-Goals

- No iOS or iPadOS target.
- No iCloud or sync.
- No real AI provider.
- No plugin runtime.
- No production breakdown UI.
- No automatic destructive merge or rename behavior.
- No SwiftData canonical storage.
- No replacement of `.dreamjotter` package storage.

## Architecture Rules

- macOS first.
- Portable core always.
- TextKit remains an editor adapter only.
- Semantic screenplay model remains canonical.
- `.dreamjotter` package remains canonical storage.
- SwiftData must not become canonical storage.
- SwiftUI views must stay thin.
- Project object workflows belong in testable core services, app-support services, or view models.
- Parsed detections must be distinct from user-authored profiles and scene metadata.
- Milestone 6 document lifecycle and Milestone 7 editor behavior must remain intact.

## Feature Areas

### A. Character Profile Workflow

Character profiles are explicit project objects with beginner-friendly fields: name, aliases, role, description, motivation, want, need, backstory, notes, timestamps, and archived status. Character autocomplete should prefer active profiles. Script appearances are derived from screenplay cues.

### B. Detected Character Workflow

Detected character cues come from parsed screenplay text. Unresolved detections appear when no active matching profile exists and the name is not ignored. Writers can convert a detection into a profile or ignore generic names such as `MAN`, `WOMAN`, `GUARD`, `COP`, `VOICE`, `ANNOUNCER`, `CROWD`, and `EVERYONE`.

Implementation status: portable core, app view-model actions, Characters pane presentation, and executable specs are implemented for manual profile create/edit/save/reopen, unresolved detection, existing-profile matching, convert-to-profile, generic ignore, duplicate collapse, malformed text safety, Unicode preservation, and ignored-key `.dreamjotter` package persistence.

### C. Location Profile Workflow

Location profiles are explicit project objects with name, aliases, description, notes, timestamps, and archived status. Location autocomplete should prefer active profiles and may also include parsed locations.

Implementation status: basic manual profile create/edit/save/reopen is implemented in the app workflow. Profile-backed suggestions use the existing editor suggestion flow. Archive/delete and richer profile fields remain deferred polish.

### D. Detected Location Workflow

Detected locations come from scene headings such as `INT. APARTMENT - MORNING`, `EXT. PARK - NIGHT`, and `INT./EXT. CAR - CONTINUOUS`. Time of day is never treated as the location. Writers can convert or ignore detected locations.

Implementation status: portable detection, duplicate collapse, Unicode normalization, convert/ignore actions, Locations pane presentation, dirty state, and `.dreamjotter` package persistence are implemented and covered by executable specs.

### E. Scene Cards Workflow

Scene cards show derived scene facts in screenplay order and allow user-authored metadata such as status, summary, plotline tags, and linked notes. Derived heading/location/time/characters update from the screenplay without discarding user metadata where identity can be matched.

Implementation status: scene cards derive heading, location, time of day, and characters; user-authored status is editable from the Scenes pane and preserved separately from derived screenplay data.

### F. Notes Workflow

Manual notes can link to project, scene, character, or location objects. Notes support open, resolved, and archived states. Parsed script TODO notes such as `[[TODO: improve this dialogue]]` are derived from screenplay text and should update when screenplay text changes.

Implementation status: note links support project, scene, character, and location targets; open/resolved status is implemented; parsed TODO notes are derived from script text without becoming canonical manual notes.

### G. Dashboard Integration

Dashboard summary should include project title, logline, synopsis, scene count, character profile count, unresolved detected character count, location profile count, unresolved detected location count, open notes count, TODO count, dirty/saved status where available, and last saved timestamp if known.

Implementation status: `ProjectWorkspaceSummaryBuilder` and the macOS dashboard expose scene, profile, unresolved detection, open note, TODO, dirty, and saved-state counts.

### H. Search Integration

Search should include character profiles, location profiles, notes, and scene card metadata where practical.

Implementation status: project search covers character profiles, location profiles, notes, and scene card metadata through rebuildable core indexes.

### I. Save/Open/Export Preservation

All user-authored Milestone 8 metadata persists through `.dreamjotter` save/open. Fountain export remains screenplay text only and excludes profile, note, detection, and scene-card metadata unless a future export intentionally includes it.

Implementation status: character profiles, location profiles, ignored detection keys, notes, and scene-card metadata persist through the local package store. Fountain export remains screenplay text only.

## Data Contracts

- `docs/data-contracts/character-profile.md`
- `docs/data-contracts/detected-character.md`
- `docs/data-contracts/location-profile.md`
- `docs/data-contracts/detected-location.md`
- `docs/data-contracts/scene-card.md`
- `docs/data-contracts/project-note.md`
- `docs/data-contracts/project-workspace-summary.md`

## Related Specs

- `docs/specs/characters/character-workflow.spec.md`
- `docs/specs/characters/detected-character-resolution.spec.md`
- `docs/specs/locations/location-workflow.spec.md`
- `docs/specs/locations/detected-location-resolution.spec.md`
- `docs/specs/scenes/scene-card-workflow.spec.md`
- `docs/specs/notes/notes-workflow.spec.md`
- `docs/specs/dashboard/project-dashboard-workflow.spec.md`

## Executable Spec Plan

- Create character profile.
- Edit character profile marks dirty.
- Save/reopen character profile.
- Detect unresolved character from script.
- Convert detected character to profile.
- Ignore detected generic character.
- Character autocomplete uses profiles.
- Character appearances derive from script.
- Create location profile.
- Edit location profile marks dirty.
- Detect location from scene heading.
- Convert detected location to profile.
- Ignore detected location.
- Location autocomplete uses profiles and detected locations.
- Scene cards generate in screenplay order.
- Scene card click navigates to editor.
- Scene status update marks dirty.
- Scene metadata survives save/reopen.
- Add project note.
- Add scene note.
- Resolve note.
- Detect script TODO note.
- Dashboard counts unresolved characters, unresolved locations, and open notes.
- Search finds characters, locations, and notes.
- M8 metadata does not pollute Fountain export.
- M8 workflows preserve Milestone 6 and Milestone 7 behavior.

## Deferred Work

- Character/location archive and delete UI.
- Rich character fields such as aliases, role, motivation, want, need, and backstory.
- Rich location fields such as aliases and structured description fields.
- Full note search/filter UI and archive UI.
- Bulk merge/rename workflows.
- Production breakdown integration.
- Relationship graph visualization.
- AI-assisted profile generation.
- Cloud/team collaboration.
- Plugin-provided metadata panels.

## Open Questions

- Should archived profiles remain available in autocomplete behind an explicit toggle, or only through search?
- Should ignored detected names be scoped globally to a project or scoped by screenplay draft/version?
- What stable scene identity strategy is sufficient before production revision workflows exist?
