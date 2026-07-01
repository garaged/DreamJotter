# Milestone 1 Acceptance

## Purpose

This file defines acceptance examples for Milestone 1: Apple Prototype Foundations. These examples are covered by executable specs for the portable core. They do not require production app code, app UI, TextKit integration, or an Xcode project.

## Acceptance Fixture Set

### A-M1-EMPTY-001: Empty Screenplay

Input:

```text

```

Expected result:

- Produces a valid screenplay document.
- Contains zero screenplay elements.
- Produces no fatal parse error.
- Produces an empty scene list.
- Produces no character autocomplete candidates.
- Produces no location autocomplete candidates.

Given/When/Then:

- Given empty screenplay text, when the parser runs, then it returns an empty semantic screenplay document.
- Given an empty semantic screenplay document, when scene list generation runs, then it returns no scene items.
- Given an empty semantic screenplay document, when PDF export intent is requested, then it returns either a valid empty-document export intent or a clear non-fatal diagnostic according to later export rules.

Traceability: M1-MODEL-001, M1-PARSER-001, M1-SCENELIST-001, M1-PDF-001.

### A-M1-ONE-SCENE-001: One-Scene Screenplay

Input:

```text
INT. KITCHEN - DAY

A kettle screams on the stove.

MARIA
I cannot sleep.

CUT TO:
```

Expected result:

- Detects one scene heading: `INT. KITCHEN - DAY`.
- Detects one action element: `A kettle screams on the stove.`
- Detects one character cue: `MARIA`.
- Detects one dialogue element: `I cannot sleep.`
- Detects one transition: `CUT TO:`.
- Scene list contains one item in document order.
- Character autocomplete candidates include `MARIA`.
- Location autocomplete candidates include `KITCHEN`.

Given/When/Then:

- Given this one-scene screenplay, when parsed, then semantic elements are emitted in source order.
- Given parsed elements, when scene list generation runs, then one scene item references the scene heading element.
- Given parsed elements, when character autocomplete candidates are generated, then `MARIA` appears once.
- Given parsed elements, when location autocomplete candidates are generated, then `KITCHEN` appears once.

Traceability: M1-PARSER-001, M1-SCENELIST-001, M1-CHARACTER-001, M1-LOCATION-001.

### A-M1-MULTI-SCENE-001: Multi-Scene Screenplay

Input:

```text
EXT. PARK - MORNING

Birds scatter from the grass.

ANA
We are late.

INT. CAR - CONTINUOUS

The engine refuses to start.

ANA
Try again.
```

Expected result:

- Detects two scene headings.
- Scene list order is `EXT. PARK - MORNING`, then `INT. CAR - CONTINUOUS`.
- Detects `ANA` as one character autocomplete candidate despite repeated cues.
- Location candidates include `PARK` and `CAR`.
- Dialogue detection associates the dialogue lines with nearby character cues according to later model rules.

Given/When/Then:

- Given this multi-scene screenplay, when parsed, then all semantic elements preserve source order.
- Given parsed scene headings, when scene list generation runs, then two scene items appear in document order.
- Given repeated character cues, when character candidates are generated, then duplicate suggestions are collapsed.

Traceability: M1-MODEL-001, M1-PARSER-001, M1-SCENELIST-001, M1-CHARACTER-001, M1-LOCATION-001.

### A-M1-UNICODE-001: Spanish And Unicode Screenplay Text

Input:

```text
EXT. ZOCALO - NOCHE

La ciudad respira bajo la lluvia.

NIÑA
¿Dónde está José?

CORTE A:
```

Expected result:

- Preserves Spanish punctuation and accented characters.
- Detects `EXT. ZOCALO - NOCHE` as a scene heading.
- Detects `NIÑA` as a character cue.
- Detects `¿Dónde está José?` as dialogue text.
- Detects `CORTE A:` as a transition.
- Location candidates include `ZOCALO`.
- No ASCII-only normalization corrupts text.

Given/When/Then:

- Given Spanish and Unicode screenplay text, when parsed, then original text is preserved in each semantic element.
- Given `NIÑA` followed by dialogue, when character candidates are generated, then `NIÑA` appears as a valid candidate.
- Given `CORTE A:`, when transition detection runs, then it is classified as a transition or transition candidate according to supported rules.

Traceability: M1-MODEL-001, M1-PARSER-001, M1-CHARACTER-001, M1-LOCATION-001.

### A-M1-MALFORMED-001: Malformed Screenplay Text

Input:

```text
THIS IS PROBABLY IMPORTANT
but maybe not dialogue

INT HOUSE DAY

MAYBE CUT TO THE NEXT THING
```

Expected result:

- Preserves every source line.
- Does not crash or fail the whole parse.
- Emits diagnostics for ambiguous uppercase text and malformed scene heading text.
- Does not force `MAYBE CUT TO THE NEXT THING` into a transition without a supported transition pattern.
- Produces semantic elements as action, unknown, or diagnostic-bearing elements according to later parser rules.

Given/When/Then:

- Given malformed screenplay text, when parsed, then no source text is discarded.
- Given ambiguous uppercase lines, when parser classification is uncertain, then diagnostics are emitted.
- Given malformed scene-like text, when scene list generation runs, then no valid scene item is required unless parser rules classify it as a scene heading candidate.

Traceability: M1-MODEL-001, M1-PARSER-001, M1-GUARDRAILS-001.

### A-M1-CHARACTER-DIALOGUE-001: Character Dialogue Detection

Input:

```text
INT. ROOM - NIGHT

JOSE
(sotto)
We have one chance.
```

Expected result:

- Detects `JOSE` as a character cue.
- Detects `(sotto)` as a parenthetical.
- Detects `We have one chance.` as dialogue.
- Character autocomplete candidates include `JOSE`.

Given/When/Then:

- Given a character cue followed by a parenthetical and text, when parsed, then the three lines become character cue, parenthetical, and dialogue elements.
- Given the parsed character cue, when autocomplete candidates are generated, then `JOSE` is included.

Traceability: M1-PARSER-001, M1-CHARACTER-001.

### A-M1-SCENE-HEADING-001: Scene Heading Detection

Input:

```text
INT./EXT. TRAIN - SUNSET

The doors slide open.
```

Expected result:

- Detects `INT./EXT. TRAIN - SUNSET` as a scene heading.
- Detects `The doors slide open.` as action.
- Scene list contains one item.
- Location candidates include `TRAIN`.

Given/When/Then:

- Given a common mixed interior/exterior prefix, when parsed, then the line is classified as a scene heading.
- Given the parsed scene heading, when scene list generation runs, then one scene item is returned.

Traceability: M1-PARSER-001, M1-SCENELIST-001, M1-LOCATION-001.

### A-M1-TRANSITION-001: Transition Detection

Input:

```text
INT. OFFICE - DAY

The phone rings.

FADE OUT.
```

Expected result:

- Detects `INT. OFFICE - DAY` as a scene heading.
- Detects `The phone rings.` as action.
- Detects `FADE OUT.` as a transition.
- Does not add `FADE OUT.` as a character autocomplete candidate.

Given/When/Then:

- Given a standalone supported transition line, when parsed, then it is classified as a transition.
- Given parsed transition elements, when character autocomplete candidates are generated, then transition text is excluded.

Traceability: M1-PARSER-001, M1-CHARACTER-001.

## Cross-Cutting Acceptance Rules

- Original text must be preserved for every parsed element, including malformed or ambiguous content.
- Semantic element order must match source order.
- Diagnostics must be non-fatal when the source can be preserved.
- Unicode text must not be degraded by parsing, export intent, scene list, character candidates, or location candidates.
- Parser results must be testable without app UI.
- Scene list, character autocomplete, and location autocomplete must derive from semantic model data.
- PDF export behavior in Milestone 1 is export intent only; actual PDF bytes are not required.

## Deferred Acceptance

The following are explicitly deferred beyond Milestone 1 acceptance:

- Final editor UI interactions.
- Full TextKit/AppKit/UIKit integration.
- Full Fountain grammar and byte-identical round trips.
- Full PDF rendering and pagination.
- Snapshot/versioning implementation.
- Scene cards.
- Character profiles and aliases.
- Production breakdown.
- Export presets.
- Routines.
- Plugins.
- Real AI provider integration.
