# Milestone 3 Acceptance

## Purpose

This file defines acceptance examples for Milestone 3: Friendly Writer Tools. These examples are covered by executable specs for the portable core. They do not require app UI, real AI providers, or external service calls.

## Acceptance Fixture Set

### A-M3-STORYSETUP-001: Guided Story Setup Without AI

Input:

```yaml
action: guided_story_setup
ai_enabled: false
title: The Last Light
protagonist: Lucia
goal: Find her missing brother
obstacle: A citywide blackout
```

Expected result:

- Story setup record is created from user-entered fields.
- Missing optional fields remain empty.
- No AI provider request is made.
- Project remains valid `.dreamjotter` data.

Given/When/Then:

- Given AI is disabled, when guided setup completes, then user-entered setup fields are saved and no provider is called.
- Given optional fields are skipped, when setup is saved, then the project remains valid.

Traceability: M3-STORYSETUP-001, M3-AI-ABSTRACTION-001.

### A-M3-LOGLINE-001: Manual Logline Builder

Input:

```yaml
action: update_logline
text: A young medic crosses a powerless city to find her brother before sunrise.
ai_enabled: false
```

Expected result:

- Logline text is stored as project metadata.
- No provider request is made.
- Logline can be searched later.

Given/When/Then:

- Given the user writes a logline manually, when it is saved, then the logline record updates through future command behavior.
- Given AI is disabled, when saving the logline, then no AI suggestion is created.

Traceability: M3-LOGLINE-001, M3-AI-ABSTRACTION-001.

### A-M3-SYNOPSIS-001: Synopsis Builder With Missing Setup Context

Input:

```yaml
action: update_synopsis
setup_fields_missing: true
synopsis: Lucia searches the city as the blackout reveals old secrets.
```

Expected result:

- Synopsis record is saved.
- Missing setup fields do not block synopsis editing.
- Synopsis remains user-authored text.

Given/When/Then:

- Given story setup fields are incomplete, when the user saves a synopsis, then the synopsis is stored without requiring generated text.

Traceability: M3-SYNOPSIS-001.

### A-M3-BEATS-001: Beat Sheet Template Application

Input:

```yaml
action: apply_beat_template
template: beginning-middle-end
```

Expected result:

- Three editable beat records are created.
- Beat sheet is optional project data.
- No screenplay scenes are created unless a future command explicitly does so.

Given/When/Then:

- Given the user applies a beat template, when the beat sheet is created, then editable beats exist and screenplay text remains unchanged.

Traceability: M3-BEATS-001.

### A-M3-SCENE-STARTER-001: Scene Starter Preview With FakeAIProvider

Input:

```yaml
action: request_scene_starter
provider: FakeAIProvider
target_scene: scene-001
fake_response: "Start with Lucia listening to the dark apartment breathe."
```

Expected result:

- FakeAIProvider returns deterministic suggestion text.
- Suggestion status is pending.
- Canonical screenplay text is unchanged.

Given/When/Then:

- Given FakeAIProvider returns a scene starter, when the user previews it, then no screenplay element is inserted.
- Given the user rejects it, when the project reloads, then the screenplay remains unchanged.

Traceability: M3-SCENESTARTER-001, M3-AI-SUGGESTION-001, M3-AI-ABSTRACTION-001.

### A-M3-AI-DISABLED-001: AI Optional And Disableable

Input:

```yaml
ai_enabled: false
action: request_ai_logline_suggestion
```

Expected result:

- No provider request is made.
- User-facing result says AI assistance is disabled or unavailable.
- Manual logline editing remains available.
- Project data is unchanged.

Given/When/Then:

- Given AI is disabled, when an AI suggestion is requested, then no provider call occurs and no project mutation occurs.

Traceability: M3-AI-ABSTRACTION-001, M3-AI-SUGGESTION-001.

### A-M3-AI-REJECT-001: Rejecting AI Suggestion Leaves Screenplay Unchanged

Input:

```yaml
original_text: "MARIA\nI am staying."
suggestion: "MARIA\nI will not leave."
action: reject_suggestion
```

Expected result:

- Suggestion status becomes rejected.
- Original screenplay text remains `MARIA\nI am staying.`
- No snapshot is required because no mutation occurs.

Given/When/Then:

- Given a pending rewrite suggestion, when the user rejects it, then screenplay text remains unchanged.

Traceability: M3-AI-SUGGESTION-001, M3-AI-REWRITE-001.

### A-M3-AI-ACCEPT-REWRITE-001: Applying AI Rewrite Requires Snapshot First

Input:

```yaml
original_text: "MARIA\nI am staying."
suggestion: "MARIA\nI will not leave."
action: accept_rewrite
snapshot_creation: succeeds
```

Expected result:

- Snapshot is created before rewrite mutation.
- Snapshot reason identifies AI rewrite acceptance.
- Rewrite applies only after snapshot succeeds.
- Suggestion status becomes accepted.

Given/When/Then:

- Given a pending rewrite suggestion, when the user accepts it and snapshot creation succeeds, then the snapshot is created before the rewrite command applies.

Traceability: M3-AI-REWRITE-001, M3-SNAPSHOT-AI-001, M2-SNAPSHOTS-001.

### A-M3-AI-SNAPSHOT-FAIL-001: Snapshot Failure Prevents AI Rewrite

Input:

```yaml
original_text: "MARIA\nI am staying."
suggestion: "MARIA\nI will not leave."
action: accept_rewrite
snapshot_creation: fails
```

Expected result:

- Rewrite does not apply.
- Original screenplay text remains unchanged.
- Suggestion remains pending or failed according to later command policy.
- Friendly warning explains that a recovery snapshot could not be created.

Given/When/Then:

- Given snapshot creation fails, when the user accepts an AI rewrite, then no rewrite mutation occurs.

Traceability: M3-SNAPSHOT-AI-001, M3-FRIENDLY-WARNINGS-001.

### A-M3-CONTINUITY-NAME-001: Character Name Spelling Mismatch

Input:

```yaml
characters:
  - JOSE
  - JOSÉ
```

Expected result:

- Continuity warning identifies possible spelling mismatch.
- Warning is advisory.
- Evidence references both names.
- No automatic merge or rename occurs.

Given/When/Then:

- Given character names differ only by accent, when continuity checks run, then a possible mismatch warning is produced and data remains unchanged.

Traceability: M3-CONTINUITY-001, M3-CHARACTER-CONSISTENCY-001.

### A-M3-CONTINUITY-UNKNOWN-CHARACTER-001: Scene References Unknown Character

Input:

```yaml
scene_card:
  scene_id: scene-002
  summary: Maria confronts Victor in the empty station.
known_characters:
  - MARIA
```

Expected result:

- Warning identifies `Victor` as a possible unknown character reference.
- Warning links to the scene card evidence.
- No character is created automatically.

Given/When/Then:

- Given scene material references a name not found in character records or cues, when continuity checks run, then an unknown character reference warning may be produced.

Traceability: M3-CONTINUITY-001, M3-CHARACTER-CONSISTENCY-001.

### A-M3-CONTINUITY-TODO-001: Unresolved TODO Note

Input:

```yaml
notes:
  - id: note-001
    body: "TODO: fix the ending motivation."
```

Expected result:

- Warning identifies unresolved TODO note.
- Warning links to the note.
- Warning uses friendly language and does not block writing.

Given/When/Then:

- Given a note contains TODO text, when continuity checks run, then an unresolved note warning is produced.

Traceability: M3-CONTINUITY-001, M3-FRIENDLY-WARNINGS-001, M2-NOTES-001.

### A-M3-CONTINUITY-CONFLICTING-METADATA-001: Conflicting Structured Metadata

Input:

```yaml
scene_heading: "INT. KITCHEN - NIGHT"
scene_metadata:
  time_of_day: DAY
```

Expected result:

- Warning identifies conflict between scene heading and structured metadata.
- Evidence references both the heading and metadata field.
- No automatic metadata correction occurs.

Given/When/Then:

- Given structured scene metadata conflicts with the scene heading, when continuity checks run, then a metadata conflict warning is produced.

Traceability: M3-CONTINUITY-001, M3-FRIENDLY-WARNINGS-001.

### A-M3-CONTINUITY-INCOMPLETE-DATA-001: No False Crash On Incomplete Data

Input:

```yaml
scene_cards:
  - id: scene-card-001
    source_scene_id: missing-scene
characters: null
notes:
  - id: note-001
    linked_to: missing-target
```

Expected result:

- Continuity checks complete without crashing.
- Diagnostics or warnings may report missing references.
- No invented character, scene, or note data is created.

Given/When/Then:

- Given incomplete project data, when continuity checks run, then checks complete safely with diagnostics and no mutation.

Traceability: M3-CONTINUITY-001, M3-FRIENDLY-WARNINGS-001, M2-HEALTH-001.

### A-M3-READALOUD-001: Table-Read/Read-Aloud Sequence Data

Input:

```text
INT. ROOM - NIGHT

The light flickers.

MARIA
We should go.

CUT TO:
```

Expected result:

- Read-aloud sequence follows document order.
- Action is narratable.
- Dialogue is associated with `MARIA`.
- Transition is represented as narratable or skippable according to later policy.
- No platform speech API is required.

Given/When/Then:

- Given semantic screenplay elements, when read-aloud sequence is generated, then ordered narratable records are produced without using platform speech APIs.

Traceability: M3-READALOUD-001, PRD-READALOUD-001.

### A-M3-FRIENDLY-WARNINGS-001: Friendly Warning Language

Input finding:

```yaml
rule_id: possible-character-spelling-mismatch
evidence:
  - JOSE
  - JOSÉ
```

Expected result:

- Warning title is short and understandable.
- Message uses uncertainty, such as `These names might refer to the same character.`
- Message avoids parser jargon and blame.
- Rule ID remains available for tests and advanced diagnostics.

Given/When/Then:

- Given a continuity finding, when warning text is generated, then the message is friendly, advisory, and linked to evidence.

Traceability: M3-FRIENDLY-WARNINGS-001, M3-CONTINUITY-001.

## Cross-Cutting Acceptance Rules

- No external AI calls are allowed.
- FakeAIProvider is used for tests and deterministic examples.
- AI disabled mode makes no provider calls.
- Pending suggestions must not mutate canonical text.
- Rejected suggestions leave screenplay and project text unchanged.
- Accepted rewrite suggestions require a successful snapshot before mutation.
- Continuity and warning generation are read-only.
- Friendly warnings are advisory and do not block writing.
- Incomplete data must produce diagnostics or no findings, never crashes or invented state.

## Deferred Acceptance

The following are explicitly deferred beyond Milestone 3 acceptance:

- Real AI providers.
- Network calls or API keys.
- Provider account management.
- Prompt telemetry or retention policies beyond local fake-provider tests.
- Full table-read UI.
- Actual speech playback implementation.
- Custom warning rule editor.
- Automatic character merging.
- Routines and plugins.
- Production app implementation.
