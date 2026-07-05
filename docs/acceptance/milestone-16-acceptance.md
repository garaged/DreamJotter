# Milestone 16 — iOS Full Feature Parity Acceptance

Status: in progress

## Automated evidence

| Area | Evidence | Status |
| --- | --- | --- |
| iOS package platform | `Package.swift` declares iOS 17 and `DreamJotteriOS` | Implemented |
| Feature parity inventory | `IOSFeatureParityCatalog` uniqueness/completeness tests | Implemented |
| Adaptive performance policy | iPhone/iPad bounded cache and visible-window hydration tests | Implemented |
| Lifecycle save policy | active autosave and background-save decision tests | Implemented |
| Native iOS app target | Simulator build and launch tests | Pending |
| Document browser | package creation/open/save/rename/move/delete tests | Pending |
| Cross-platform package compatibility | shared package round-trip fixtures | Pending |
| TextKit editor parity | editor command, undo, selection, paste, autocomplete tests | Pending |
| Long-script performance | structural budgets plus physical-device measurements | Pending |
| Organization workflows | scene/character/location/note/TODO regression tests | Pending |
| Review and health | shared finding/navigation fixtures | Pending |
| Export parity | shared Fountain/text/Markdown/JSON/FDX/PDF fixtures | Pending |
| Localization | iOS English, es-MX, and es-419 resource validation | Pending |
| Accessibility | identifiers plus manual VoiceOver/Dynamic Type matrix | Pending |
| Recovery and diagnostics | corruption/conflict/privacy-filter tests | Pending |

## Manual evidence required

- [ ] Compact iPhone visual and interaction approval.
- [ ] Regular iPhone visual and interaction approval.
- [ ] Compact iPad split-view approval.
- [ ] Regular iPad split-view and keyboard approval.
- [ ] Physical-device long-script typing and scrolling measurements.
- [ ] Hardware keyboard command and focus-order validation.
- [ ] Dictation, autocorrection, selection handles, copy/paste, and input assistant validation.
- [ ] VoiceOver screenplay semantics and warning announcements.
- [ ] Files providers: local, iCloud Drive, and at least one third-party provider.
- [ ] Background save, forced termination, low-storage, and memory-warning exercises.
- [ ] macOS-to-iOS and iOS-to-macOS package round trips.
- [ ] Production PDF visual comparison and share/print workflow.
- [ ] TestFlight installation, migration, privacy, and clean-device validation.

## Performance evidence

Record the baseline device, OS version, fixture revision, build configuration, measurement tool, sample count, median, p95, and maximum for each accepted budget. Simulator measurements are diagnostic only and cannot close physical-device gates.

| Budget | Baseline | Result | Status |
| --- | --- | --- | --- |
| Editor input p95 ≤ 16 ms | Not selected | — | Pending |
| Cached-pane navigation p95 ≤ 100 ms | Not selected | — | Pending |
| Standard document usable ≤ 750 ms | Not selected | — | Pending |
| Standard background save ≤ 2 s | Not selected | — | Pending |
| Memory warning leaves ≤ 1 heavy cached view | Not selected | — | Pending |

## Human intervention currently required

The next unavoidable gate is creation/provisioning of the final Xcode iOS application target, including bundle identifier, signing team, application groups or iCloud entitlements if chosen, icon catalog, and simulator/device scheme. Repository implementation may continue around platform-neutral policies and shared fixtures, but a launchable signed app cannot be accepted without this configuration and physical-device evidence.
