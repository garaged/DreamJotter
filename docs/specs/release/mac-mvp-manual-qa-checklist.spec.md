# Mac MVP Manual QA Checklist Spec

Status: specified
Milestone: 9.5
Traceability ID: MAC-MVP-MANUAL-QA-CHECKLIST

## User Goal

Before release readiness work is accepted, a human tester can follow a checklist that covers the Mac MVP’s critical writer workflows.

## Scope

- App launch.
- Project creation, writing, save, reopen.
- TextKit editor typing, Smart Enter, Tab cycling.
- Scene navigation.
- Character/location detection and conversion.
- Notes and TODOs.
- Dashboard and Review Mode.
- Health findings.
- Export formats and backup/restore.
- Dirty state and recent projects.

## Manual QA Checklist

| Area | Check | Expected Result |
| --- | --- | --- |
| Launch | Open `DreamJotterMac`. | Project Library appears without crash. |
| New Project | Create a blank project. | Workspace opens with default title and clean unsaved state. |
| Writing | Type `INT. ROOM - DAY` and dialogue. | Text appears and scene list updates. |
| Save | Save as `.dreamjotter`. | Package is created and dirty state clears. |
| Reopen | Open saved package. | Script, scenes, metadata, notes, and profiles reload. |
| TextKit Typing | Type in TextKit editor. | Keyboard input reaches editor and updates project text. |
| Smart Enter | Press Enter after scene heading and character cue. | Next-line behavior follows editor rules. |
| Tab Cycling | Press Tab on a line. | Element-kind cycling preserves text. |
| Scene Navigation | Click a scene. | Editor navigates to scene when practical. |
| Characters | Type a new character cue and convert detection. | Character profile is created and unresolved count updates. |
| Locations | Type a scene heading and convert detected location. | Location profile is created and unresolved count updates. |
| Notes | Add project/scene note. | Note appears and marks project dirty. |
| TODO | Type `[[TODO: improve this dialogue]]`. | TODO appears as derived note/finding. |
| Dashboard | Open Dashboard. | Counts reflect scenes, profiles, unresolved items, and notes. |
| Review Mode | Open Review. | Read-only preview and findings appear. |
| Health | Inspect findings. | Unresolved/formatting/TODO findings are understandable. |
| Fountain Export | Export Fountain. | Fountain file is produced and dirty state is unchanged. |
| PDF Export | Export Reader PDF. | Basic readable PDF is produced. |
| Markdown Export | Export Markdown. | Readable Markdown file is produced. |
| Plain Text Export | Export Plain Text. | Plain script text is produced. |
| Backup | Create JSON backup. | Backup artifact is produced with success feedback. |
| Restore | Restore valid backup. | Restored project opens after safe workflow. |
| Failed Export | Export to invalid path if practical. | Friendly error appears and current project remains safe. |
| Canceled Export | Cancel export destination. | No error; dirty state unchanged. |
| Dirty After Export | Export dirty project. | Project remains dirty. |
| Dirty Close | Close/replace dirty project. | Save / Discard / Cancel protection appears. |
| Recent Projects | Save/open project. | Recent project appears and can reopen. |

## Acceptance Criteria

- Given release readiness planning begins, then this checklist exists.
- Given a tester follows the checklist, then each expected result is observable or logged as a defect.

## Data Model Implications

None.

## Storage Implications

Checklist verifies `.dreamjotter` package and backup artifacts but does not change storage contracts.

## Testability Notes

Manual QA complements executable specs and does not replace them.

## Open Questions

- Which OS versions must be manually certified before a public build?
