# M13 Paragraph, Cue, and Autocomplete Hardening

Status: implemented pending automated build validation and manual acceptance.

## Problem

Editor styling, semantic parsing, and PDF rendering must never disagree about a paragraph's screenplay type. The observed Print Script regression showed prose after a dialogue block rendered in the narrow dialogue column. Character cue suggestions also treated a whole cue as one prefix, preventing reliable combined-speaker cues and requiring mouse clicks to accept suggestions.

## Invariants

1. One paragraph-boundary engine feeds editor selection, editor styling, parsing safeguards, and printing semantics.
2. Explicit paragraph markers always win.
3. Ambiguous unmarked prose resolves to Action.
4. A completed dialogue block cannot assign Dialogue to a later paragraph.
5. Combined cues remain one cue while exposing each speaker as an individual character.
6. Autocomplete changes only the active cue or scene-heading segment.
7. Keyboard acceptance happens before Smart Enter or Tab element cycling.
8. The selected paragraph type always exposes novice-oriented usage guidance.

## Paragraph boundaries

Paragraphs are separated by one or more blank lines. CRLF, CR, Unicode line separators, and Unicode paragraph separators are normalized before boundary resolution. Source ranges are UTF-16 ranges compatible with TextKit.

## Dialogue ownership

A cue may own contiguous parenthetical and dialogue lines in its paragraph block. A blank paragraph ends that ownership. The parser compatibility adapter inserts a transient Action marker only when legacy parser state could otherwise leak from a completed dialogue block into following prose. Transient markers are never written back to editor text.

## Combined character cues

Supported input separators:

- `/`
- `&`
- `+`
- `AND`
- Spanish `Y`

Canonical output separator: ` / `.

Examples:

```text
SOFÍA / TOM
ÍÑIGO / DOÑA ÁNGELES
MARA / ELENA
```

Combined cues render and print as one Character Cue. Character indexing registers each normalized name individually.

## Cue suggestions

Suggestion matching is case- and accent-insensitive. Ranking order:

1. exact match
2. full-name prefix
3. individual-word prefix
4. contained text

Duplicate character records collapse to one suggestion. Names already present in a combined cue are excluded. In `SOFÍA / TO`, accepting `TOM` replaces only `TO`.

## Scene heading suggestions

Scene heading completion is staged because a heading contains several semantic parts:

1. heading prefix, such as `INT.`, `EXT.`, or `INT./EXT.`
2. location, using previously parsed project locations
3. the ` - ` separator
4. localized time of day

Each accepted suggestion replaces only its active segment. Accepting a location automatically appends the separator so the next suggestion stage can offer time-of-day values. Location matching is case- and accent-insensitive. Time suggestions follow the configured screenplay language.

## Keyboard autocomplete

Autocomplete commands are handled by the focused TextKit editor rather than the surrounding SwiftUI hierarchy.

- Down Arrow: next suggestion
- Up Arrow: previous suggestion
- Return: accept active suggestion
- Tab: accept active suggestion
- Escape: dismiss suggestions

Return and Tab accept a visible suggestion before invoking Smart Enter or element-kind cycling. Mouse acceptance remains supported.

## Formatting guide

The paragraph inspector provides contextual syntax for the current type and an expandable complete guide. Each editable type has exactly one marker, example, and explanation. The guide states that markers are editor syntax and do not appear in PDF output.

At the bottom of the Paragraph Type section, the selected type exposes a small **How to use this type** explanation. Guidance must distinguish novice-confusing concepts, including Action versus Dialogue, Character Introduction versus later Action, Synopsis versus screenplay Action, and Shot or Page Break versus normal automatic layout.

## Deterministic regression requirements

- Reproduce the Print Script pattern: dialogue followed by long prose; prose must be Action and body width.
- Verify shared paragraph ranges between inspector selection and style runs.
- Verify all explicit markers have deterministic precedence.
- Verify mixed newline and blank-line normalization.
- Verify combined cue parsing, character registration, and PDF roles.
- Verify active cue segment replacement and suggestion ranking.
- Verify staged scene-heading prefix, location, and time completion.
- Verify keyboard commands are routed through the focused TextKit view.
- Verify selected paragraph usage guidance exists for every editable type.
