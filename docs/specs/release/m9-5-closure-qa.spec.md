# M9.5 Closure QA Spec

Status: specified
Milestone: M9.5 closure
Traceability ID: M9-5-CLOSURE-QA

## Goal

Close Milestone 9.5 with a lightweight but explicit Mac MVP release-readiness pass before new feature work begins.

M9.5 implementation is already present. This spec defines the verification pass that should be executed after implementation and before treating the Mac MVP export/review/backup flow as release-ready.

## Scope

- Manual QA execution for the current Mac MVP.
- Confirmation that existing automated validation commands still pass.
- Verification that M9.5 known limitations are intentionally deferred rather than accidentally unresolved.
- Capture of QA notes in a short report.

## Non-Goals

- No new export formats.
- No production PDF pagination.
- No restore-specific Save / Discard / Cancel implementation; that belongs to M9.6.
- No iPad, iPhone, cloud sync, AI provider, or plugin runtime work.

## Required Validation

Run and record the result of:

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

Xcode validation should also build the `DreamJotterMac` scheme on a macOS run destination.

## Manual QA Checklist

Use `docs/specs/release/mac-mvp-manual-qa-checklist.spec.md` as the canonical checklist.

At minimum, manually verify:

1. The app launches and creates a blank project.
2. TextKit and TextEditor editing both preserve screenplay text.
3. Save, Save As, Open, and recent-project flows preserve dirty state correctly.
4. Scene, character, location, note, dashboard, and search flows still reflect current project data.
5. Review Mode is read-only and navigates scenes/findings without dirtying the project.
6. Export picker appears from the main workspace and Review Mode.
7. Fountain, PDF, Markdown, plain text, and JSON backup exports write files successfully.
8. Canceling destination selection reports canceled feedback and does not dirty the project.
9. Reveal in Finder is available after successful file export.
10. Create Backup succeeds and Restore Backup validates backup content.
11. Restore with unsaved current work is blocked by confirmation-required feedback.
12. Invalid backup input preserves current project state.

## QA Report Format

Create a short dated QA note under `docs/acceptance/qa/` when the pass is executed.

Recommended filename:

```text
docs/acceptance/qa/m9-5-mac-mvp-qa-YYYY-MM-DD.md
```

Recommended sections:

- Environment
- Validation commands
- Manual checklist results
- Bugs found
- Deferred limitations
- Acceptance recommendation

## Acceptance Criteria

- All required validation commands pass or failures are documented with blocking/non-blocking classification.
- Manual QA checklist is executed once against a local build.
- Known limitations are explicitly carried forward to M9.6 or M10.
- No M9.5 QA action mutates project data unexpectedly or weakens dirty-state protection.

## Deferred Follow-Up

- M9.6 owns restore-specific Save / Discard / Cancel flow.
- M10 owns production PDF layout and pagination.
- Future release milestones may own native distribution, signing, notarization, and packaging.
