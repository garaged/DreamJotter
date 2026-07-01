# Milestone 5: Apple App Shell / Usable Vertical Slice

## Goal

Create the first launchable macOS DreamJotter app shell while preserving the portable-core architecture established in Milestones 1 through 4.

Milestone 5 is Apple-specific at the app boundary only. SwiftUI views and macOS file panels live outside `DreamJotterCore`. Core parsing, storage, Fountain export, dashboard derivation, and health reporting continue to use portable package APIs.

## Scope

- macOS SwiftUI app entry point.
- Project Library screen.
- Blank project creation.
- Project title entry and later title editing.
- TextKit/AppKit screenplay editor foundation using `NSTextView`.
- SwiftUI `TextEditor` fallback during the editor transition.
- Live and explicit screenplay parse refresh using existing parser core.
- Scene and character lists derived from parsed screenplay text.
- Dashboard summary for title, logline, synopsis, scenes, characters, and notes.
- Editable project logline and synopsis stored in existing story-development records.
- Project notes with project links by default and first-scene links when a parsed scene exists.
- `.dreamjotter` package save and open using existing storage code.
- Fountain export using existing export code.
- Script health report using existing analysis code.
- Simple error presentation for load, save, and export failures.
- View-model tests for app-support logic that does not require launching UI.

## Non-Goals

- No TextKit/AppKit editor adapter.
- No iPadOS or iOS app shell.
- No SwiftData canonical storage.
- No iCloud or sync.
- No plugin runtime.
- No external AI services.
- No fragile UI automation tests.
- No production-grade screenplay pagination or PDF rendering.

## Architecture Rules

- `DreamJotterCore` remains platform-neutral.
- SwiftUI and AppKit imports are allowed only in the macOS app target.
- Business behavior stays in portable core or thin app view models.
- `.dreamjotter` remains canonical project storage.
- SwiftUI `TextEditor` is temporary and does not become the canonical model.
- TextKit/AppKit editor work remains deferred to a later milestone.

## Implemented Target Shape

- `DreamJotterMac` SwiftPM executable target provides the macOS app shell.
- `DreamJotterMacTests` covers view-model behavior without launching UI.
- Xcode can generate a runnable `DreamJotterMac` scheme from `Package.swift`.
- `TextKitScreenplayEditorView` provides the first macOS `NSTextView` adapter while preserving the same document view-model binding as the fallback editor.

## Acceptance Summary

- App launches as a real macOS app window from the `DreamJotterMac` scheme.
- User can create a blank project.
- User can enter and edit the project title, logline, and synopsis.
- User can type screenplay text into the temporary editor.
- User can switch between TextKit and SwiftUI fallback editor surfaces.
- Parsed scene and character data update from the screenplay text.
- User can add a note linked to the project or first parsed scene.
- Dashboard updates from portable core state.
- User can save and reopen `.dreamjotter` packages.
- User can export Fountain text.
- Health report is visible.
- Existing executable specs and package tests continue passing.
