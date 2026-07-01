# Milestone 7: Screenplay Editor Usability v1

Status: implemented
Milestone: M7
Traceability ID: M7-SCREENPLAY-EDITOR-USABILITY

## Goal

Make DreamJotter's macOS editor feel like a screenplay editor instead of a generic text editor, while preserving the existing semantic parse, save, reopen, dirty-state, and Fountain export workflow.

Milestone 7 focuses on editor behavior that helps a writer stay in screenplay form: smart Enter, element-kind cycling, character and location suggestions, scene navigation sync, controlled parsing, basic adapter-only line styling, and nonintrusive empty-state guidance.

Implementation status: Milestone 7 is implemented as a usable v1 editor workflow. TextKit handles Smart Enter, Tab cycling, visible scene navigation, cursor-to-scene sync, adapter-only styling, and a passive empty-state overlay. Suggestions render in the Script pane and are accepted through the document view model. The SwiftUI TextEditor fallback remains available and uses the same plain-text save/export path.

## Scope

- Smart Enter behavior for screenplay element flow.
- Tab-based element kind cycling.
- Scene heading classification and suggestions.
- Character autocomplete from existing project/parsed character data.
- Location autocomplete from parsed scene headings or future explicit location records.
- Debounced or otherwise controlled parser refresh.
- Scene list to editor selection synchronization.
- Basic TextKit line styling for key screenplay element kinds.
- Empty editor guidance for new writers.
- Preservation of Milestone 6 document lifecycle behavior.

## Non-Goals

- No iOS or iPadOS target.
- No iCloud or sync.
- No real AI provider.
- No plugin runtime.
- No canonical rich-text storage.
- No production pagination or print layout.
- No revision-color production editor.
- No replacement of `.dreamjotter` package storage.

## Architecture Rules

- macOS first.
- Portable core always.
- TextKit remains an editor adapter.
- SwiftUI and TextKit views stay thin.
- Editor behavior should live in testable editor state, view-model, or app-support code where practical.
- The semantic screenplay model remains the source of truth.
- `NSTextView`, `NSAttributedString`, and raw rich text are never canonical screenplay storage.
- Save/Open/Save As/export/dirty-state behavior from Milestone 6 must continue working.

## Feature Areas

### A. Smart Enter Behavior

Enter predicts the useful next screenplay line kind from the current semantic context. Scene headings lead to action, character cues lead to dialogue, parentheticals return to dialogue, transitions lead to scene headings, and malformed text must never crash the editor.

### B. Tab Element Kind Cycling

Tab cycles the current line through supported screenplay element kinds: action, character, dialogue, parenthetical, transition, shot, and note. Scene headings may be inferred from heading syntax. Cycling must preserve text and update the semantic parse.

### C. Scene Heading Suggestions

Typing scene heading prefixes such as `INT.`, `EXT.`, or `INT./EXT.` should classify or suggest scene headings. Known locations and common times of day may be suggested without mutating text until accepted.

### D. Character Autocomplete

Existing project characters should be suggested case-insensitively while typing character lines. Accepted suggestions update the current line; ignored suggestions leave text unchanged.

### E. Location Autocomplete

Existing parsed or explicit locations should be suggested while typing scene headings. Suggestions preserve canonical spelling and Unicode text.

### F. Debounced Parsing

Parser refresh should be controlled so typing remains stable. Explicit refresh can remain available. When parsing catches up, scene list, dashboard, health report inputs, save, and export use the updated semantic state.

### G. Scene Navigation Sync

Scene list selection and editor selection should stay synchronized where practical. Scene clicks request editor navigation. Cursor movement can update selected scene. Deleted or duplicate scenes fall back safely using stable parsed position or ID strategy.

### H. Basic Screenplay Line Styling

TextKit may visually distinguish scene headings, character names, transitions, and notes. Styling is adapter-only and not required to recover, save, reopen, or export screenplay content. SwiftUI TextEditor fallback may remain unstyled.

### I. Editor Empty States And Guidance

Blank scripts should show passive guidance or placeholder examples such as `INT. APARTMENT - MORNING`, action, and dialogue. Guidance must stop obstructing the writer once typing starts.

### J. Preserve Existing Document Workflow

All editor changes must preserve TextKit and fallback TextEditor dirty-state updates, package save/reopen, recent projects, and Fountain export.

## Data Contracts

- `docs/data-contracts/editor-navigation-state.md`
- `docs/data-contracts/editor-suggestion.md`
- `docs/data-contracts/editor-parse-state.md`

## Related Specs

- `docs/specs/editor/smart-enter.spec.md`
- `docs/specs/editor/element-kind-cycling.spec.md`
- `docs/specs/editor/character-location-autocomplete.spec.md`
- `docs/specs/editor/scene-navigation-sync.spec.md`
- `docs/specs/editor/debounced-parsing.spec.md`
- `docs/specs/editor/basic-screenplay-line-styling.spec.md`

## Executable Spec Plan

- Enter after scene heading selects or suggests action.
- Enter after character selects or suggests dialogue.
- Enter after dialogue returns to a useful next state.
- Tab cycles element kinds.
- Tab cycling preserves Unicode text.
- `INT.` and `EXT.` classify as scene headings.
- Character autocomplete returns known characters.
- Location autocomplete returns parsed or explicit locations.
- Parse debounce prevents excessive parse calls.
- Parse refresh updates scene list.
- Clicking scene requests editor navigation.
- Cursor-in-scene updates selected scene.
- Styling does not affect canonical text.
- TextKit and TextEditor both preserve save/reopen behavior.
- Export after editor changes reflects current text.

## Deferred Work

- Production pagination and page breaks.
- Revision-color editing UI.
- Full keyboard command customization.
- iPadOS/iOS editor adapters.
- AI-assisted suggestions.
- Plugin-provided editor behavior.
