# Milestone 10 Acceptance: Production PDF Export

Status: specified
Milestone: M10
Traceability ID: M10-PRODUCTION-PDF-EXPORT

## Acceptance Summary

Milestone 10 is accepted when DreamJotter can produce deterministic, production-oriented screenplay PDF exports through the existing export workflow without mutating project state.

## Required Acceptance Criteria

### Layout Planning

- PDF layout planning is deterministic for the same screenplay and preset.
- Layout planning is testable without requiring SwiftUI view state.
- Page setup, margins, body text roles, wrapped lines, and page numbers are represented explicitly enough for tests.

### Screenplay Formatting

- Scene headings are visually distinct from action.
- Action blocks wrap predictably.
- Character cues are formatted as screenplay cues.
- Parentheticals and dialogue use narrower dialogue formatting.
- Transitions are formatted distinctly.
- Unknown or malformed elements fall back to readable text with warnings.

### Pagination

- Content stays inside page margins.
- Page numbers do not collide with body content.
- Character cue and first dialogue line stay together where practical.
- Oversized blocks split safely.
- Title page numbering policy is deterministic.

### Preset Privacy and Metadata

- Reader Copy excludes internal metadata by default.
- Print Script includes print-friendly page numbers.
- Contest Submission suppresses identifying metadata by default.
- Notes and TODOs are excluded from reader-facing PDFs by default.

### Export Workflow Preservation

- PDF export uses the existing M9 export workflow entry point.
- M9.5 export picker can invoke production PDF export without a PDF-only UI rewrite.
- Export does not dirty the project.
- Fountain, Markdown, plain text, and JSON backup exports remain unchanged.

### Diagnostics

- Missing optional title metadata warns instead of crashing.
- Omitted notes/TODOs may be reported as non-fatal diagnostics.
- Renderer-unavailable failures produce friendly diagnostics.
- Malformed screenplay fallback produces warning diagnostics.

## Required Tests

- Simple one-scene PDF layout plan.
- Multi-scene page numbering.
- Character cue/dialogue keep-with-next behavior.
- Reader Copy metadata exclusion.
- Contest Submission identity suppression.
- Print Script page number policy.
- Notes/TODO exclusion.
- Malformed screenplay fallback warning.
- Export-result dirty-state preservation.

## Validation Commands

```sh
python3 scripts/spec-check
python3 scripts/spec-trace
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift test --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache swift build --product DreamJotterMac --disable-sandbox --scratch-path /private/tmp/DreamJotterSwiftPM
```

## Acceptance Decision

M10 should remain `specified` until the production PDF layout planner, renderer adapter, workflow integration, and tests are implemented.
