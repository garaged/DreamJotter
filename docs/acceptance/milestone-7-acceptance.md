# Milestone 7 Acceptance

## Purpose

This file defines acceptance criteria for Milestone 7: Screenplay Editor Usability v1.

Status: implemented. Production pagination, revision-color editing UI, iPadOS/iOS adapters, AI-generated editor suggestions, and plugin-provided editor extensions remain deferred beyond Milestone 7.

## A. Smart Enter Behavior

### A-M7-SMART-ENTER-001: Scene Heading To Action

Given the cursor is at the end of a scene heading, when Enter is pressed, then the next element kind is action.

Traceability: EDITOR-SMART-ENTER.

### A-M7-SMART-ENTER-002: Character To Dialogue

Given the cursor is at the end of a character name, when Enter is pressed, then the next element kind is dialogue.

Traceability: EDITOR-SMART-ENTER.

### A-M7-SMART-ENTER-003: Dialogue Returns To Useful State

Given the cursor is at the end of dialogue, when Enter is pressed twice or according to the chosen rule, then the editor can return to action.

Traceability: EDITOR-SMART-ENTER.

### A-M7-SMART-ENTER-004: Malformed Text Does Not Crash

Given malformed text, when Enter is pressed, then the editor does not crash.

Traceability: EDITOR-SMART-ENTER.

## B. Tab Element Kind Cycling

### A-M7-CYCLING-001: Action Cycles To Next Kind

Given a line selected as action, when Tab is pressed, then the element kind changes to the next supported kind.

Traceability: EDITOR-ELEMENT-KIND-CYCLING.

### A-M7-CYCLING-002: Save Reopen Preserves Cycled Text

Given a cycled line, when saved and reopened, then the screenplay text and semantic element remain consistent.

Traceability: EDITOR-ELEMENT-KIND-CYCLING, EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M7-CYCLING-003: Unicode Text Preserved

Given text with Spanish or Unicode characters, when Tab cycling occurs, then characters are preserved.

Traceability: EDITOR-ELEMENT-KIND-CYCLING.

## C. Scene Heading Suggestions

### A-M7-SCENE-SUGGEST-001: Prefix Classifies Scene Heading

Given the user types `INT.`, when the parser refreshes, then the current line is classified as a scene heading.

Traceability: EDITOR-SCENE-HEADING-SUGGESTIONS.

### A-M7-SCENE-SUGGEST-002: Known Location Suggested

Given known location `APARTMENT`, when the user starts a scene heading, then `APARTMENT` is suggested.

Traceability: EDITOR-SCENE-HEADING-SUGGESTIONS, EDITOR-LOCATION-AUTOCOMPLETE.

### A-M7-SCENE-SUGGEST-003: Ignored Suggestion Does Not Mutate Text

Given the user ignores a suggestion, then the original text remains unchanged.

Traceability: EDITOR-SCENE-HEADING-SUGGESTIONS.

## D. Character Autocomplete

### A-M7-CHARACTER-001: Known Character Suggested

Given a project has character `ELENA`, when the user types `ELE`, then `ELENA` is suggested.

Traceability: EDITOR-CHARACTER-AUTOCOMPLETE.

### A-M7-CHARACTER-002: Accepted Character Replaces Line

Given the user accepts `ELENA`, then the current line becomes `ELENA`.

Traceability: EDITOR-CHARACTER-AUTOCOMPLETE.

### A-M7-CHARACTER-003: No Match Is Safe

Given no matching character exists, then no suggestion is shown and no error occurs.

Traceability: EDITOR-CHARACTER-AUTOCOMPLETE.

## E. Location Autocomplete

### A-M7-LOCATION-001: Parsed Location Suggested

Given prior scene heading `INT. COFFEE SHOP - DAY`, when the user types `INT. COF`, then `COFFEE SHOP` is suggested.

Traceability: EDITOR-LOCATION-AUTOCOMPLETE.

### A-M7-LOCATION-002: No Location Match Is Safe

Given no matching location exists, then no suggestion is shown.

Traceability: EDITOR-LOCATION-AUTOCOMPLETE.

### A-M7-LOCATION-003: Unicode Location Preserved

Given Spanish or Unicode location names, suggestions preserve text.

Traceability: EDITOR-LOCATION-AUTOCOMPLETE.

## F. Debounced Parsing

### A-M7-DEBOUNCE-001: Fast Typing Avoids Excessive Parses

Given the user types quickly, then the editor does not trigger excessive parse operations.

Traceability: EDITOR-DEBOUNCED-PARSING.

### A-M7-DEBOUNCE-002: Typing Stop Updates Parse

Given typing stops, then parse state eventually updates.

Traceability: EDITOR-DEBOUNCED-PARSING.

### A-M7-DEBOUNCE-003: Malformed Parse Keeps Editor Usable

Given parse fails or encounters malformed text, then the editor remains usable.

Traceability: EDITOR-DEBOUNCED-PARSING.

### A-M7-DEBOUNCE-004: Updated Parse Drives Save And Export

Given parsing updates semantic elements, then save and export use the updated state.

Traceability: EDITOR-DEBOUNCED-PARSING, EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

## G. Scene Navigation Sync

### A-M7-NAV-001: Scene Click Requests Navigation

Given a multi-scene screenplay, when the user clicks Scene 2 in the scene list, then the editor scrolls or moves to Scene 2.

Traceability: EDITOR-SCENE-NAVIGATION-SYNC.

### A-M7-NAV-002: Cursor Updates Selected Scene

Given the cursor is inside Scene 3, when selection sync runs, then Scene 3 becomes selected.

Traceability: EDITOR-SCENE-NAVIGATION-SYNC.

### A-M7-NAV-003: Deleted Scene Falls Back Safely

Given a scene is deleted, then selected scene falls back safely.

Traceability: EDITOR-SCENE-NAVIGATION-SYNC.

### A-M7-NAV-004: Duplicate Headings Use Stable Identity

Given duplicate scene headings exist, then scene identity uses stable parsed position or ID strategy.

Traceability: EDITOR-SCENE-NAVIGATION-SYNC.

## H. Basic Screenplay Line Styling

### A-M7-STYLING-001: Scene Headings Distinguished

Given parsed scene headings, when TextKit styling refreshes, then scene headings are visually distinguished.

Traceability: EDITOR-BASIC-LINE-STYLING.

### A-M7-STYLING-002: Character Lines Distinguished

Given character lines, when styling refreshes, then character lines are visually distinguished.

Traceability: EDITOR-BASIC-LINE-STYLING.

### A-M7-STYLING-003: Styling Not Required For Recovery

Given text is saved, then styling metadata is not required to recover the screenplay.

Traceability: EDITOR-BASIC-LINE-STYLING, EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M7-STYLING-004: Fallback Editor Still Works

Given the fallback editor is used, then the app remains functional without styling.

Traceability: EDITOR-BASIC-LINE-STYLING, EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

## I. Editor Empty States And Guidance

### A-M7-EMPTY-001: Blank Script Shows Guidance

Given a new blank project, when opening the Script pane, then the user sees helpful guidance or placeholder text.

Traceability: EDITOR-EMPTY-STATE-GUIDANCE.

### A-M7-EMPTY-002: Typing Clears Guidance

Given the user starts typing, then guidance no longer obstructs writing.

Traceability: EDITOR-EMPTY-STATE-GUIDANCE.

## J. Preserve Existing Document Workflow

### A-M7-WORKFLOW-001: TextKit Save Reopen Preserves Text

Given the user edits through TextKit, when saving and reopening, then text is preserved.

Traceability: EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M7-WORKFLOW-002: Fallback Save Reopen Preserves Text

Given the user edits through fallback TextEditor, when saving and reopening, then text is preserved.

Traceability: EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M7-WORKFLOW-003: Export Reflects Current Text

Given the user exports Fountain after editor changes, then exported text reflects current screenplay.

Traceability: EDITOR-DOCUMENT-WORKFLOW-PRESERVATION.

### A-M7-WORKFLOW-004: Export Excludes Styling Artifacts

Given editor styling exists, then exported Fountain does not include styling artifacts.

Traceability: EDITOR-DOCUMENT-WORKFLOW-PRESERVATION, EDITOR-BASIC-LINE-STYLING.

## Deferred Acceptance

- Production pagination.
- Revision-color editing UI.
- iPadOS/iOS editor behavior.
- AI-generated editor suggestions.
- Plugin-provided editor extensions.
