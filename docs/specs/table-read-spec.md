# Table-Read Spec

Status: specified
Milestone: M3-M4
Traceability ID: TABLE-READ-001

## Purpose

Table-read support converts semantic screenplay content into an ordered read-aloud plan. It separates speaking parts from action and non-dialogue text so future Apple platform adapters can present read-aloud or text-to-speech features without embedding speech behavior in the portable core.

## Scope

Table-read support covers:

- Ordered speaking parts.
- Dialogue extraction.
- Action line separation.
- Character preservation.
- Non-dialogue scene handling.
- Future text-to-speech boundary.

## Principles

- Table-read data derives from semantic screenplay elements.
- The read plan must preserve document order.
- Character names and Unicode dialogue must be preserved.
- The portable core defines read order and roles, not speech synthesis.
- Future text-to-speech belongs in Apple or platform-specific adapters.
- Generating a read plan must not mutate project data.

## TableReadPlan

A table-read plan includes:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable plan ID. |
| `projectId` | Yes | Project source. |
| `screenplayId` | Yes | Screenplay source. |
| `generatedAt` | Yes | ISO-8601 timestamp. |
| `scenes` | Yes | Ordered scene read groups. |
| `speakingParts` | Yes | Ordered unique speaking parts. |
| `diagnostics` | No | Non-blocking warnings. |

The plan may be generated on demand and does not need to be canonical project state.

## Ordered Speaking Parts

Speaking parts are derived from semantic `character` cues with associated dialogue.

Rules:

- Preserve original character cue text such as `NIÑA`, `JOSÉ`, or `MARIA (V.O.)`.
- Keep first appearance order for default speaking-part order.
- Do not merge spelling variants automatically.
- Character metadata may enrich display names where available but must not replace authored cue text without explicit policy.

## Dialogue Extraction

Dialogue extraction groups dialogue lines under the nearest valid preceding character cue.

Read item fields:

| Field | Required | Purpose |
| --- | --- | --- |
| `elementId` | Yes | Source element. |
| `kind` | Yes | `dialogue`, `action`, `parenthetical`, `sceneHeading`, or `transition`. |
| `characterName` | No | Speaker for dialogue/parenthetical. |
| `text` | Yes | Text to read or display. |
| `sceneId` | No | Scene context. |
| `order` | Yes | Stable order in read plan. |

Parentheticals may be included as speaker direction according to future read settings.

## Action Line Separation

Action lines are separate read items from dialogue. They may be read by a narrator role in future adapters.

Rules:

- Action text remains in screenplay order.
- Scene headings may be read as scene headers.
- Transitions may be included or skipped according to future settings.
- Notes are excluded by default unless a writer-facing review mode includes them.

## Character Preservation

The plan must preserve authored character names and Unicode text.

Examples:

- `NIÑA` remains `NIÑA`.
- `JOSÉ` remains `JOSÉ`.
- Dialogue `¿Dónde está José?` remains unchanged.
- `MARIA (V.O.)` remains distinguishable from `MARIA` unless future alias policy maps it.

## Non-Dialogue Scene Handling

Scenes without dialogue still appear in the table-read plan when they contain action, headings, or other readable screenplay elements.

Rules:

- A scene with only action has no speaking parts but may have narrator items.
- Empty scenes may produce a scene group with diagnostics or be omitted according to future settings.
- Malformed dialogue-like content without character cue is not assigned to a speaker automatically.

## Future Text-To-Speech Boundary

Portable core defines table-read data only. It does not synthesize speech.

Future platform adapters may handle:

- Apple speech APIs.
- Voice selection.
- Playback controls.
- Timing and highlighting.
- Accessibility announcements.
- Audio export, if ever supported.

TTS adapters must consume `TableReadPlan` and must not become canonical screenplay storage.

## Given/When/Then Scenarios

### Ordered Speaking Parts

Given a screenplay has dialogue for `MARIA`, then `JOSÉ`, then `MARIA` again
When a table-read plan is generated
Then speaking parts are ordered as `MARIA`, `JOSÉ`
And repeated dialogue is grouped by source order, not duplicated in the speaking-part list.

### Dialogue Extraction

Given a character cue followed by dialogue
When a table-read plan is generated
Then the dialogue read item includes the character name and source element ID.

### Action Separation

Given a scene contains action before and after dialogue
When a table-read plan is generated
Then action items are separate from dialogue items
And their order is preserved.

### Character Preservation

Given dialogue is spoken by `NIÑA`
When a table-read plan is generated
Then the speaking part preserves `NIÑA` exactly.

### Non-Dialogue Scene

Given a scene contains only action lines
When a table-read plan is generated
Then the scene appears with narrator/action items
And no speaking part is invented.

## Non-Goals

- No production implementation.
- No text-to-speech implementation.
- No audio export.
- No voice casting UI.
- No AI-generated voices.
- No mutation of screenplay or character data.

## Related Specs

- `docs/editor/screenplay-engine-spec.md`
- `docs/data-contracts/core-domain-model.md`
- `docs/milestones/milestone-3-friendly-writer-tools.md`
