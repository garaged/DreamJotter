# Notes Workflow Spec

Status: specified
Milestone: 8
Registry IDs: NOTES-WORKFLOW, SCRIPT-TODO-DETECTION

## User Goal

Writers can keep project, scene, character, and location notes in one workflow, including TODO notes detected from script text.

## Scope

- Create manual notes linked to project, scene, character, or location.
- Mark notes as open, resolved, or archived.
- Detect script TODO notes such as `[[TODO: improve this dialogue]]`.
- Search note text.
- Preserve manual notes through save/open.

## Non-Goals

- No task management integration.
- No collaboration comments.
- No AI-generated notes.
- No automatic deletion of manual notes when screenplay text changes.

## Beginner Behavior

The Notes pane shows open notes by default and keeps resolved/archived notes out of the way. Script TODOs are visible as derived notes.

## Pro Behavior

Future Pro Mode may add filters, tags, production departments, or routine-created notes. Milestone 8 only specifies basic links and status.

## User-Facing Behavior

- Adding a note marks the project dirty.
- Scene notes appear linked to the selected scene.
- `[[TODO: improve this dialogue]]` appears as a parsed TODO.
- Resolving a note hides it from open notes by default.
- Removing TODO syntax updates derived TODO behavior.

## Acceptance Criteria

- `A-M8-NOTES-001`
- `A-M8-NOTES-002`
- `A-M8-NOTES-003`
- `A-M8-NOTES-004`
- `A-M8-NOTES-005`
- `A-M8-NOTES-006`

## Given/When/Then Examples

Given a project has no notes, when the user adds a project note, then the note appears as open and the project becomes dirty.

Given the script contains `[[TODO: improve this dialogue]]`, when parse-derived notes refresh, then an open derived TODO appears.

Given a manual note is resolved, when open notes are shown, then that note is hidden by default.

## Edge Cases

- Unicode note text must be preserved.
- Missing linked entities should not corrupt notes; links can become unresolved.
- Parsed TODOs are derived and should not be confused with manual notes.
- Removing TODO syntax should not delete manual notes that happen to contain similar text.

## Data Model Implications

Uses `ProjectNote` for manual and derived note views. `source` distinguishes `manual`, `parsedScriptTodo`, `imported`, and `routine`.

## Storage Implications

Manual notes are canonical package data. Parsed TODO notes are rebuildable from screenplay text; only user decisions about derived TODOs may require metadata.

## Command Implications

Create, edit, resolve, archive, and relink notes should route through workflow operations that mark dirty for persistent changes.

## UI Implications

Notes view should support project-level creation and context-aware links to selected scene, character, or location.

## Testability Notes

Executable specs should cover add project note, add scene note, resolve note, search note, parse TODO, remove TODO behavior, save/reopen, and Unicode preservation.

## Platform Implications

Note parsing and persistence must be portable.

## Future Cross-Platform Implications

All future platforms should show the same manual notes and derived TODOs from the package and screenplay text.

## Security and Privacy Notes

Notes remain local project data and are not sent externally.

## Open Questions

- Should users be able to promote a parsed TODO into a manual note?
- Should ignored parsed TODOs be tracked if the text remains in the screenplay?
