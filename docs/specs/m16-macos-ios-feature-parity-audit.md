# M16 macOS-to-iOS Feature Parity Audit

Status: implementation-in-progress

This audit maps the macOS 1.0 workspace and document workflows to their native iPhone/iPad equivalents. A destination is not considered complete merely because it appears in navigation; its core mutations, persistence, direct navigation, and performance behavior must also be present.

## Workspace parity

| macOS capability | iOS adaptation | Status |
| --- | --- | --- |
| Dashboard title, logline, synopsis, project metrics | Adaptive form with explicit save and project metrics | Implemented |
| Script/TextKit editing | Native UIKit TextKit editor with adaptive phone/iPad layouts | Implemented; acceptance ongoing |
| Scene list and search | Searchable scene-card list with status filtering | Implemented |
| Scene summary, note, status, tags editing | Touch editor for scene cards | Pending |
| Apply planning order to screenplay | Confirmation workflow with snapshot-preserving core reorder | Pending |
| Open scene directly in screenplay | Switch pane and restore exact screenplay selection | Pending |
| Character profile create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Detected character convert/ignore | In-pane actions using CharacterManager | Implemented |
| Location profile create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Detected location convert/ignore | In-pane actions using LocationManager | Implemented |
| Note create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Note resolve/reopen and status filter | Swipe resolve/reopen plus segmented status filtering | Implemented |
| Note target selection and linked-target navigation | Touch target picker and direct destination navigation | Pending |
| Review screenplay preview | Read-only monospaced Fountain preview | Implemented |
| Review finding search | Native searchable findings list | Implemented |
| Review severity and source filters | Compact filter controls | Pending |
| Review direct script navigation | Finding script-range selection in TextKit | Implemented where a script range exists; linked-entity fallback pending |
| Review layout numbering preview | Touch-adapted numbered preview | Pending |
| Health report overview | Counts, ratio, longest scenes, no-dialogue scenes, formatting warnings | Implemented |

## Document and sharing parity

| macOS capability | iOS adaptation | Status |
| --- | --- | --- |
| Open/create project packages | UIDocumentBrowser open-in-place workflow | Implemented |
| Autosave/background save/conflict checks | Coordinated package adapter and generation checks | Implemented; acceptance ongoing |
| Fountain export | Files destination and share sheet | Pending |
| Text and Markdown export | Files destination and share sheet | Pending |
| JSON backup and restore | Files import/export plus destructive restore confirmation | Pending |
| FDX export | Files destination and share sheet | Pending |
| Production PDF export | Share sheet, Files destination, and print preview | Pending |
| Save As / duplicate / rename / move / delete | Native document-browser actions | Partial; browser acceptance pending |

## Cross-cutting parity

| macOS capability | iOS adaptation | Status |
| --- | --- | --- |
| English, es-MX, es-419 | Localized iOS strings and runtime language behavior | Pending completion |
| App language relaunch | AppKit implementation isolated from non-macOS builds | Implemented |
| VoiceOver and Dynamic Type | Native labels, element announcements, scalable controls | Partial; evidence pending |
| Diagnostics and support export | Native share workflow | Pending |
| Long-project derived-data performance | Revision-keyed async caches and cancellation | Partial; scene/review/health panes require final async audit |

## Immediate acceptance rules

- Create actions must be visible inside compact and regular pane content; they cannot depend only on an inherited toolbar.
- Review must render the screenplay as well as findings.
- Dashboard, Screenplay, Scenes, Characters, Locations, Notes, Review, and Health Report must all be reachable on iPhone and iPad.
- AppKit files must be protected from non-macOS compilation.
- Pending rows remain release blockers for M16 acceptance and must not be described as complete.
