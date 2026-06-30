# Editor Behavior Spec

Status: specified
Milestone: M1-M4
Traceability ID: EDITOR-BEHAVIOR-001

## Purpose

This spec defines DreamJotter's smart screenplay editor behavior before TextKit UI work begins. It describes document state, semantic conversion, editing predictions, autocomplete, keyboard behavior, and platform adapter boundaries. It does not define production UI, TextKit wrapper code, pagination, or rendering implementation.

## Product Intent

The editor should help non-programmers write screenplay-shaped text without requiring them to understand file formats or element metadata. Beginners should be able to type naturally and get useful formatting suggestions. Advanced users should be able to override element kinds, use keyboard-driven workflows, and preserve precise semantic intent.

## Editor Document State

The platform-neutral editor owns an `EditorDocumentState` concept with these responsibilities:

| Field | Purpose | Notes |
| --- | --- | --- |
| `projectId` | Identifies the open project. | Portable ID from core model. |
| `screenplayId` | Identifies the screenplay being edited. | Supports future alternate drafts. |
| `textBuffer` | Current editable text representation. | Plain UTF-8 text, not canonical storage by itself. |
| `semanticElements` | Current semantic screenplay elements. | Derived from parser or direct semantic edits. |
| `currentElementId` | Element containing the cursor, if known. | Optional during malformed or empty states. |
| `currentElementKind` | Active semantic kind at cursor. | Drives toolbar state and smart Enter. |
| `selection` | Platform-neutral selection range concept. | Stored as text offsets or element-relative ranges, not AppKit/UIKit types. |
| `diagnostics` | Parser/editor warnings. | Non-blocking; preserve authored text. |
| `suggestions` | Autocomplete and scene-heading suggestions. | Ephemeral UI state, not canonical project content. |
| `mode` | Simple Mode or Pro Mode. | Controls visible actions, not project format. |
| `dirtyState` | Tracks unsaved semantic/text changes. | Used by future save/snapshot workflows. |

The text buffer is an editing projection. The canonical project remains semantic screenplay data inside the `.dreamjotter` package.

## Text Buffer To Semantic Screenplay Conversion

The editor reducer may request conversion from text buffer to semantic elements after meaningful edits, explicit parse commands, save, import, or cursor-context changes. Conversion must use the screenplay engine rules in `docs/editor/screenplay-engine-spec.md`.

Requirements:

- Preserve all authored text, including malformed input.
- Produce stable semantic elements where possible.
- Preserve Unicode and Spanish text.
- Emit diagnostics instead of blocking editing.
- Avoid SwiftUI, AppKit, UIKit, TextKit, SwiftData, or CloudKit dependencies in portable conversion logic.
- Avoid external AI or plugin involvement.

## Semantic Screenplay To Text Buffer Conversion

The editor may regenerate the text buffer from semantic elements when loading a project, restoring a snapshot, applying accepted structured edits, changing export/import views, or repairing editor state.

Requirements:

- Convert semantic elements into readable screenplay text.
- Preserve element order and authored text content.
- Use blank lines between screenplay blocks according to editor formatting policy.
- Avoid losing diagnostics or unknown text.
- Maintain cursor anchoring where practical by element ID and offset.
- Treat generated text as a projection, not a replacement for canonical semantic data.

## Current Element Kind

The current element kind is derived from cursor position and parser state. It controls displayed state, keyboard shortcuts, smart Enter, Tab cycling, and autocomplete priority.

When the cursor is in ambiguous or malformed text, the editor should expose the safest likely kind and keep diagnostics available. If confidence is low, the editor should show `action` or `unknown` rather than incorrectly forcing character/dialogue structure.

## Smart Enter Behavior

Smart Enter predicts the next element kind after the user presses Return. It must be deterministic and undoable. It should insert the minimal whitespace needed for the next screenplay block.

| Current context | Default next kind | Beginner behavior | Pro behavior |
| --- | --- | --- | --- |
| Empty document | Scene heading | Show scene-heading placeholder/suggestion. | Allow cycling to any supported kind. |
| Scene heading | Action | Move to action block after a blank line. | Allow Tab or shortcut override. |
| Action | Action | Continue prose unless action block is empty. | Allow explicit next kind selection. |
| Character | Dialogue | Move directly to dialogue line. | Preserve character cue and allow parenthetical insertion. |
| Parenthetical | Dialogue | Move to dialogue line. | Allow additional parenthetical or dialogue. |
| Dialogue | Character or action | Suggest character if next line looks like a cue; otherwise action. | Allow fast cycling to character, action, transition, or shot. |
| Transition | Scene heading | Suggest next scene heading. | Allow action or section override. |
| Note | Action | Return to prior writing context when known. | Allow note continuation. |

Acceptance examples:

- Pressing Enter after `INT. KITCHEN - DAY` creates or suggests an action block.
- Pressing Enter after `MARIA` creates or suggests dialogue.
- Pressing Enter after dialogue suggests a character cue or action depending on context.

## Tab Cycling Behavior

Tab cycles the current block through valid screenplay element kinds without changing authored text unless the selected kind requires safe formatting syntax. The cycle must be reversible and undoable.

Suggested default cycle:

1. Action
2. Scene heading
3. Character
4. Dialogue
5. Parenthetical
6. Transition
7. Shot
8. Note

Rules:

- Cycling must not create invalid direct state mutation outside the editor reducer/controller.
- Cycling a block to `character` should validate that dialogue context is possible or add a diagnostic.
- Cycling a block to `parenthetical` outside dialogue context should warn or disallow in Simple Mode.
- Pro Mode may expose a fuller element-kind menu.

Acceptance example: pressing Tab while the cursor is in an action line cycles the block to the next valid kind and updates `currentElementKind`.

## Character Autocomplete

Character autocomplete suggests known characters from project metadata and detected character cues.

Requirements:

- Trigger on character-cue contexts, forced character entry, or uppercase name-like input.
- Suggest exact known characters before inferred names.
- Preserve Unicode names such as `NIÑA` and `JOSÉ`.
- Do not auto-create a character without explicit acceptance or a future command.
- In Simple Mode, suggestions should be unobtrusive and easy to dismiss.
- In Pro Mode, suggestions may expose aliases, voice tags, and metadata hints.

Acceptance example: typing `MA` in a character cue context suggests `MARIA` when that character exists in the project.

## Location Autocomplete

Location autocomplete suggests known locations from scene headings and project location records.

Requirements:

- Trigger after scene prefixes such as `INT.`, `EXT.`, `INT./EXT.`, and forced scene-heading entry.
- Prefer locations previously used in the screenplay.
- Preserve casing and Unicode in locations.
- Do not require a separate location manager to function.
- Do not create canonical location records without explicit acceptance or a future command.

Acceptance example: typing `INT. CAF` suggests `CAFETERIA` when that location exists in scene headings or project locations.

## Scene Heading Suggestions

Scene heading suggestions help the user form valid scene headings.

Requirements:

- Typing `INT.` suggests scene heading context.
- Typing `EXT.` suggests scene heading context.
- The editor may suggest recent locations and common times of day.
- Suggestions must not block free typing.
- Invalid scene headings should produce friendly diagnostics, not modal errors.

## Note Insertion

The editor supports note insertion as a semantic note or Fountain-style inline note projection.

Requirements:

- Inserted notes must preserve text and link to the current element where practical.
- Notes do not alter screenplay dialogue/action text unless explicitly inserted into the buffer.
- In Simple Mode, note insertion should be a clear writing aid.
- In Pro Mode, notes may expose tags, linked elements, and custom fields where available.

## TODO Detection

TODO detection identifies writer reminders without forcing project structure.

Rules:

- `[[TODO: ...]]` is treated as an explicit note candidate.
- Plain `TODO:` lines may be highlighted or suggested as notes.
- TODO detection is advisory and never mutates text automatically.
- TODO findings should be available to script health and continuity workflows later.

## Selection And Cursor Behavior Assumptions

The platform-neutral editor uses portable selection concepts. Platform adapters translate to AppKit/UIKit selection ranges.

Assumptions:

- Cursor position can be represented as a UTF-8/Unicode-safe text offset or element-relative offset.
- Selections may span multiple semantic elements.
- Edits across multiple elements trigger reparse of the affected range or whole buffer, depending on implementation maturity.
- Cursor preservation should prefer element ID plus offset after semantic regeneration.
- The editor must not corrupt Unicode grapheme clusters when moving or selecting text.

## Platform-Specific UI Adapters

### macOS TextKit/AppKit

The macOS adapter may use TextKit and AppKit to render and edit text. It is responsible for keyboard handling, native menus, selection bridging, accessibility bridges, and visual styling. It must call the platform-neutral editor reducer/controller for semantic decisions.

### iPadOS/iOS TextKit/UIKit

The iPadOS/iOS adapter may use TextKit and UIKit for touch editing, hardware keyboard support, input accessory controls, selection handles, and platform accessibility. It must call the same platform-neutral editor reducer/controller as macOS.

### Platform-Neutral Editor Reducer/Controller

The editor reducer/controller owns state transitions for:

- Buffer changes.
- Current element kind updates.
- Smart Enter decisions.
- Tab cycling.
- Autocomplete request/accept/dismiss behavior.
- Note insertion requests.
- TODO detection.
- Diagnostics propagation.

It must remain portable and must not import SwiftUI, AppKit, UIKit, TextKit, SwiftData, or CloudKit.

## Accessibility Considerations

- Semantic element kind should be available to assistive technologies through platform adapters.
- Autocomplete suggestions must be keyboard reachable and dismissible.
- Diagnostics should be announced without interrupting typing.
- Distraction-free mode must not hide essential accessibility controls.
- Color must not be the only indicator of element kind, warning state, or revision status.
- The editor must preserve readable contrast in default themes.

## Keyboard Shortcut Expectations

Initial shortcut expectations are behavioral, not binding UI implementation:

| Action | Expected shortcut direction |
| --- | --- |
| Smart Enter | Return |
| New line without smart transition | Option-Return or platform equivalent |
| Cycle element kind | Tab or menu command |
| Reverse cycle element kind | Shift-Tab or menu command |
| Insert note | Command-oriented shortcut or menu item |
| Dismiss suggestions | Escape |
| Accept suggestion | Return, Tab, or explicit command depending on context |
| Toggle distraction-free mode | User-visible command, shortcut optional |

Platform adapters may choose final key equivalents that fit Apple conventions.

## Distraction-Free Writing Mode Expectations

Distraction-free mode reduces visible chrome while preserving writing safety.

Requirements:

- Keep the text editor and current writing context available.
- Hide nonessential panels and pro tools.
- Preserve autosave/save status indicators where practical.
- Keep diagnostics subtle and non-blocking.
- Keep accessibility and escape paths available.
- Do not change canonical storage or semantic parsing behavior.

## Simple Mode Behavior

Simple Mode is the default. It should expose writing, scene headings, characters, notes, and common autocomplete without requiring users to manage metadata directly.

Simple Mode should:

- Prefer suggestions over configuration panels.
- Avoid exposing low-level element-kind details unless needed.
- Keep Pro-only revision, production, custom field, routine, and plugin extension controls hidden.
- Preserve all project data even when advanced metadata is hidden.

## Pro Mode Behavior

Pro Mode may expose explicit element kind controls, advanced keyboard workflows, revision metadata, production tags, custom fields, and routine-related commands when those features exist.

Pro Mode must not fork the editor model. It uses the same semantic screenplay state and `.dreamjotter` package format as Simple Mode.

## Acceptance Criteria

- Pressing Enter after a scene heading suggests or creates action context.
- Pressing Enter after a character cue suggests or creates dialogue context.
- Pressing Enter after dialogue suggests character or action based on context.
- Typing `INT.` suggests scene-heading entry.
- Typing `EXT.` suggests scene-heading entry.
- Pressing Tab cycles the current block through valid screenplay element kinds.
- Character autocomplete suggests known characters.
- Location autocomplete suggests known locations.
- Spanish and Unicode text remain editable, selectable, and classifiable without corruption.
- Platform adapters delegate semantic decisions to the portable reducer/controller.

## Given/When/Then Examples

### Enter After Scene Heading

Given the buffer contains `INT. KITCHEN - DAY` and the cursor is at the end of the scene heading
When the writer presses Enter
Then the editor moves to or suggests an action block
And `currentElementKind` becomes `action`.

### Enter After Character

Given the current block is `MARIA` classified as `character`
When the writer presses Enter
Then the editor moves to dialogue context
And it does not create a second character cue automatically.

### Enter After Dialogue

Given the current block is dialogue following `MARIA`
When the writer presses Enter
Then the editor suggests character or action context
And the writer can override the suggestion.

### Typing Scene Prefixes

Given the writer starts a new line
When they type `INT.` or `EXT.`
Then the editor treats the line as scene-heading context
And location autocomplete may suggest known locations.

### Tab Cycles Element Kind

Given the cursor is inside an action block
When the writer presses Tab
Then the editor cycles the block to the next valid element kind
And the change is undoable.

### Character Autocomplete

Given the project has a known character named `MARIA`
When the writer types `MA` in character context
Then autocomplete suggests `MARIA`
And accepting the suggestion inserts the text through the editor controller.

### Location Autocomplete

Given the project has a known location named `CAFETERIA`
When the writer types `INT. CAF`
Then autocomplete suggests `CAFETERIA`
And accepting the suggestion preserves a valid scene heading.

### Spanish And Unicode Text

Given the writer types `NIÑA` and `¿Dónde está José?`
When the editor parses and regenerates the buffer
Then the text remains unchanged
And grapheme-safe cursor movement is preserved.

## Non-Goals

- No production UI implementation.
- No TextKit/AppKit/UIKit wrappers yet.
- No Xcode project creation.
- No rich text canonical model.
- No SwiftData canonical storage.
- No real AI provider behavior.
- No plugin runtime or arbitrary scripting.
- No page-accurate PDF layout or final pagination.
- No full FDX support.

## Open Questions

- Exact keyboard shortcuts should be finalized during Apple UI design.
- Whether Tab cycling should insert Fountain forcing markers or pure semantic state is deferred to implementation design.
- Partial reparse strategy versus whole-buffer reparse is deferred until parser performance is measurable.
