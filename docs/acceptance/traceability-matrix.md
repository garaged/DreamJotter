# Traceability Matrix

| ID | Requirement Or Decision | Source | Milestone | Acceptance Direction | Status |
| --- | --- | --- | --- | --- | --- |
| R-001 | DreamJotter is a screenplay app for non-programmers with optional pro customization. | `docs/vision/product-vision.md` | M0-M4 | Beginner workflows remain available without technical configuration; Pro Mode adds optional specialized controls. | Drafted |
| R-002 | Complexity progresses through Simple Mode and Pro Mode. | `docs/vision/product-principles.md` | M1-M4 | Specs identify mode-specific behavior where behavior differs. | Drafted |
| R-003 | The screenplay model is semantic, not rich-text-only. | `docs/architecture/overview.md` | M1-M4 | Screenplay elements are represented by typed meaning before rendering/export concerns. | Drafted |
| R-004 | The canonical project format is `.dreamjotter`. | `docs/adr/0002-local-first-dreamjotter-package.md` | M1-M4 | Project content can be reconstructed from the `.dreamjotter` package without SwiftData. | Accepted |
| R-005 | SwiftData is not canonical project storage. | `docs/adr/0002-local-first-dreamjotter-package.md` | M1-M4 | Any SwiftData use is derived metadata, cache, recents, or indexing only. | Accepted |
| R-006 | Apple UI is native first, while the core remains portable. | `docs/adr/0001-apple-native-first-portable-core.md` | M0-M4 | Core specs avoid SwiftUI, AppKit, UIKit, and TextKit dependencies. | Accepted |
| R-007 | Commands come before routines, and routines come before plugins. | `docs/adr/0003-commands-before-routines-before-plugins.md` | M2-M4 | MVP specs define built-in command semantics before routine or plugin extension points. | Accepted |
| R-008 | Plugins are future work and must not drive MVP architecture. | `docs/adr/0003-commands-before-routines-before-plugins.md` | M0-M4 | No plugin runtime or plugin-first abstractions are introduced during MVP scaffolding. | Accepted |
| R-009 | Specs are the source of truth for implementation. | `CONTRIBUTING.md` | M0-M4 | Implementation changes reference current specs and update acceptance criteria when behavior changes. | Drafted |
