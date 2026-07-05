# Milestone 16 — iOS Full Feature Parity

Status: implementation-in-progress

## Intent

Deliver a native iPhone and iPad version of DreamJotter with the complete user-facing capability set of the macOS 1.0 application while preserving the portable semantic core, local-first package format, screenplay fidelity, privacy guarantees, and regression discipline.

The iOS application is not a reduced companion. Layout and interaction may adapt to touch, compact width, keyboard availability, and lifecycle constraints, but project semantics and supported workflows must remain compatible with macOS.

## Architecture decisions

- `DreamJotterCore` remains the single source of truth for screenplay semantics, package storage, commands, validation, review, backup, import, and export behavior.
- `DreamJotteriOS` owns adaptive navigation, UIKit/TextKit integration, document-browser integration, scene lifecycle handling, platform sharing, and iOS accessibility.
- iPhone uses a single-pane navigation model. iPad uses a collapsible or persistent sidebar according to available width.
- Editing uses native TextKit through a UIKit bridge rather than SwiftUI `TextEditor` so semantic paragraph formatting, selection restoration, undo grouping, keyboard commands, and long-script performance can match macOS.
- Derived panes must use revision-keyed caches, bounded previews, asynchronous generation, cancellation, and memory-warning eviction.
- `.dreamjotter` remains canonical storage. Files integration must not introduce an alternate database or hidden copy as the source of truth.

## Delivery slices

### M16.1 Foundation and measurable budgets

- Add iOS 17 package support and a dedicated `DreamJotteriOS` module.
- Define the complete desktop-parity capability inventory.
- Define adaptive workspace, editor hydration, cache, debounce, and lifecycle save policies.
- Add policy tests and CI compilation/test coverage.
- Record device performance budgets before building heavy views.

### M16.2 Native document experience

- Create the iOS application target and app lifecycle.
- Integrate `UIDocumentBrowserViewController` or an equivalent document-browser flow for create, open, duplicate, move, rename, delete, and recent packages.
- Register `.dreamjotter` package UTType and document roles.
- Implement coordinated package reads/writes, security-scoped access where required, autosave, background save, external-generation conflict handling, corruption recovery, and restoration.
- Prove macOS-created packages open and round-trip without semantic changes on iOS and vice versa.

### M16.3 TextKit editor parity

- UIKit TextKit editor bridge with semantic paragraph styling.
- Smart Enter, element-kind changes, native undo/redo grouping, normalized paste, semantic copy/cut, find, autocomplete, cursor restoration, and grapheme-safe selection.
- Touch selection, hardware-keyboard commands, dictation, autocorrection policy, input assistant behavior, and compact formatting controls.
- VoiceOver announcements for screenplay element types, suggestions, findings, and formatting warnings.
- Long-script virtualization or visible-window hydration with cancellation-safe parser refresh.

### M16.4 Organization and planning parity

- Scenes, dashboard, character profiles, location profiles, notes, TODOs, statuses, summaries, plotline tags, and planning order.
- iPhone drill-down navigation and iPad split-view workflows.
- Preserve direct navigation from derived panes to exact screenplay locations.
- Avoid regenerating all derived data on every keystroke.

### M16.5 Review, import, export, and sharing parity

- Review findings, health report, filters, and direct script navigation.
- Fountain, text, Markdown, JSON backup, FDX, and production PDF workflows.
- Files destination selection, share sheet, print preview where applicable, restore confirmation, and reveal/open-in-place behavior adapted for iOS.
- Export output must remain byte-equivalent or structurally equivalent to core/macOS output where platform metadata is irrelevant.

### M16.6 Localization, accessibility, diagnostics, and release hardening

- Complete English, `es-MX`, and `es-419` iOS surfaces.
- Dynamic Type, VoiceOver, Switch Control, reduced motion, high contrast, pointer, hardware keyboard, and focus-order validation.
- Privacy statement, onboarding, help, diagnostics export, recovery UI, migration fixtures, and App Store privacy metadata.
- CI simulator builds and tests, device performance evidence, memory-pressure evidence, package round trips, and release acceptance matrix.

## Performance budgets

Initial budgets are regression thresholds, not aspirational averages:

- Editor input handling p95: at most 16 ms excluding OS text-service latency.
- Navigation to an already-derived pane p95: at most 100 ms.
- Initial usable document presentation: at most 750 ms for the standard fixture on the baseline device.
- Background save completion: at most 2 seconds for the standard fixture.
- Editor hydration must remain visible-window bounded for all device classes.
- Compact iPhone derived-view cache: at most two heavy views.
- Memory warning must evict heavy caches down to one retained current view.
- No synchronous PDF, FDX, health-report, dashboard, or full-project parse work on the main actor.

Budgets must be measured on a declared baseline physical device and separately guarded with deterministic structural/performance tests where timing is stable enough for CI.

## Required regression coverage

- Cross-platform package round trip and schema compatibility.
- Empty, representative, Unicode-heavy, and very long screenplay fixtures.
- Save during background transition and interrupted coordinated write.
- External-generation conflict without silent overwrite.
- Undo/redo across Smart Enter, formatting changes, and multi-element edits.
- Cursor and selection stability after parser and autocomplete updates.
- Bounded derived data, cancellation of stale work, and cache eviction under memory pressure.
- Every desktop capability appears exactly once in the iOS parity catalog.
- Every export format has structural equivalence tests shared with macOS/core.

## Human-intervention gates

Implementation should continue without design approval until one of these gates is reached:

1. Selecting and provisioning the final Xcode iOS app target, bundle identifier, signing team, and App Store capabilities.
2. Choosing the minimum supported device set if iOS 17 proves incompatible with product goals.
3. Physical-device TextKit, dictation, hardware-keyboard, Files provider, memory-pressure, and accessibility validation.
4. Visual approval of compact iPhone and regular iPad navigation/toolbar composition.
5. App Store Connect privacy, entitlement, distribution, and TestFlight submission actions.

## Acceptance gates

M16 is accepted only when:

1. All macOS 1.0 user-facing capabilities are represented and implemented on iOS, with documented platform adaptations.
2. macOS and iOS packages round-trip without semantic loss.
3. Automated tests and CI pass for core, macOS, iOS support modules, and the iOS simulator target.
4. Long-script editing remains responsive within the accepted device budgets.
5. Backgrounding, Files coordination, conflicts, recovery, and migrations never silently discard or overwrite user work.
6. VoiceOver, Dynamic Type, hardware keyboard, and touch workflows have completed evidence.
7. Every import/export format passes shared regression fixtures.
8. Physical-device and TestFlight acceptance evidence is recorded.

## Out of scope

- Cloud synchronization or collaboration.
- An iOS-only alternate project format.
- Feature removal solely to simplify compact-width design.
- Rewriting core screenplay behavior in UIKit or SwiftUI.
- Telemetry or content upload without a separate privacy specification.
