# Contributing

DreamJotter uses Spec Driven Development. Specs are binding project artifacts, not supporting notes.

## How To Write Specs

Write specs for both product and engineering readers. Every feature spec should include:

- User goal.
- Scope.
- Non-goals.
- User-facing behavior.
- Acceptance criteria.
- Edge cases.
- Data model implications.
- Testability notes.
- Platform implications.
- Future cross-platform implications.

Use Given/When/Then examples when behavior has state, rules, or branching outcomes. Avoid vague terms such as "easy", "fast", or "smart" unless the spec defines observable behavior.

Separate beginner workflows from advanced controls. Simple Mode should stay understandable for new screenplay writers. Pro Mode may expose specialized features without forcing them into the beginner path.

## Updating Acceptance Criteria

Acceptance criteria must be specific enough to become tests later. Each criterion should identify:

- The user or system action.
- The expected observable result.
- Any relevant data state.
- Mode differences between Simple Mode and Pro Mode.
- Platform differences, if any.

When behavior changes, update the acceptance criteria in the same change as the spec. Do not leave implementation expectations only in comments, issues, or commit messages.

## Maintaining Traceability

Update `docs/acceptance/traceability-matrix.md` whenever a new requirement, milestone, ADR, or acceptance criterion is added.

Traceability should answer:

- Which requirement or decision introduced this behavior?
- Which milestone owns it?
- Which acceptance criteria validate it?
- Which future implementation or tests should cover it?

## Implementation Follows Specs

Implementation should not invent product behavior that is absent from specs. If implementation reveals a missing rule, update the spec before or alongside the code change.

The canonical project format is `.dreamjotter`. Do not make SwiftData the source of truth for projects or screenplay content. The screenplay model must be semantic, not merely rich text with formatting spans.

Plugins are future work. Build command concepts first, routine automation second, and plugin extension points only after those surfaces are proven by specs and implementation.

## Definition Of Done

A change is done when:

- Relevant specs or ADRs are created or updated.
- Acceptance criteria are observable and current.
- Traceability links the change to milestones and validation.
- Implementation, if any, follows the spec without expanding scope.
- Tests or validation notes exist where appropriate.
- No production app code is introduced during documentation-only prompts.
- Future work is captured in `TODO.md` or the relevant milestone document.
