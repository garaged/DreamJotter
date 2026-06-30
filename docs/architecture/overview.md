# Architecture Overview

DreamJotter will be Apple-native first with a portable core. This means Apple UI can use platform-native frameworks, while domain behavior remains independent from those frameworks.

## Layers

| Layer | Responsibility | Constraint |
| --- | --- | --- |
| Apple App | macOS, iPadOS, and iOS user experience | May use SwiftUI, AppKit, UIKit, and TextKit as appropriate |
| Portable Core | Screenplay model, commands, routines, storage contracts, export behavior, validation, AI abstractions | Must not depend on UI frameworks |
| Project Format | Local-first `.dreamjotter` document package | Canonical source of truth |
| App Metadata | Recents, cache, search index, window state, convenience metadata | May use SwiftData later, but not as canonical storage |

## Screenplay Model

The screenplay model must be semantic. A document is not just rich text. The model should represent elements such as scenes, action, character cues, dialogue, parentheticals, transitions, notes, title page data, and future revision metadata.

Rendering, editing, export, and automation should operate from semantic data. Formatting spans may exist as presentation details, but they must not replace screenplay structure.

## Storage Direction

The `.dreamjotter` package is the canonical project format. It should be local-first, inspectable where practical, versionable where practical, and portable across future platforms.

SwiftData may be introduced later for Apple app convenience data such as indexing, caching, or recents. It must not become the source of truth for screenplay content.

## Feature Sequencing

MVP architecture should be shaped by:

1. Semantic document model.
2. Local-first `.dreamjotter` package.
3. Explicit command system.
4. Routines built from commands.
5. Plugin APIs after command and routine surfaces mature.

Plugins must not drive MVP architecture.
