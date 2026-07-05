# M16 macOS-to-iOS Feature Parity Audit

Status: closure-in-progress

This audit maps the macOS 1.0 workspace and document workflows to their native iPhone/iPad equivalents. A destination is not complete merely because it appears in navigation; its mutations, persistence, navigation, performance, localization, accessibility, and acceptance evidence must also be present.

No remaining row in this document may be deferred before PR #19 is merged. Work is implemented in the dependency order below so later navigation and sharing workflows build on stable project targets.

## Closure execution order

1. Scene-card editing, scene navigation, and snapshot-preserving planning-order application.
2. Note target selection and linked-target navigation.
3. Review severity/source filters, linked-entity navigation, and numbered-layout preview.
4. Fountain, plain text, Markdown, JSON backup/restore, FDX, PDF, Files, share, and print workflows.
5. Document-browser create, duplicate, rename, move, delete, Save As, and conflict/recovery acceptance.
6. English/es-MX/es-419 localization, diagnostics/support export, VoiceOver, Dynamic Type, performance, and physical-device evidence.

## Workspace parity

| macOS capability | iOS adaptation | Status |
| --- | --- | --- |
| Dashboard title, logline, synopsis, project metrics | Adaptive form with explicit save and project metrics | Implemented |
| Script/TextKit editing | Native UIKit TextKit editor with adaptive phone/iPad layouts | Implemented; acceptance ongoing |
| Scene list and search | Searchable scene-card list with status filtering | Implemented |
| Scene summary, note, status, tags editing | Touch editor for scene cards | In implementation |
| Apply planning order to screenplay | Confirmation workflow with automatic snapshot and deterministic core reorder | In implementation |
| Open scene directly in screenplay | Switch pane and restore exact screenplay selection | In implementation |
| Character profile create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Detected character convert/ignore | In-pane actions using CharacterManager | Implemented |
| Location profile create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Detected location convert/ignore | In-pane actions using LocationManager | Implemented |
| Note create/edit/delete | Visible in-pane create row, editor sheet, swipe delete | Implemented |
| Note resolve/reopen and status filter | Swipe resolve/reopen plus segmented status filtering | Implemented |
| Note target selection and linked-target navigation | Touch target picker and direct destination navigation | Pending |
| Review screenplay preview | Read-only native TextKit Fountain preview | Implemented |
| Review finding search | Native searchable findings list | Implemented |
| Review severity and source filters | Compact filter controls | Pending |
| Review direct script navigation | Finding script-range selection plus linked-entity fallback | Partial |
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
| Save As / duplicate / rename / move / delete | Native document-browser actions | Partial; implementation and browser acceptance pending |

## Cross-cutting parity

| macOS capability | iOS adaptation | Status |
| --- | --- | --- |
| English, es-MX, es-419 | Localized iOS strings and runtime language behavior | Pending completion |
| App language relaunch | AppKit implementation isolated from non-macOS builds | Implemented |
| VoiceOver and Dynamic Type | Native labels, element announcements, scalable controls | Partial; evidence pending |
| Diagnostics and support export | Native share workflow | Pending |
| Long-project derived-data performance | Revision-keyed async caches and cancellation | Partial; scene/review/health/export panes require final audit |
| Physical-device evidence | iPhone 14 Plus baseline plus current iPhone/iPad evidence matrix | Pending |

## Required automated evidence

- Core tests for scene-card mutation and planning reorder, including snapshot creation and no-loss round trip.
- Core tests for note links and linked-target resolution.
- Review filter and numbered-preview tests.
- Export content and filename tests for every format.
- JSON backup restore round trip on iOS adapter.
- Document-browser source and UI smoke coverage.
- Localization resource validation for English, es-MX, and es-419.
- Accessibility source tests and UI evidence.
- Long-script performance tests for editor, review, scene, health, and export generation.

## Required human evidence

- iPhone portrait and landscape.
- iPad regular full-screen and compact split view.
- Light and dark appearance.
- Large Dynamic Type and VoiceOver.
- Files local storage, iCloud Drive, and one third-party provider where available.
- Physical iPhone 14 Plus or equivalent baseline, plus current-device screenshots.
- Export open/share/print verification for every supported format.
- Background, reopen, conflict, duplicate, rename, move, and delete verification.

## Immediate acceptance rules

- Create actions must remain visible inside compact and regular pane content.
- Review must render the screenplay as the primary surface and expose findings without shrinking the screenplay unusably.
- Dashboard, Screenplay, Scenes, Characters, Locations, Notes, Review, Health Report, and Export must be reachable on iPhone and iPad.
- AppKit files must be protected from non-macOS compilation.
- No pending or partial row may be marked accepted or removed without test or human evidence.
- PR #19 remains draft until this audit contains no Pending, Partial, In implementation, or acceptance-ongoing rows.
