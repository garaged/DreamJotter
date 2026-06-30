# Apple Native First

DreamJotter prioritizes a native Apple experience before other platforms.

## Platform Order

1. macOS.
2. iPadOS and iOS.
3. Linux, Windows, and Android later.

## Expected Apple Direction

The Apple app may use:

- Swift and SwiftUI for app structure and general UI.
- AppKit, UIKit, and TextKit wrappers later for the serious screenplay editor.
- Apple document APIs where they help present and manage local `.dreamjotter` packages.
- SwiftData later for app metadata, cache, and search indexing only.

## Boundaries

Apple-native does not mean Apple-only core. UI and platform adapters should remain outside the portable domain model and storage contracts.

The first UI should feel excellent on Mac, iPad, and iPhone, but project data should remain portable and local-first.

## MVP Constraint

Do not create app UI, an Xcode project, or a Swift package until a later prompt explicitly asks for implementation scaffolding.
