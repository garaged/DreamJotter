# M16 Adaptive iPhone and iPad Workspace Redesign

Status: implementation-in-progress

## Intent

Redesign the native iOS workspace so DreamJotter feels deliberately composed on iPhone and iPad rather than presenting a desktop or tablet layout compressed into compact width. The redesign preserves screenplay semantics, document compatibility, editor behavior, accessibility, and performance constraints while adapting navigation, chrome, typography, spacing, controls, suggestions, and secondary information to each device class.

## Supported layout classes

DreamJotter defines four explicit adaptive classes:

- **Compact phone**: narrow portrait or split-screen phone width below 390 points.
- **Regular phone**: phone width of at least 390 points.
- **Compact iPad**: iPad in narrow split view or compact horizontal size class.
- **Regular iPad**: full-width or broad split-view iPad workspace.

Runtime classification must use available width and horizontal size class. Device model names must not drive layout behavior.

## Visual principles

1. The screenplay remains the dominant surface.
2. Navigation chrome must never consume more vertical space than necessary.
3. Primary editing commands remain reachable without text labels crowding compact toolbars.
4. Secondary tools appear progressively: hidden behind menus on phone, collapsible on compact iPad, persistent on regular iPad.
5. Autocomplete overlays the editor and must not permanently reduce editor height.
6. Text remains readable at all Dynamic Type sizes without horizontal clipping.
7. Touch targets are at least 44 by 44 points.
8. Safe areas, keyboard avoidance, rotation, multitasking, pointer, and hardware keyboard behavior are first-class constraints.

## Phone composition

- Single-pane `NavigationStack`.
- Inline project title with one-line truncation and accessibility value exposing the full title.
- Leading back-to-documents action.
- Compact icon-only Smart Enter and Format actions with labels for VoiceOver.
- Editor uses the full width minus class-specific readable margins.
- Autocomplete appears as a floating bottom card with horizontally scrollable suggestions.
- Hardware-keyboard instructions are omitted from compact visual chrome but remain discoverable through accessibility help.
- Secondary project navigation is exposed through a compact menu rather than a persistent sidebar.

## iPad composition

- Regular iPad uses `NavigationSplitView` with a persistent or user-collapsible sidebar and an editor detail column.
- Compact iPad collapses the sidebar automatically and preserves the editor as the primary destination.
- Sidebar width is bounded and contains project identity plus navigation destinations; it must not cause the screenplay column to exceed the readable maximum width.
- Editor content is centered within a bounded readable column while the surrounding canvas absorbs extra width.
- Toolbar actions may include labels when sufficient width exists.
- Autocomplete remains anchored to the editor detail column rather than the full screen.

## Adaptive metrics

The layout policy owns these values per class:

- navigation mode
- title display mode
- horizontal editor inset
- maximum readable editor width
- autocomplete presentation
- autocomplete maximum width
- whether keyboard help is visually shown
- whether command labels are visible
- preferred sidebar width

No view may hard-code competing device-specific values outside this policy unless required by a platform API.

## Editor requirements

- The visible TextKit viewport must remain stable across rotation, sidebar changes, suggestion presentation, parser refresh, and Dynamic Type changes.
- Selection and first responder state must survive adaptive layout transitions.
- Large scripts must not trigger complete-document styling when width changes.
- Formatting visuals must preserve semantic differentiation without relying on color alone.
- The editor background, page/canvas treatment, and margins must remain legible in light and dark appearance.

## Autocomplete requirements

- Suggestions never become a permanent `VStack` sibling that reduces editor height.
- Compact layouts use a short floating card with close control and horizontal suggestion chips.
- Regular iPad may show keyboard guidance and a wider bounded card.
- The selected suggestion remains visible when navigating by hardware keyboard.
- The panel respects the keyboard and bottom safe area.

## Accessibility requirements

- Full project title is available to VoiceOver even when visually truncated.
- Icon-only commands have labels, hints, and 44-point hit regions.
- Sidebar selection, current screenplay element, formatting actions, and suggestions expose state.
- Dynamic Type through accessibility sizes must not clip toolbar controls or prevent screenplay editing.
- Reduced Motion replaces panel movement with opacity-only transitions.
- High Contrast and Differentiate Without Color preserve selected-suggestion visibility.

## Regression coverage

Automated coverage must prove:

- width and size-class inputs map deterministically to the four layout classes
- phone classes use single-pane navigation and floating autocomplete
- regular iPad uses split navigation and a bounded readable editor column
- compact classes hide verbose command labels and keyboard help
- all metrics remain positive, bounded, and ordered from compact to spacious layouts
- source-level app tests guard against restoring large navigation titles or placing autocomplete as a permanent vertical sibling

## Acceptance scenarios

1. iPhone portrait opens a long script with an inline title, full-height editor, compact toolbar, and floating suggestions.
2. iPhone landscape retains editing focus and does not clip toolbar actions.
3. iPad full screen shows a sidebar and centered readable screenplay column.
4. iPad split view collapses navigation without losing selection or editor state.
5. Showing and dismissing autocomplete does not resize the TextKit editor viewport.
6. Dynamic Type accessibility sizes keep all primary commands reachable.
7. VoiceOver can identify the project, current element type, Smart Enter, Format, suggestion selection, and return-to-documents action.
8. Existing long-script performance and autosave budgets remain satisfied.

## Out of scope

- Changing screenplay semantics or the `.dreamjotter` format.
- Replacing TextKit with a different editor stack.
- Adding new organization, review, or export features solely for visual completeness.
- Device-model-specific branches.
