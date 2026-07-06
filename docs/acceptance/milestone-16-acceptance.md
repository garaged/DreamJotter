# Milestone 16 — iOS Full Feature Parity Acceptance

Status: in progress

## Resolved configuration

| Decision | Value | Status |
| --- | --- | --- |
| Bundle identifier | `org.garaged.DreamJotter` | Accepted |
| Document UTType | `org.garaged.dreamjotter.project` | Accepted |
| iCloud container | `iCloud.org.garaged.DreamJotter` | Accepted |
| Deployment target | iOS/iPadOS 26.0 | Accepted |
| Current-device design target | iPhone 17 family | Accepted |
| Performance baseline | iPhone 14 Plus | Accepted |
| Storage | Local Files, iCloud Drive, open in place | Accepted |
| Signing configuration | Automatic; team ID supplied outside source control | Accepted |
| Icon source | Adapt `docs/icon-v1.png` into opaque 1024px iOS master | In progress |

## Automated evidence

| Area | Evidence | Status |
| --- | --- | --- |
| Reusable iOS module | `Package.swift` and `DreamJotteriOS` | Implemented |
| iOS 26 application definition | `project.yml` deployment target and scheme | Implemented; build pending |
| Product configuration | `IOSProductConfiguration` and tests | Implemented |
| Files and iCloud registration | Info plist and iCloud Documents entitlements | Implemented; provisioning pending |
| Feature parity inventory | `IOSFeatureParityCatalog` uniqueness/completeness tests | Implemented |
| Adaptive performance policy | iPhone/iPad bounded cache and visible-window hydration tests | Implemented |
| Lifecycle save policy | active autosave and background-save decision tests | Implemented |
| Native document browser shell | `UIDocumentBrowserViewController` host | Implemented; canonical create/open adapter pending |
| Deterministic iOS icon generation | `scripts/generate-ios-app-icon` and asset catalog | Implemented; visual/opacity validation pending |
| Simulator build and launch | Generated Xcode project and iOS 26 simulator | Pending |
| Document browser workflow | package create/open/save/rename/move/delete tests | Pending |
| Cross-platform package compatibility | shared package round-trip fixtures | Pending |
| TextKit editor parity | editor command, undo, selection, paste, autocomplete tests | Pending |
| Long-script performance | structural budgets plus iPhone 14 Plus measurements | Pending |
| Organization workflows | scene/character/location/note/TODO regression tests | Pending |
| Review and health | shared finding/navigation fixtures | Pending |
| Export parity | shared Fountain/text/Markdown/JSON/FDX/PDF fixtures | Pending |
| Localization | iOS English, es-MX, and es-419 resource validation | Pending |
| Accessibility | identifiers plus manual VoiceOver/Dynamic Type matrix | Pending |
| Recovery and diagnostics | corruption/conflict/privacy-filter tests | Pending |

## Manual evidence required

- [ ] iPhone 17-family visual and interaction approval.
- [ ] iPhone 14 Plus visual, interaction, and performance validation.
- [ ] Compact iPad split-view approval.
- [ ] Regular iPad split-view and keyboard approval.
- [ ] Physical-device long-script typing and scrolling measurements on iPhone 14 Plus.
- [ ] Hardware keyboard command and focus-order validation.
- [ ] Dictation, autocorrection, selection handles, copy/paste, and input assistant validation.
- [ ] VoiceOver screenplay semantics and warning announcements.
- [ ] Files providers: local, iCloud Drive, and at least one third-party provider.
- [ ] Background save, forced termination, low-storage, and memory-warning exercises.
- [ ] macOS-to-iOS and iOS-to-macOS package round trips.
- [ ] Production PDF visual comparison and share/print workflow.
- [ ] Generated iOS icon inspected for opaque background, safe margins, and no precomposed corner mask.
- [ ] TestFlight installation, migration, privacy, and clean-device validation.

## Performance evidence

Record the tested iPhone 14 Plus OS version, fixture revision, release build identifier, measurement tool, sample count, median, p95, and maximum. Simulator measurements are diagnostic only.

| Budget | Baseline | Result | Status |
| --- | --- | --- | --- |
| Editor input p95 ≤ 16 ms | iPhone 14 Plus | — | Pending |
| Cached-pane navigation p95 ≤ 100 ms | iPhone 14 Plus | — | Pending |
| Standard document usable ≤ 750 ms | iPhone 14 Plus | — | Pending |
| Standard background save ≤ 2 s | iPhone 14 Plus | — | Pending |
| Memory warning leaves ≤ 1 heavy cached view | iPhone 14 Plus | — | Pending |

## Human intervention currently required

Repository-level identifiers, target version, Files/iCloud configuration, icon pipeline, scheme definition, and performance baseline are resolved. The remaining provisioning gate requires selecting the Apple Developer team in Xcode and registering `org.garaged.DreamJotter` plus `iCloud.org.garaged.DreamJotter` in the Apple Developer account. App Store distribution still requires a signed archive even though the app is delivered through Apple rather than directly distributed.
