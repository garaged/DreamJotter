# Screenplay Engine Spec

Status: specified
Milestone: M1-M4
Traceability IDs: EDITOR-ENGINE-001, EDITOR-FIXTURES-001

## Purpose

The screenplay engine defines how DreamJotter understands screenplay text as semantic project data. It is not an editor widget, a rich text model, or an Apple-platform adapter. The engine must accept plain screenplay text and supported Fountain text, classify it into ordered `ScriptElement` records, preserve user-authored text, and report diagnostics for ambiguous or malformed input without blocking writing.

## Non-Negotiable Rules

- The canonical screenplay model is semantic, not rich text only.
- Parsed output uses portable core data contracts and must not require SwiftUI, AppKit, UIKit, TextKit, SwiftData, or CloudKit.
- The parser is deterministic. The same input, parser version, and options produce the same elements and diagnostics.
- Unicode text is first-class. Spanish names, punctuation, accents, and inverted punctuation must round-trip.
- Malformed input is preserved as text with diagnostics rather than discarded.
- Future AI, routines, plugins, or UI formatting must not be required to classify screenplay text.

## Semantic Screenplay Model

A screenplay is an ordered collection of `ScriptElement` records. Each element has a stable portable ID, a semantic kind, raw text content, normalized display text where applicable, optional links to scene/character/location metadata, and optional diagnostics.

The parser may derive higher-level records such as `Scene`, detected `Character`, and detected `Location`, but those records are derived from semantic elements or explicit project metadata. They are not inferred from styling alone.

## Script Element Classification

The engine classifies non-empty text blocks into these semantic kinds, aligned with `docs/data-contracts/screenplay-element-kinds.md`:

| Kind | Purpose |
| --- | --- |
| `sceneHeading` | Starts or identifies a scene location/time block. |
| `action` | Describes visible action, setting, or prose direction. |
| `character` | Names the speaker for following dialogue. |
| `dialogue` | Spoken text belonging to the most recent character cue. |
| `parenthetical` | Performance direction inside a dialogue block. |
| `transition` | Editing transition such as `CUT TO:`. |
| `shot` | Camera or shot instruction such as `CLOSE ON:`. |
| `note` | Inline writer note or TODO marker. |
| `section` | Act, sequence, or outline heading. |
| `pageBreak` | Explicit page break marker. |
| `unknown` | Preserved malformed or unsupported text. |

## Deterministic Parsing Rules

Classification uses a stable precedence order:

1. Explicit Fountain markers and block syntax.
2. Blank-line block boundaries.
3. Scene heading detection.
4. Transition detection.
5. Section and page break detection.
6. Note detection.
7. Character cue detection when followed by dialogue-compatible content.
8. Parenthetical detection inside a dialogue block.
9. Dialogue continuation inside a dialogue block.
10. Shot detection.
11. Action fallback.
12. Unknown fallback for malformed text that cannot be safely classified.

The parser must not reinterpret earlier elements based on later UI actions. Reclassification is allowed only when the source text changes or parser options/version changes.

## Scene Heading Detection

A line is a scene heading when it is a standalone line that matches a supported scene prefix followed by location text, or when Fountain forces a scene heading with a leading `.`.

Supported prefixes include:

- `INT.`
- `EXT.`
- `INT./EXT.`
- `EXT./INT.`
- `I/E.`
- `EST.`

Scene headings may include Unicode text and Spanish words in the location or time segment, for example `EXT. ZOCALO - NOCHE` or `INT. CAFETERIA - DIA`.

Invalid scene-like lines such as `INT HOUSE DAY` should be preserved as `unknown` or `action` with a diagnostic, depending on parser confidence. They must not silently create a valid scene.

## Action Detection

Action is the fallback for prose blocks not classified as another semantic kind. Action may include mixed case, Unicode, punctuation, TODO text that is not explicitly marked as a note, and multiple lines when the parser groups adjacent prose lines.

Action must not depend on paragraph styling. Rich text emphasis may be imported as plain text or preserved through future annotation metadata, but it is not required for classification.

## Character Detection

A character cue is a standalone line that is uppercase or Fountain-forced with `@`, is not a scene heading, transition, shot, section, or page break, and is followed by dialogue-compatible content.

Supported names include Unicode uppercase names such as `NIÑA`, `JOSÉ`, and names with parenthetical extensions such as `MARIA (V.O.)`.

Ambiguous uppercase lines are not automatically character cues unless dialogue context supports that classification. For example, `THIS IS PROBABLY IMPORTANT` followed by lowercase prose should be classified as action or unknown with an ambiguity diagnostic.

## Dialogue Detection

Dialogue begins after a character cue and continues until a blank line, a new scene heading, a transition, a new character cue, or another block-ending element. Dialogue may contain Unicode text and Spanish punctuation such as `¿Dónde está José?`.

Dialogue is linked to the nearest preceding character cue within the current dialogue block. If dialogue-like text appears without a character cue, it must be preserved as action or unknown with a diagnostic.

## Parenthetical Detection

A parenthetical is a standalone line inside a dialogue block that starts with `(` and ends with `)`. Parentheticals without a valid dialogue context are preserved as action or unknown with a diagnostic.

Malformed parentheticals such as `(whispering` must be preserved and reported. The parser must not drop following dialogue.

## Transition Detection

A transition is a standalone line matching known transition patterns or a Fountain forced transition marker. Supported examples include:

- `CUT TO:`
- `DISSOLVE TO:`
- `SMASH CUT TO:`
- `FADE IN:`
- `FADE OUT.`
- `CORTE A:`

Transition detection has higher priority than character detection because many transitions are uppercase.

## Shot Detection

Shot lines describe camera or framing intent and are classified separately from action when confidence is high. Supported examples include:

- `CLOSE ON:`
- `ANGLE ON:`
- `INSERT:`
- `POV:`
- `BACK TO SCENE`

Shot detection has lower priority than transition and character cue detection. Ambiguous uppercase lines that could be character names must use surrounding context.

## Note Detection

Fountain inline notes use `[[note text]]` and become `note` elements or note references. Notes must preserve Unicode text and may include TODO markers. Notes may later link to project `Note` records, but parsing must not require a notes database.

Lines beginning with `TODO:` may be classified as `note` when the parser option `treatTodoLinesAsNotes` is enabled. Otherwise they remain action text.

## Act, Sequence, and Page Breaks

Fountain sections use leading `#` characters and map to `section` elements. A section may represent an act, sequence, or outline heading depending on user text and future metadata.

Fountain synopsis lines using `=` are imported as section-supporting metadata or notes where supported. Explicit page breaks use `===` and map to `pageBreak` elements.

## Fountain Import Behavior

Fountain import delegates supported syntax mapping to `docs/editor/fountain-support-spec.md`. Import must produce semantic elements, preserve source text where possible, and attach diagnostics for unsupported constructs.

Fountain title-page metadata should map to project metadata when supported. Unsupported title-page fields must be preserved as import diagnostics or raw metadata rather than discarded.

## Fountain Export Behavior

Fountain export serializes semantic elements into supported Fountain syntax. Export may normalize whitespace and casing where required by the export preset, but it must preserve authored text content and Unicode.

Export is semantic-round-trip oriented, not byte-for-byte oriented. If an element has no supported Fountain representation, export must either emit a conservative plain-text representation or report a clear unsupported-export diagnostic.

## Round-Trip Expectations

Round-trip acceptance means importing supported Fountain, exporting it, and importing the export again yields equivalent semantic elements for supported constructs. Exact whitespace, blank-line count, title-page ordering, and unsupported markup are not guaranteed unless separately specified.

## Unicode And Spanish Support

The engine must preserve UTF-8 text, including accents, ñ, inverted punctuation, and non-English dialogue. Classification rules must not require ASCII-only names or English-only dialogue. Scene prefixes are initially English/Fountain-compatible, while location and time text may be Spanish or any Unicode text.

## Malformed Input Handling

Malformed input must be recoverable. The parser should:

- Preserve original text in `rawText` or equivalent.
- Emit stable diagnostics with source ranges where practical.
- Continue parsing subsequent blocks.
- Avoid creating false valid scenes from invalid headings.
- Avoid crashing on incomplete parentheticals, orphan dialogue, unclosed notes, or unsupported Fountain constructs.

## Required Examples

### Empty Script

Input:

```fountain
```

Expected elements: none.

Expected diagnostics: none, unless a calling workflow requires a warning for an empty screenplay.

### One-Scene Script

Input:

```fountain
INT. KITCHEN - DAY

A kettle screams on the stove.

MARIA
I cannot sleep.

CUT TO:
```

Expected sequence:

| Order | Kind | Text |
| --- | --- | --- |
| 1 | `sceneHeading` | `INT. KITCHEN - DAY` |
| 2 | `action` | `A kettle screams on the stove.` |
| 3 | `character` | `MARIA` |
| 4 | `dialogue` | `I cannot sleep.` |
| 5 | `transition` | `CUT TO:` |

### Multi-Scene Script

Input contains `EXT. PARK - MORNING` followed by `INT. CAR - CONTINUOUS`.

Expected behavior: two scene heading elements are created in document order, and derived scene records preserve that order.

### Script With Spanish Text

Input:

```fountain
EXT. ZOCALO - NOCHE

La ciudad respira bajo la lluvia.

NIÑA
(susurra)
¿Dónde está José?

CORTE A:
```

Expected behavior: `NIÑA`, `¿Dónde está José?`, and `CORTE A:` are preserved. `CORTE A:` is classified as `transition`.

### Script With Parentheticals

Input:

```fountain
JOSÉ
(en voz baja)
No mires atrás.
```

Expected sequence: character, parenthetical, dialogue.

### Script With Transitions

Input:

```fountain
FADE IN:

EXT. ROAD - NIGHT

A car appears.

DISSOLVE TO:
```

Expected behavior: `FADE IN:` and `DISSOLVE TO:` are transitions, not character cues.

### Script With Notes

Input:

```fountain
INT. ROOM - DAY

[[TODO: check this location name]]

The room is empty.
```

Expected behavior: the bracketed TODO is a note element and the surrounding text remains in order.

### Ambiguous Uppercase Line

Input:

```fountain
THIS IS PROBABLY IMPORTANT
but maybe it is action.
```

Expected behavior: classify as action or unknown with an ambiguity diagnostic. Do not create a character cue because the following block is not dialogue-compatible.

### Malformed Line Sequence

Input:

```fountain
INT HOUSE DAY

JOSE
(parenthetical without closing
We keep this text.
```

Expected behavior: preserve all text, report invalid scene heading and malformed parenthetical diagnostics, continue parsing later lines.

## Test Fixture Strategy

Parser executable specs should use committed text fixtures in `specs/fixtures/screenplay/` before adding broad randomized tests. Each fixture should have an expected classification document or executable test assertion once implementation begins.

Required fixture coverage:

- `simple.fountain`: one scene, action, character, dialogue, transition.
- `multi-scene.fountain`: multiple scene headings and repeated character dialogue.
- `spanish-unicode.fountain`: Unicode names, Spanish dialogue, Spanish transition.
- `malformed.fountain`: ambiguity, invalid scene heading, malformed parenthetical, note preservation.

## Known Limitations

- Full Final Draft FDX import/export is future work.
- Dual dialogue, lyrics, centered text, boneyard comments, and complex inline formatting are not required in the first parser contract.
- Scene heading localization is limited to Fountain-compatible prefixes; Spanish location/time text is supported.
- Byte-for-byte Fountain round-trip is not required.
- The spec does not define editor cursor behavior, TextKit integration, pagination, or PDF layout.

## Future FDX Boundary

FDX support must be a future import/export adapter that maps to the same semantic screenplay model. FDX must not become canonical storage, must not require SwiftData, and must not bypass `.dreamjotter` package persistence.
