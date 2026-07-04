# Milestone 15 Acceptance — Mac 1.0 Release Readiness

Status: pending

## Automated evidence

| Area | Required evidence | Status |
|---|---|---|
| Specification integrity | `python3 scripts/spec-check` | Pending |
| Traceability | `python3 scripts/spec-trace` | Pending |
| Core and app tests | `swift test` | Pending |
| Release compilation | `swift build --configuration release --product DreamJotterMac` | Pending |
| Localization | `python3 scripts/localization-check` | Pending |
| Packaging scripts | `bash -n` for universal, tester, and release scripts | Pending |
| Package persistence | Round-trip fixtures across supported schema versions | Pending |
| Corruption safety | Tests prove source package remains unchanged | Pending |
| Diagnostics privacy | Tests prove screenplay content is excluded by default | Pending |
| Long-script performance | Fixture timings remain within documented budgets | Pending |
| CI artifacts | Failed runs upload logs and test output | Pending |

## Manual QA matrix

Record the tested build SHA, application version, macOS version, architecture, locale, and tester for every row.

| Scenario | Apple Silicon | Intel | English | Spanish | Result / evidence |
|---|---:|---:|---:|---:|---|
| Fresh install and first launch | ☐ | ☐ | ☐ | ☐ | |
| About, Help, privacy, and onboarding | ☐ | ☐ | ☐ | ☐ | |
| Create, edit, save, quit, and reopen | ☐ | ☐ | ☐ | ☐ | |
| Finder double-click and Open With | ☐ | ☐ | ☐ | ☐ | |
| Keyboard-only screenplay workflow | ☐ | ☐ | ☐ | ☐ | |
| VoiceOver primary workflow | ☐ | ☐ | ☐ | ☐ | |
| Long screenplay open/edit/save/export | ☐ | ☐ | ☐ | ☐ | |
| Corrupt package recovery choices | ☐ | ☐ | ☐ | ☐ | |
| Historical schema migration | ☐ | ☐ | ☐ | ☐ | |
| Unsupported future schema rejection | ☐ | ☐ | ☐ | ☐ | |
| Diagnostics export and content review | ☐ | ☐ | ☐ | ☐ | |
| PDF, Fountain, FDX, text, and backup export | ☐ | ☐ | ☐ | ☐ | |
| Signed download Gatekeeper launch | ☐ | ☐ | ☐ | ☐ | |
| Offline launch and normal editing | ☐ | ☐ | ☐ | ☐ | |

## Menu and shortcut review

- [ ] File menu exposes supported new/open/recent/save/save as/export/close actions.
- [ ] Edit menu exposes undo/redo, cut/copy/paste, find, and supported screenplay formatting.
- [ ] View menu exposes supported panels and focus/navigation actions.
- [ ] Window menu exposes standard macOS window behavior.
- [ ] Help menu exposes onboarding, keyboard shortcuts, privacy, diagnostics, and release notes.
- [ ] Every advertised shortcut works from the expected focus context.
- [ ] No duplicate or shadowed shortcuts remain.
- [ ] Destructive actions require an explicit confirmation where data loss is possible.

## Accessibility review

- [ ] All controls have meaningful labels and values.
- [ ] Decorative images are hidden from accessibility.
- [ ] Focus order follows the visual and task order.
- [ ] Every primary workflow is keyboard-only operable.
- [ ] VoiceOver announces screenplay semantic element types.
- [ ] Error and recovery messages are announced once and do not trap focus.
- [ ] Text remains usable with increased contrast and larger accessibility sizes where supported.
- [ ] Reduced-motion preference is respected.

## Distribution evidence

Attach command output or CI artifacts for:

```sh
lipo -archs dist/DreamJotter.app/Contents/MacOS/DreamJotterMac
codesign --verify --deep --strict --verbose=2 dist/DreamJotter.app
xcrun notarytool history --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID"
xcrun stapler validate dist/DreamJotter.app
spctl --assess --type execute --verbose=4 dist/DreamJotter.app
```

## Acceptance decision

- Release candidate version:
- Commit SHA:
- Date:
- Accepted by:
- Known limitations:
- Decision: Pending