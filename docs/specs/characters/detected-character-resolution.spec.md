# Detected Character Resolution Spec

Status: specified
Milestone: 8
Registry ID: DETECTED-CHARACTER-RESOLUTION

## User Goal

Writers can turn detected script character cues into real character profiles without the app flooding the project with unwanted generic roles.

## Scope

- Detect likely character cues from semantic screenplay parse results.
- Show unresolved detected characters when no matching profile exists.
- Convert detections into profiles.
- Ignore detected names, especially generic roles.
- Preserve Unicode text.

## Non-Goals

- No automatic full profile creation.
- No AI classification of character importance.
- No destructive merge/rename workflow.

## Beginner Behavior

The app presents detected names as suggestions for cleanup. The writer chooses whether to convert or ignore each one.

## Pro Behavior

Future Pro Mode may support bulk merge, draft-specific ignore lists, or richer role classification. Milestone 8 only specifies safe single-item resolution.

## User-Facing Behavior

- `SOFIA` appears as unresolved when parsed as a character cue and no profile exists.
- Converting `SOFIA` creates a `CharacterProfile`.
- Ignoring `MAN` prevents repeated unresolved prompts for that name.
- Existing matching profiles remove detections from unresolved lists.

## Acceptance Criteria

- `A-M8-DETECTED-CHARACTER-001`
- `A-M8-DETECTED-CHARACTER-002`
- `A-M8-DETECTED-CHARACTER-003`
- `A-M8-DETECTED-CHARACTER-004`
- `A-M8-DETECTED-CHARACTER-005`
- `A-M8-DETECTED-CHARACTER-006`

## Given/When/Then Examples

Given the script contains `SOFIA`, when the parser refreshes, then unresolved detections include `SOFIA`.

Given the user converts unresolved `SOFIA`, when the action succeeds, then an active character profile named `SOFIA` exists.

Given the script contains `MAN`, when the user ignores it, then `MAN` is suppressed from unresolved detected characters.

## Edge Cases

- Generic roles include `MAN`, `WOMAN`, `GUARD`, `COP`, `COP #2`, `VOICE`, `ANNOUNCER`, `CROWD`, and `EVERYONE`.
- Malformed uppercase prose should not crash detection.
- Parentheticals and transitions should not be treated as character profiles.
- Duplicate detections collapse by normalized name.

## Data Model Implications

Uses `DetectedCharacter` for rebuildable detection records and project-level ignore state. User-authored profile data remains in `CharacterProfile`.

## Storage Implications

Ignored names are project metadata. Raw detected records are rebuildable from script text and need not be canonical unless cached.

## Command Implications

Convert and ignore actions should be explicit commands or view-model operations that mark dirty only when user-authored metadata changes.

## UI Implications

Detected characters can appear in Characters pane and dashboard cleanup counts. Conversion must be deliberate.

## Testability Notes

Executable specs should cover detection, conversion, generic ignore, duplicate collapse, existing-profile resolution, malformed text safety, and Unicode preservation.

## Platform Implications

Detection logic belongs in portable services and must not depend on Apple UI frameworks.

## Future Cross-Platform Implications

All platforms should produce the same unresolved detections for the same project package and screenplay text.

## Security and Privacy Notes

Detection runs locally from project screenplay text.

## Open Questions

- Should ignored detected names be stored per draft, per project, or globally per project?
- Should generic roles be auto-collapsed separately from named characters?
