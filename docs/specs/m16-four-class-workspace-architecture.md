# M16 Four-Class iOS Workspace Architecture

Status: implementation-in-progress

## Goal

DreamJotter uses four intentionally different workspace compositions rather than one shared screen with changing padding. All layouts share the same screenplay session, commands, autosave pipeline, package format, and TextKit editor.

## Application shell

The document browser and editor are sibling child controllers inside one root container. Opening a project replaces the browser child with a SwiftUI hosting controller constrained to every edge of the root view. Returning to Documents restores the browser child. The editor is not shown as a sheet or as a child of the folder picker.

This shell is required because a visually correct editor still fails acceptance when it occupies only a centered modal card.

## Runtime classes

- Compact phone: phone width below 390 points.
- Regular phone: phone width at least 390 points.
- Compact iPad: iPad with compact horizontal size class or width below 700 points.
- Regular iPad: iPad with regular horizontal size class and width at least 700 points.

Classification uses width, size class, and interface idiom. Rotation and multitasking can change the active class without replacing the editor session.

## Compact phone workspace

A narrow writing view with no standard navigation stack chrome.

- Custom compact header.
- Documents button on the leading edge.
- One-line project title in the center.
- Editing commands grouped in a trailing menu.
- Edge-to-edge screenplay editor below the header.
- No persistent sidebar, inspector, or bottom toolbar.
- Small floating autocomplete panel.

## Regular phone workspace

A focused writing view with direct access to common actions.

- Inline-title navigation stack.
- Documents, Smart Enter, and Format in the toolbar.
- Lightly separated writing surface with small margins.
- Compact bottom writing bar for high-frequency commands.
- Floating autocomplete above the bottom bar and keyboard.

## Compact iPad workspace

A collapsible two-column workspace.

- NavigationSplitView.
- Project navigator in the sidebar.
- Screenplay editor in the detail column.
- Labeled toolbar commands.
- Medium page margins and bounded readable width.
- Sidebar collapse preserves selection, scroll position, and undo state.

## Regular iPad workspace

A persistent three-column screenplay studio.

- Dedicated top studio command bar.
- Persistent project navigator on the left.
- Center screenplay canvas with the widest readable editor surface.
- Persistent project inspector on the right.
- Autocomplete anchored to the center canvas only.
- Navigator and inspector remain visible in full-screen and broad Stage Manager windows.

## Shared visual rules

- Primary writing surface uses the system background.
- Surrounding workspace uses a secondary system background.
- Compact phone is edge-to-edge.
- Regular phone uses subtle canvas separation.
- Compact iPad uses a centered rounded canvas.
- Regular iPad uses generous canvas separation and persistent supporting columns.
- Every primary control has a minimum 44-point target.
- Long project titles never push commands outside the visible width.

## Editor invariants

- One IOSEditorSession survives layout changes.
- TextKit remains the editor implementation.
- Formatting remains visible-window bounded.
- Undo history survives rotation and resizing.
- Parser refresh and autocomplete preserve selection.
- Autocomplete overlays the editor and does not resize it.
- Keyboard presentation never turns the workspace into a centered card.

## Accessibility

- VoiceOver exposes project title, Documents, Smart Enter, Format, current screenplay element, and selected suggestion.
- Icon-only controls include labels and hints.
- Sidebar and inspector headings define clear landmarks.
- Dynamic Type keeps primary commands reachable.
- Increased Contrast preserves writing-surface and selected-suggestion boundaries.

## Automated regression requirements

Tests verify:

- deterministic classification for all four classes
- four distinct workspace builders remain in source
- regular iPad includes navigator, editor, and inspector regions
- root controller swaps full-window child controllers
- child controllers are constrained to all four root edges
- editor source does not use modal presentation style
- autocomplete remains a bottom-aligned overlay
- readable widths stay bounded

## Visual acceptance matrix

Capture the full simulator or device window for:

1. Compact phone portrait
2. Compact phone with keyboard and autocomplete
3. Regular phone portrait
4. Regular phone landscape
5. Compact iPad split view
6. Compact iPad rotated
7. Regular iPad full screen
8. Regular iPad broad Stage Manager window
9. Light and dark appearance
10. Accessibility Dynamic Type on compact phone and regular iPad

## Acceptance

The slice is accepted when the editor fills the application root window, all four classes are visibly distinct, regular iPad shows persistent navigator and inspector regions, compact phone no longer resembles a compressed tablet window, CI is green, and the visual matrix is approved.
