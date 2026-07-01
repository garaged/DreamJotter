# Debounced Parsing Spec

Status: specified
Milestone: M7
Registry ID: EDITOR-DEBOUNCED-PARSING

## User Goal

A writer can type without the editor feeling unstable while scene lists, dashboard, health reports, save, and export eventually reflect current screenplay text.

## Scope

- Track text revisions and parse revisions.
- Avoid excessive parse operations during rapid typing.
- Update semantic state after typing settles or explicit refresh runs.
- Keep malformed text usable.
- Preserve save/export correctness.

## Non-Goals

- No background indexing system.
- No worker-process parser.
- No AI analysis.
- No autosave policy changes.

## Behavior

Each text edit increments a current text revision. Parsing is scheduled after a debounce interval or equivalent controlled refresh. Successful parse updates last parsed revision, scene count, element count, and warnings. Malformed parse results must be represented without blocking editing.

## Given/When/Then Examples

- Given the user types quickly, then the editor should not trigger excessive parse operations.
- Given typing stops, then parse state eventually updates.
- Given parse fails or encounters malformed text, then the editor remains usable.
- Given parsing updates semantic elements, then save and export still use the updated state.

## Data Model Implications

Uses `EditorParseState` with current text revision, last parsed text revision, parsing status, parse date, warnings, errors, scene count, and element count.

## UI Implications

The UI may show subtle parse status if needed, but it should not interrupt typing. Explicit refresh can remain available for confidence.

## Testability Notes

Tests should use a deterministic scheduler or fake clock to verify debounce behavior, parse count, eventual parse refresh, and malformed text safety.

## Open Questions

- What is the initial debounce interval for macOS?
- Should save force a final parse before package write?
