# Milestone 15 — Mac 1.0 Release Readiness

Status: implementation-ready

## Intent

Prepare the existing macOS application for a trustworthy 1.0 release without adding new screenplay-domain behavior. Work in this milestone should harden presentation, recovery, diagnostics, packaging, automation, and release evidence.

## Release principles

- Release work must not change canonical screenplay semantics.
- Failure paths must preserve user data and offer an understandable next action.
- Shipping evidence must be reproducible from repository automation.
- Accessibility, keyboard behavior, migration, and long-script performance are release gates rather than optional polish.
- Signing and notarization credentials must remain outside the repository.

## Capability slices

### M15.1 Branding, help, and trust

- Final app icon and consistent product naming.
- Native About presentation with version/build details.
- Bundled privacy statement describing local-first storage and exported diagnostics.
- First-run onboarding and discoverable Help content.
- Release notes surfaced from a maintained repository document.

### M15.2 Failure handling and recovery

- Crash-safe, non-recursive error presentation.
- Package corruption recovery that never overwrites the damaged package implicitly.
- Recovery choices: open read-only information, restore from a selected backup, export diagnostics, or cancel.
- Support diagnostics export with explicit user review and no screenplay text by default.
- Migration tests across every supported schema transition and explicit rejection of unsupported future schemas.

### M15.3 Mac interaction completeness

- Keyboard shortcut inventory with conflict review.
- Complete File, Edit, View, Format, Window, and Help menu coverage for supported commands.
- Accessibility audit for labels, values, focus order, keyboard-only operation, reduced motion, and VoiceOver announcements.

### M15.4 Performance and QA evidence

- Automated long-script performance fixtures with documented budgets.
- Manual QA matrix covering supported macOS versions, Apple Silicon, Intel, localization, package recovery, migration, export, accessibility, and keyboard workflows.
- Failed CI runs publish logs and test result artifacts.

### M15.5 Build, signing, and distribution

- Deterministic release build configuration.
- Universal application bundle validation.
- Developer ID signing, hardened runtime, notarization, stapling, and Gatekeeper verification.
- CI gates: `spec-check`, `spec-trace`, `swift test`, `DreamJotterMac` release build, localization validation, shell syntax validation, and package round-trip fixtures.
- Secrets are referenced by environment variable or GitHub Actions secret only.

## Required automated checks

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
python3 scripts/localization-check
swift test
swift build --configuration release --product DreamJotterMac
bash -n scripts/build-universal-macos
bash -n scripts/package-first-tester-macos
bash -n scripts/package-release.sh
```

Package round-trip tests must prove that a representative `.dreamjotter` fixture can be opened, saved, reopened, and compared semantically without loss.

## Acceptance gates

M15 is accepted only when:

1. Every scope item has automated or documented manual evidence.
2. CI passes from a clean checkout on the supported GitHub-hosted macOS runner.
3. Failed CI attempts retain useful logs and test artifacts.
4. A universal release bundle is signed, notarized, stapled, and passes `spctl` assessment.
5. Migration fixtures cover all supported historical schema versions.
6. Corrupt packages are never modified during diagnosis or recovery selection.
7. Diagnostics export is inspectable and excludes screenplay content by default.
8. The manual QA matrix is completed for the release candidate.
9. Release notes and privacy/help content match the shipped build.

## Out of scope

- New screenplay element types.
- Cloud synchronization.
- Telemetry or crash upload without a separate privacy decision.
- Automatic repair that rewrites a damaged package without explicit user confirmation and backup.
- New automation/plugin capabilities.