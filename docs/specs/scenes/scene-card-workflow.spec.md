# Scene Card Workflow Spec

Status: specified
Milestone: 8
Registry ID: SCENE-CARD-WORKFLOW

## User Goal

Writers can review and manage scenes as cards that combine parsed screenplay facts with user-authored planning metadata.

## Scope

- Generate scene cards in screenplay order from semantic scene data.
- Show heading, location, time of day, characters, notes, status, summary, and tags where available.
- Allow user-authored scene status and metadata edits.
- Navigate from a scene card to the editor scene.
- Preserve user metadata through save/open.

## Non-Goals

- No production scheduling board.
- No drag-to-reorder screenplay structure.
- No revision locking workflow.
- No AI summaries.

## Beginner Behavior

The Scenes pane shows readable cards in script order. A writer can click a card to jump to the script and update the scene status without learning screenplay internals.

## Pro Behavior

Future Pro Mode may add production breakdown, custom fields, and draft comparison links. Milestone 8 only specifies writer-facing status and metadata.

## User-Facing Behavior

- Scene cards appear in screenplay order.
- Clicking a scene card navigates to its scene heading.
- Changing scene status marks the project dirty.
- Heading changes update derived card text without dropping user-authored status where identity can be matched.

## Acceptance Criteria

- `A-M8-SCENE-001`
- `A-M8-SCENE-002`
- `A-M8-SCENE-003`
- `A-M8-SCENE-004`
- `A-M8-SCENE-005`

## Given/When/Then Examples

Given a script has three scene headings, when the Scenes pane opens, then three cards appear in screenplay order.

Given the user clicks Scene 2, when navigation succeeds, then the editor selection moves to Scene 2.

Given the user sets status to `needsRewrite`, when the project saves and reopens, then the card retains `needsRewrite`.

## Edge Cases

- Duplicate headings should use stable parsed position or scene ID strategy.
- Deleted scenes should not crash metadata resolution.
- Reordered scenes should preserve metadata when the identity strategy can match safely.
- User metadata must not overwrite derived parse facts.

## Data Model Implications

Uses `SceneCard` with separated derived metadata and user metadata. Derived fields rebuild from semantic screenplay elements; user fields persist.

## Storage Implications

Only user-authored scene card metadata must be canonical. Derived scene-card data is rebuildable.

## Command Implications

Scene status, summary, tags, and note links should update through workflow operations that mark dirty.

## UI Implications

The Scenes pane binds to scene card view model state and uses existing editor navigation APIs for jumps.

## Testability Notes

Executable specs should cover generation order, navigation target creation, status dirtying, save/reopen metadata, deleted scene fallback, and duplicate heading handling.

## Platform Implications

Scene card assembly and metadata matching belong in portable or app-support services, not SwiftUI views.

## Future Cross-Platform Implications

Scene cards should render consistently on future iPad and iPhone panes while using the same canonical package data.

## Security and Privacy Notes

Scene metadata remains local project data.

## Open Questions

- What scene identity rule is sufficient before production revisions exist?
- Should status defaults come from script parse state or remain user-authored only?
