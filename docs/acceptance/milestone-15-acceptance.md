# Milestone 15 Acceptance — Mac 1.0 Release Readiness

Status: accepted

## Automated evidence

| Area | Required evidence | Status |
|---|---|---|
| Specification integrity | `python3 scripts/spec-check` | Passed |
| Traceability | `python3 scripts/spec-trace` | Passed |
| Core and app tests | `swift test` | Passed |
| Release compilation | `swift build --configuration release --product DreamJotterMac` | Passed |
| Localization | `python3 scripts/localization-check` | Passed |
| Packaging scripts | `bash -n` for universal, tester, and release scripts | Passed |
| Package persistence | Round-trip fixtures across supported schema versions | Passed |
| Corruption safety | Tests prove source package remains unchanged | Passed |
| Diagnostics privacy | Tests prove screenplay content is excluded by default | Passed |
| Long-script performance | Fixture timings remain within documented budgets | Passed |
| CI artifacts | Failed runs upload logs and test output | Passed |

## Manual QA matrix

The release owner confirmed all M15 manual checks as successful.

| Scenario | Apple Silicon | Intel | English | Spanish | Result / evidence |
|---|---:|---:|---:|---:|---|
| Fresh install and first launch | ☑ | ☑ | ☑ | ☑ | Passed |
| About, Help, privacy, and onboarding | ☑ | ☑ | ☑ | ☑ | Passed |
| Create, edit, save, quit, and reopen | ☑ | ☑ | ☑ | ☑ | Passed |
| Finder double-click and Open With | ☑ | ☑ | ☑ | ☑ | Passed |
| Keyboard-only screenplay workflow | ☑ | ☑ | ☑ | ☑ | Passed |
| VoiceOver primary workflow | ☑ | ☑ | ☑ | ☑ | Passed |
| Long screenplay open/edit/save/export | ☑ | ☑ | ☑ | ☑ | Passed |
| Corrupt package recovery choices | ☑ | ☑ | ☑ | ☑ | Passed |
| Historical schema migration | ☑ | ☑ | ☑ | ☑ | Passed |
| Unsupported future schema rejection | ☑ | ☑ | ☑ | ☑ | Passed |
| Diagnostics export and content review | ☑ | ☑ | ☑ | ☑ | Passed |
| PDF, Fountain, FDX, text, and backup export | ☑ | ☑ | ☑ | ☑ | Passed |
| Signed download Gatekeeper launch | ☑ | ☑ | ☑ | ☑ | Passed |
| Offline launch and normal editing | ☑ | ☑ | ☑ | ☑ | Passed |

## Menu and shortcut review

- [x] File menu exposes supported new/open/recent/save/save as/export/close actions.
- [x] Edit menu exposes undo/redo, cut/copy/paste, find, and supported screenplay formatting.
- [x] View menu exposes supported panels and focus/navigation actions.
- [x] Window menu exposes standard macOS window behavior.
- [x] Help menu exposes onboarding, keyboard shortcuts, privacy, diagnostics, and release notes.
- [x] Every advertised shortcut works from the expected focus context.
- [x] No duplicate or shadowed shortcuts remain.
- [x] Destructive actions require an explicit confirmation where data loss is possible.

## Accessibility review

- [x] All controls have meaningful labels and values.
- [x] Decorative images are hidden from accessibility.
- [x] Focus order follows the visual and task order.
- [x] Every primary workflow is keyboard-only operable.
- [x] VoiceOver announces screenplay semantic element types.
- [x] Error and recovery messages are announced once and do not trap focus.
- [x] Text remains usable with increased contrast and larger accessibility sizes where supported.
- [x] Reduced-motion preference is respected.

## Distribution evidence

Release validation covers universal architecture, Developer ID signing, notarization, stapling, and Gatekeeper assessment.

## Acceptance decision

- Release candidate version: 1.0.0
- Commit SHA: final M15 branch head
- Date: 2026-07-04
- Accepted by: release owner
- Known limitations: No release-blocking limitations identified.
- Decision: Accepted for Mac 1.0 release
