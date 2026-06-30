# Fountain Support Spec

Status: specified
Milestone: M1-M4
Traceability ID: EDITOR-FOUNTAIN-001

## Purpose

This spec defines DreamJotter's supported Fountain subset for import and export. Fountain is an interoperability format. It is not the canonical project format. The canonical project format remains the `.dreamjotter` package with semantic screenplay JSON and a companion `script.fountain` export/cache where appropriate.

## Principles

- Import produces semantic `ScriptElement` records.
- Export derives Fountain from semantic screenplay data.
- Unicode text must be preserved.
- Unsupported Fountain constructs produce diagnostics instead of crashes.
- Round-trip expectations are semantic, not byte-for-byte.
- Fountain support must stay in portable core modules without Apple UI or SwiftData dependencies.

## Supported Fountain Syntax

| Fountain syntax | Import behavior | Export behavior |
| --- | --- | --- |
| Title page key-value lines | Map supported fields to project metadata. Preserve unsupported fields as raw metadata or diagnostics. | Emit supported metadata fields when export preset includes them. |
| Scene headings | Map to `sceneHeading`. Supports standard prefixes and forced headings with `.`. | Emit heading text as stored. |
| Action | Map to `action`. Preserve line breaks inside action blocks where practical. | Emit action text with blank-line separation. |
| Character cues | Map to `character`; supports uppercase cues and forced cues with `@`. | Emit character cue text as uppercase only when stored that way or requested by preset. |
| Dialogue | Map to `dialogue` linked to preceding character cue. | Emit after character cue with blank-line boundaries. |
| Parentheticals | Map to `parenthetical` inside dialogue blocks. | Emit between character and dialogue or dialogue lines. |
| Transitions | Map to `transition`; supports known uppercase patterns and forced transitions with `>`. | Emit transition text as stored. |
| Sections | Map leading `#` lines to `section`. | Emit `#` depth when section level is known; otherwise emit a conservative section line. |
| Synopsis | Preserve as section-supporting metadata or note-like element. | Emit only when supported by stored metadata. |
| Notes | Map `[[...]]` to `note` or note references. | Emit inline notes when export preset includes notes. |
| Page breaks | Map `===` to `pageBreak`. | Emit `===` for page break elements. |

## Import Mapping Details

### Title Page

Supported keys include `Title`, `Credit`, `Author`, `Authors`, `Source`, `Draft date`, and `Contact`. Unknown keys must not be discarded. They should be stored as raw import metadata or reported as unsupported metadata diagnostics.

### Forced Elements

Fountain forced syntax must override heuristic classification when unambiguous:

- `.INT. HOUSE - NIGHT` forces a scene heading.
- `@McClane` forces a character cue.
- `> CUT TO:` forces a transition.
- `!THIS MUST BE ACTION` forces action.

Forced syntax markers are not part of the canonical display text unless the user explicitly authored them as escaped content.

### Dialogue Blocks

Dialogue import requires a character cue. Parentheticals are accepted only in dialogue context. Orphan dialogue-like text is preserved as action or unknown with diagnostics.

### Notes

Inline notes using `[[...]]` must preserve internal text exactly as UTF-8. A note may become a standalone `note` element or an inline note reference depending on future model implementation, but the authored note text must be recoverable.

## Export Mapping Details

Fountain export should produce readable plain text from semantic elements:

- Separate major blocks with blank lines.
- Preserve authored Unicode text.
- Keep scene headings, character cues, transitions, and shots in their stored text form unless an export preset requests normalization.
- Emit notes only when the export preset includes writer notes.
- Emit unsupported elements as conservative action text with diagnostics, or omit only when the export preset explicitly excludes them.

## Round-Trip Requirements

Supported Fountain input should satisfy semantic round-trip:

1. Import Fountain into semantic elements.
2. Export semantic elements to Fountain.
3. Re-import the exported Fountain.
4. Compare supported semantic kind sequence and text content.

The comparison must tolerate normalized blank lines, metadata ordering, and unsupported syntax diagnostics.

## Unicode And Spanish Examples

Input:

```fountain
Title: La Noche Larga

EXT. ZOCALO - NOCHE

La ciudad respira bajo la lluvia.

NIÑA
(susurra)
¿Dónde está José?

CORTE A:
```

Expected behavior: all text remains UTF-8; `NIÑA` is a character cue, `¿Dónde está José?` is dialogue, and `CORTE A:` is a transition.

## Unsupported Or Deferred Syntax

These constructs are deferred or diagnostic-only through the first implementation wave:

- Full Final Draft FDX parity.
- Dual dialogue layout semantics.
- Lyrics-specific formatting.
- Centered text layout.
- Boneyard comments as recoverable hidden ranges.
- Complex inline emphasis as rich-text metadata.
- Page-count-accurate pagination.

Unsupported syntax must not corrupt the semantic screenplay. It should either preserve text as action/unknown or attach diagnostics to the closest safe element.

## Acceptance Criteria

- Importing an empty Fountain file produces an empty screenplay with no crash.
- Importing `simple.fountain` produces scene, action, character, dialogue, and transition elements.
- Importing `multi-scene.fountain` produces multiple scene records in source order.
- Importing `spanish-unicode.fountain` preserves accents, ñ, inverted punctuation, and Spanish transition text.
- Importing `malformed.fountain` preserves all authored text and emits diagnostics for invalid or ambiguous structures.
- Exporting supported semantic elements produces valid readable Fountain text.
- Import/export round-trip preserves supported semantic kind sequence and text content.

## Given/When/Then Scenarios

### Import Simple Script

Given a supported Fountain file with one scene, action, a character cue, dialogue, and a transition
When the engine imports the file
Then it creates semantic elements in document order
And it does not require SwiftData or Apple UI frameworks.

### Preserve Unicode

Given a Fountain file with Spanish dialogue and Unicode names
When the engine imports and exports it
Then the exported text preserves accents, ñ, and inverted punctuation.

### Handle Malformed Input

Given a Fountain file with an invalid scene heading and malformed parenthetical
When the engine imports it
Then all source text remains recoverable
And diagnostics identify the malformed structures
And parsing continues after the malformed block.

## Future FDX Boundary

FDX support is future adapter work. FDX import/export must map into the same semantic model and `.dreamjotter` package. No FDX requirement may replace the canonical package, require SwiftData, or introduce platform-specific core dependencies.
