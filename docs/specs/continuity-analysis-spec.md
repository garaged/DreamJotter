# Continuity Analysis Spec

Status: implemented
Milestone: M3-M4
Traceability ID: CONTINUITY-ANALYSIS-001

## Purpose

Continuity analysis identifies likely story and project consistency issues without blocking writing or mutating project data. It should help writers notice mismatches while preserving creative control.

## Scope

Continuity analysis covers:

- Character spelling mismatch.
- Unknown character reference.
- Conflicting structured metadata.
- Unresolved TODOs.
- Friendly warning language.
- False-positive mitigation.

## Principles

- Findings are advisory, not authoritative.
- Analysis must not mutate project data.
- Incomplete drafts are normal and should not be treated as errors.
- Unicode and Spanish text are supported.
- Evidence should be linked to semantic elements or project records where practical.
- False positives should be mitigated through confidence levels and dismissible findings.

## Continuity Finding

A continuity finding includes:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable finding ID. |
| `ruleId` | Yes | Rule that produced the finding. |
| `severity` | Yes | `info`, `warning`, or `needsReview`. |
| `confidence` | Yes | `low`, `medium`, or `high`. |
| `message` | Yes | Friendly user-facing language. |
| `evidence` | Yes | Source references or text snippets. |
| `suggestedAction` | No | Non-mutating suggestion. |
| `createdAt` | Yes | ISO-8601 timestamp. |

## Character Spelling Mismatch

Detect likely spelling variants across character cues, metadata, notes, and references.

Examples:

- `JOSÉ` and `JOSE`.
- `MARIA` and `MARA` when used in similar contexts.
- `NIÑA` and `NINA` when accents may have been omitted.

Rules:

- Do not auto-merge names.
- Do not auto-rename cues.
- Preserve original spelling in evidence.
- Use confidence levels to avoid overstating uncertain matches.

## Unknown Character Reference

Detect references to names that are not known character records or detected cues.

Sources:

- Notes.
- Scene cards.
- Production breakdown entries.
- Custom fields.
- Structured story setup fields.

Rules:

- Do not require every mentioned person to be a character.
- Use friendly language such as “This name is not in your character list yet.”
- Provide source evidence.
- Do not create character records automatically.

## Conflicting Structured Metadata

Detect contradictions in structured project fields.

Examples:

- Scene card location differs from scene heading location.
- Character age field conflicts across custom fields.
- Production breakdown location differs from scene metadata.
- Scene status is `final` while open TODOs are attached to the scene.

Rules:

- Report conflicting values and source locations.
- Do not pick a winner automatically.
- Allow future dismissal or resolution commands without requiring them now.

## Unresolved TODOs

Continuity analysis may surface unresolved TODOs when they affect story clarity or production readiness.

Sources:

- Inline Fountain notes.
- Project notes.
- Scene notes.
- Character notes.

Rules:

- TODOs remain unchanged.
- TODO count can be shared with script analysis.
- Findings should distinguish TODO reminders from continuity contradictions.

## Friendly Warning Language

Warnings should be specific, calm, and actionable.

Good examples:

- “This scene mentions `Jose`, but your character list uses `JOSÉ`.”
- “This note references `LUCIA`, who is not in your character list yet.”
- “This scene is marked final, but it still has an open TODO.”

Avoid:

- “Invalid character.”
- “You made a mistake.”
- “Continuity failed.”

## False-Positive Mitigation

Mitigation strategies:

- Use confidence levels.
- Require evidence from more than one source for higher severity.
- Treat accents and case carefully rather than stripping meaning blindly.
- Allow findings to be dismissed later through commands.
- Do not block export or writing.
- Never crash on incomplete data.

## Given/When/Then Scenarios

### Character Spelling Mismatch

Given the screenplay contains `JOSE` and character metadata contains `JOSÉ`
When continuity analysis runs
Then it reports a medium-confidence spelling mismatch
And neither name is changed.

### Unknown Character Reference

Given a scene note references `LUCIA`
And no character cue or character record exists for `LUCIA`
When continuity analysis runs
Then it reports an unknown character reference
And no character is created.

### Conflicting Structured Metadata

Given a scene heading uses `EXT. PARK - DAY`
And the scene card location field says `HOSPITAL`
When continuity analysis runs
Then it reports conflicting location metadata with both values.

### Unresolved TODO

Given a scene has an open TODO note
When continuity analysis runs
Then it reports an unresolved TODO finding
And the TODO remains unresolved.

### No False Crash On Incomplete Data

Given a project has missing optional character metadata
When continuity analysis runs
Then analysis completes with diagnostics where needed
And the project remains unchanged.

## Non-Goals

- No automatic fixes.
- No AI calls.
- No mandatory continuity gate before export.
- No full natural-language story understanding.

## Related Specs

- `docs/specs/script-analysis-spec.md`
- `docs/ai/ai-abstraction-spec.md`
- `docs/milestones/milestone-3-friendly-writer-tools.md`
- `docs/data-contracts/core-domain-model.md`
