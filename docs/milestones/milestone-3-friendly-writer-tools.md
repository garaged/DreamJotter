# Milestone 3: Friendly Writer Tools

## Goal

Add beginner-friendly story-development tools and safe AI-assisted workflows without introducing real AI provider integration. Milestone 3 helps writers shape story material, receive advisory continuity feedback, prepare read-aloud behavior, and evaluate AI suggestions while preserving user control over canonical screenplay text.

Milestone 3 portable-core behavior is implemented and executable-spec verified. It does not create app UI, create an Xcode project, call external services, implement real AI providers, or introduce plugins.

## Scope Summary

Milestone 3 includes specifications for:

- Guided story setup.
- Logline builder.
- Synopsis builder.
- Beat sheet templates.
- Scene starter generation.
- AI abstraction with no real provider.
- AI suggestion workflow.
- AI rewrite safety.
- Snapshot before AI rewrite.
- Continuity warnings.
- Character consistency checks.
- Table-read/read-aloud data model.
- Friendly warning language.

## AI Safety Baseline

- No external AI calls are allowed in Milestone 3.
- AI behavior is provider-neutral and specified through an `AIProvider` concept.
- `FakeAIProvider` is the only provider expected for tests and executable specs.
- AI suggestions must not mutate user text until accepted.
- Rejecting an AI suggestion must leave the screenplay unchanged.
- Applying an AI rewrite must create a snapshot first.
- AI must be optional and disableable.
- AI-generated output is advisory until converted into an accepted command.

## Feature Specifications

### M3-STORYSETUP-001: Guided Story Setup

User story: As a beginner writer, I want guided prompts that help me start a story without needing to understand screenplay structure upfront.

Beginner behavior: Simple Mode asks for minimal story inputs such as title, format intent, genre or tone, protagonist, goal, obstacle, and optional logline. The user can skip any field except the project title policy defined later.

Advanced behavior: Advanced users may later choose setup templates, custom fields, beat structures, or metadata defaults. Milestone 3 keeps those controls optional and hidden unless Pro Mode enables them later.

Acceptance criteria:

- Guided setup produces normal project metadata and story-development records.
- Skipped fields remain empty or unknown without blocking project creation.
- Setup output does not create AI-generated text unless the user explicitly requests a suggestion.
- Setup can run for blank, short film, and feature film projects.
- Setup data remains editable after project creation.

Given/When/Then scenarios:

- Given a new user starts guided setup, when they enter title and protagonist, then project metadata and story setup fields are saved.
- Given the user skips obstacle and genre, when setup completes, then missing values are represented as empty fields and no error blocks creation.
- Given AI is disabled, when guided setup runs, then all prompts still work without AI suggestions.

Edge cases:

- User cancels setup.
- User enters Unicode names or bilingual story text.
- User changes project template after setup.
- Setup fields conflict with later custom fields.

Privacy implications: Setup fields may contain sensitive story ideas and must remain local project data unless a future explicit export or provider flow is accepted.

Data model implications: Requires story setup records with title, format intent, genre/tone, protagonist, goal, obstacle, optional audience, optional notes, and timestamps.

Command system implications: Future implementation should create or update story setup through commands such as `UpdateStorySetupCommand` so setup changes can be undone and traced.

Testability notes: Future tests should validate skipped fields, Unicode preservation, disabled-AI behavior, and template compatibility.

### M3-LOGLINE-001: Logline Builder

User story: As a writer, I want help shaping a concise logline that describes my story premise.

Beginner behavior: Simple Mode provides fields for protagonist, goal, obstacle, stakes, and a composed logline draft. The user can edit the final text directly.

Advanced behavior: Advanced users may later store multiple logline variants, compare versions, or prepare export-specific loglines.

Acceptance criteria:

- User can create and edit a logline without AI.
- Logline fields can compose a draft suggestion locally from user-entered text.
- Multiple variants are deferred unless explicitly enabled later.
- Logline text is project metadata and can be searched.
- AI-assisted logline suggestions follow the AI suggestion workflow and do not mutate saved logline text until accepted.

Given/When/Then scenarios:

- Given the user enters protagonist and goal, when they save the logline, then the logline record is stored in project metadata.
- Given AI is disabled, when the user edits the logline, then no provider request is made.
- Given a FakeAIProvider suggestion exists, when the user rejects it, then the saved logline remains unchanged.

Edge cases:

- Empty logline.
- Very long logline.
- Multiple languages.
- Spoiler-heavy text.
- AI suggestion does not fit user fields.

Privacy implications: Logline content is private local project data. AI-assisted logline generation must be disabled unless the user enables AI and accepts the suggestion flow.

Data model implications: Requires logline record with ID, text, structured fields, source, created/updated timestamps, and optional suggestion references.

Command system implications: Future implementation should save accepted logline edits through commands and leave rejected suggestions outside canonical state.

Testability notes: Tests should cover manual save, AI disabled, FakeAIProvider accepted suggestion, FakeAIProvider rejected suggestion, and Unicode text.

### M3-SYNOPSIS-001: Synopsis Builder

User story: As a writer, I want a place to develop a short synopsis from my story setup and scenes.

Beginner behavior: Simple Mode provides a plain synopsis editor with optional prompts for beginning, middle, and ending.

Advanced behavior: Advanced users may later manage multiple synopsis lengths, export targets, or draft-specific synopsis variants.

Acceptance criteria:

- User can create and edit synopsis text manually.
- Synopsis can reference story setup fields but does not require them.
- Synopsis can be searched.
- AI synopsis suggestions are optional and must be accepted before mutation.
- Rejecting an AI synopsis suggestion leaves saved synopsis text unchanged.

Given/When/Then scenarios:

- Given a project has story setup fields, when synopsis builder opens, then those fields may be shown as context without changing synopsis text.
- Given the user writes a synopsis manually, when saved, then the synopsis record is stored in project data.
- Given an AI suggestion is rejected, when synopsis is reloaded, then the previous saved synopsis remains.

Edge cases:

- Empty synopsis.
- Synopsis longer than expected.
- Story setup fields missing.
- Multiple languages.
- Conflicting scene summaries.

Privacy implications: Synopsis may reveal full plot and should remain local unless the user explicitly exports or later enables provider-backed AI.

Data model implications: Requires synopsis record with text, optional sections, source, timestamps, and optional linked story setup references.

Command system implications: Future commands should save manual synopsis edits and apply accepted AI suggestions as explicit mutations.

Testability notes: Tests should cover manual edits, missing setup context, rejected AI suggestions, and search indexing.

### M3-BEATS-001: Beat Sheet Templates

User story: As a writer, I want optional beat sheet templates that help me organize story beats without forcing a formula.

Beginner behavior: Simple Mode offers simple beat templates, such as beginning/middle/end or short film beats, with clear optional fields.

Advanced behavior: Advanced users may later create custom beat structures, link beats to scenes, or compare beat coverage across drafts.

Acceptance criteria:

- Beat sheet templates create editable beat records.
- User can skip, rename, reorder, or delete beats according to later command rules.
- Beats can link to scenes where scene IDs exist.
- Beat sheets remain optional and do not replace screenplay structure.
- Beat template definitions are not canonical project content until applied.

Given/When/Then scenarios:

- Given the user applies a beginning/middle/end template, when the beat sheet is created, then three editable beat records exist.
- Given a beat links to a scene, when the scene is opened, then the linked beat can be discovered by future UI behavior.
- Given the user deletes a scene linked to a beat, when validation runs, then the beat reports a missing scene link without crashing.

Edge cases:

- Beat without linked scene.
- Scene linked to multiple beats.
- Deleted linked scene.
- Template version changes.
- User rejects template after preview.

Privacy implications: Beat sheets are private story-planning data and should not be sent to providers in Milestone 3.

Data model implications: Requires beat sheet records, beat records, template ID/version, optional scene links, status, and timestamps.

Command system implications: Future implementation should create, edit, link, reorder, and delete beats through commands.

Testability notes: Tests should cover template application, optional scene links, missing link diagnostics, and Unicode beat text.

### M3-SCENESTARTER-001: Scene Starter Generation

User story: As a beginner writer, I want optional prompts that help me start a scene when I am stuck.

Beginner behavior: Simple Mode can suggest non-destructive scene starter ideas based on user-provided context, existing scene card summaries, or beat records. Suggestions are presented as draft ideas, not automatic script text.

Advanced behavior: Advanced users may later request multiple variants, tone controls, or command-based insertion. Milestone 3 only defines safe suggestion behavior.

Acceptance criteria:

- Scene starter generation works with FakeAIProvider only in tests and no external AI provider.
- Generated starters are suggestions outside canonical screenplay text until accepted.
- Rejecting a starter leaves screenplay and scene cards unchanged.
- Accepting a starter must become an explicit command in future implementation.
- If accepting generated screenplay text would rewrite or materially insert content, snapshot policy must be evaluated first.

Given/When/Then scenarios:

- Given AI is disabled, when the user requests a scene starter, then the action is unavailable or uses non-AI local prompts only.
- Given FakeAIProvider returns a starter, when the user previews it, then canonical screenplay text remains unchanged.
- Given the user rejects the starter, when the document reloads, then no generated text appears in the screenplay.

Edge cases:

- Empty context.
- Provider unavailable.
- Suggestion conflicts with scene metadata.
- Suggestion contains unsupported screenplay syntax.
- User accepts into a deleted scene.

Privacy implications: Scene context must not leave the device in Milestone 3. Future provider specs must define prompt boundaries and user consent.

Data model implications: Requires suggestion records or transient suggestion state with ID, source context, generated text, provider ID, created date, status, and target reference.

Command system implications: Accepting a starter should map to an insert or update command; rejecting should require no command and no canonical mutation.

Testability notes: Tests should use FakeAIProvider to assert preview, accept, reject, disabled AI, and missing target behavior.

### M3-AI-ABSTRACTION-001: AI Abstraction, No Real Provider

User story: As a maintainer, I want AI behavior specified behind a provider-neutral boundary so future provider choices do not leak into core product logic.

Beginner behavior: Users should not need to understand providers. AI is optional and may be disabled entirely.

Advanced behavior: Advanced users may later choose providers, local-only options, or privacy modes. Milestone 3 only defines conceptual boundaries.

Acceptance criteria:

- `AIProvider` is defined conceptually as an interface for suggestion requests and responses.
- `FakeAIProvider` is defined for tests and deterministic examples.
- No external AI calls are allowed.
- Provider responses are suggestions, not canonical mutations.
- Provider errors are recoverable and do not corrupt project data.

Given/When/Then scenarios:

- Given AI is disabled, when an AI feature is requested, then no provider is called.
- Given FakeAIProvider is configured with a response, when a suggestion is requested, then the deterministic response is returned as a suggestion.
- Given provider failure, when a suggestion is requested, then a friendly recoverable error is returned and project data remains unchanged.

Edge cases:

- Provider disabled.
- Provider timeout simulated by FakeAIProvider.
- Empty prompt context.
- Malformed provider response.
- Duplicate suggestions.

Privacy implications: Milestone 3 AI is local-only conceptual behavior. Future real providers require explicit privacy specs, user consent, and data boundary ADRs.

Data model implications: Requires suggestion request/response models, provider ID, suggestion ID, target reference, status, and diagnostics.

Command system implications: AI providers never mutate directly. Accepted suggestions become commands; rejected suggestions produce no project mutation.

Testability notes: FakeAIProvider should support deterministic success, failure, empty response, and malformed response scenarios in future tests.

### M3-AI-SUGGESTION-001: AI Suggestion Workflow

User story: As a writer, I want AI help to appear as optional suggestions that I can accept, reject, or ignore.

Beginner behavior: Simple Mode labels suggestions in friendly language and offers clear accept/reject actions.

Advanced behavior: Advanced users may later inspect prompt context, provider diagnostics, or compare variants. Milestone 3 keeps advanced controls deferred.

Acceptance criteria:

- Suggestion status can be pending, accepted, rejected, expired, or failed.
- Pending suggestions do not change canonical screenplay or project text.
- Accepting a suggestion applies a future command and records the accepted source.
- Rejecting a suggestion leaves canonical data unchanged.
- Ignored or expired suggestions do not block writing.

Given/When/Then scenarios:

- Given a pending suggestion, when the user rejects it, then screenplay text remains unchanged.
- Given a pending suggestion, when the user accepts it, then a future command applies the change through the command boundary.
- Given a suggestion target no longer exists, when the user accepts it, then the accept action fails safely with a friendly warning.

Edge cases:

- Target deleted before accept.
- Multiple suggestions for same target.
- Suggestion generated from stale context.
- User closes project with pending suggestions.
- Suggestion contains malformed screenplay text.

Privacy implications: Suggestion records may include generated text and prompt context; storage policy must avoid retaining sensitive prompt context unless specified.

Data model implications: Requires suggestion lifecycle records, target references, generated content, status, diagnostics, and optional prompt-context hash rather than full prompt storage where possible.

Command system implications: Accepting suggestions must map to explicit commands. Rejection and expiration should not mutate screenplay content.

Testability notes: Tests should assert no mutation before accept, no mutation on reject, safe failure on missing targets, and command creation on accept.

### M3-AI-REWRITE-001: AI Rewrite Safety

User story: As a writer, I want rewrite assistance to be safe, reversible, and never silently overwrite my words.

Beginner behavior: Simple Mode shows rewrite suggestions as previews and requires explicit acceptance before changes apply.

Advanced behavior: Advanced users may later request rewrite scope, compare variants, or tune tone. Milestone 3 defines safety rules only.

Acceptance criteria:

- Rewrite suggestions are previews until accepted.
- Rejecting a rewrite leaves the screenplay unchanged.
- Applying a rewrite requires a snapshot first.
- Rewrite scope must be explicit: selected text, scene, note, synopsis, or logline.
- A rewrite may not directly mutate project state from provider output.

Given/When/Then scenarios:

- Given selected dialogue, when rewrite is requested, then a suggestion preview is created and original dialogue remains unchanged.
- Given the user rejects the rewrite, when the project reloads, then original dialogue remains.
- Given the user accepts the rewrite, when no snapshot exists for the operation, then snapshot creation is required before mutation.

Edge cases:

- Empty selection.
- Scope changed after suggestion generation.
- Snapshot creation fails.
- Rewrite target deleted.
- Rewrite changes screenplay syntax unexpectedly.

Privacy implications: Rewrite prompts can contain user text. Milestone 3 forbids external calls and future provider specs must require consent and visible scope.

Data model implications: Requires rewrite suggestion records with original target reference, proposed text, scope, status, and snapshot requirement state.

Command system implications: Accepting a rewrite requires `CreateSnapshotCommand` before the mutation command. Provider output cannot bypass commands.

Testability notes: Tests should verify unchanged text before accept, unchanged text after reject, snapshot requirement before accept, and safe failure when snapshot cannot be created.

### M3-SNAPSHOT-AI-001: Snapshot Before AI Rewrite

User story: As a writer, I want an automatic recovery point before any AI rewrite changes my project.

Beginner behavior: Simple Mode explains in friendly language that DreamJotter saves a recovery snapshot before applying AI rewrites.

Advanced behavior: Advanced users may later configure snapshot names or retention. Milestone 3 requires the safety policy but not retention controls.

Acceptance criteria:

- Applying an AI rewrite requires successful snapshot creation first.
- Snapshot metadata identifies the reason as AI rewrite acceptance.
- If snapshot creation fails, the rewrite is not applied.
- Snapshot creation uses `.dreamjotter` canonical project data.
- Snapshot policy applies to screenplay text, notes, synopsis, logline, and scene starters when they materially insert or rewrite content.

Given/When/Then scenarios:

- Given an accepted rewrite, when snapshot creation succeeds, then the rewrite command may proceed.
- Given snapshot creation fails, when the user accepts the rewrite, then no rewrite mutation occurs.
- Given AI is disabled, when rewrite is requested, then no snapshot is created because no rewrite suggestion is generated.

Edge cases:

- Disk full.
- Package permission denied.
- Snapshot name collision.
- Multiple accepted rewrites in sequence.
- Project modified during snapshot.

Privacy implications: Snapshots may contain sensitive pre-rewrite content and remain local `.dreamjotter` data.

Data model implications: Requires snapshot reason metadata, source operation ID, created date, and rewrite target references.

Command system implications: Snapshot command must complete before the rewrite mutation command. The operation should be atomic from the user's perspective where possible.

Testability notes: Tests should cover success, snapshot failure, no mutation on failure, and multiple rewrite acceptances.

### M3-CONTINUITY-001: Continuity Warnings

User story: As a writer, I want friendly warnings about likely story inconsistencies without being blocked from writing.

Beginner behavior: Simple Mode displays warnings in plain language with links to relevant script or project material.

Advanced behavior: Advanced users may later configure rules, severity, and false-positive dismissal. Milestone 3 defines warning types and safe behavior.

Acceptance criteria:

- Continuity warnings are advisory and never block writing or saving.
- Warnings include stable rule ID, friendly message, severity, evidence references, and optional suggested action.
- Incomplete data must not crash continuity checks.
- Required examples include character name spelling mismatch, scene references unknown character, unresolved TODO note, and conflicting structured metadata.
- Users can ignore warnings without project mutation unless a future dismissal command is defined.

Given/When/Then scenarios:

- Given character names `JOSE` and `JOSÉ`, when continuity checks run, then a possible spelling mismatch warning is produced.
- Given a scene card mentions `MARIA` but no character record or cue exists, when checks run, then an unknown character reference warning is produced.
- Given a note contains `TODO: fix ending`, when checks run, then an unresolved TODO note warning is produced.
- Given scene metadata says `DAY` while the scene heading says `NIGHT`, when checks run, then a conflicting metadata warning is produced.
- Given incomplete scene and character data, when checks run, then diagnostics may be produced but no crash occurs.

Edge cases:

- Intentional name variants.
- Bilingual names.
- Nicknames.
- Incomplete scene cards.
- Deleted linked notes.

Privacy implications: Continuity checks run on local project data in Milestone 3 and should not send screenplay content externally.

Data model implications: Requires continuity finding records with rule ID, severity, message, evidence references, source type, and optional dismissed state later.

Command system implications: Warning generation is read-only. Future fixes suggested by warnings must be applied through commands.

Testability notes: Tests should include all required continuity examples and assert no crash on incomplete data.

### M3-CHARACTER-CONSISTENCY-001: Character Consistency Checks

User story: As a writer, I want help catching character name inconsistencies without the app forcing corrections.

Beginner behavior: Simple Mode shows possible duplicates or spelling variants as gentle suggestions.

Advanced behavior: Advanced users may later manage aliases, merge characters, or define intentional variants. Milestone 3 does not merge automatically.

Acceptance criteria:

- Checks compare character cues, character records, scene card references, notes, and story setup fields where available.
- Possible matches are warnings, not automatic changes.
- Unicode and accents are preserved in evidence.
- No warning should delete, merge, or rename characters.
- Incomplete character data does not crash checks.

Given/When/Then scenarios:

- Given `JOSE` appears in dialogue and `JOSÉ` appears in notes, when checks run, then a possible spelling mismatch warning appears.
- Given `DR. ANA` and `ANA` both appear, when checks run, then the system may flag a possible alias depending on future rules.
- Given character data is empty, when checks run, then no crash occurs and no invented character is created.

Edge cases:

- Accents.
- Nicknames.
- Titles.
- Character aliases.
- Same actor playing multiple roles.

Privacy implications: Character consistency checks are local-only in Milestone 3.

Data model implications: Uses character records, cue references, note references, and warning findings; alias records are deferred.

Command system implications: Merge, rename, or alias creation actions must be explicit future commands.

Testability notes: Tests should cover accent variants, titles, no data, and no automatic mutation.

### M3-READALOUD-001: Table-Read/Read-Aloud Data Model

User story: As a writer, I want the screenplay to have enough structure for a future read-aloud or table-read experience.

Beginner behavior: Simple Mode can later read script flow in order using available platform speech, but Milestone 3 only defines data needs.

Advanced behavior: Advanced users may later assign voices, roles, pacing, or export read-aloud scripts. Milestone 3 reserves role and voice preference data.

Acceptance criteria:

- Read-aloud order derives from semantic screenplay elements.
- Dialogue is associated with character cues where detectable.
- Action and transitions are represented as narratable elements.
- Voice assignment data is optional and not required for basic read order.
- Platform speech APIs are adapter concerns, not portable core requirements.

Given/When/Then scenarios:

- Given a scene with action and dialogue, when read-aloud sequence is generated, then elements appear in document order.
- Given dialogue follows `MARIA`, when sequence is generated, then dialogue is associated with MARIA's role.
- Given a character has no voice assignment, when sequence is generated, then default voice policy can be applied later without data loss.

Edge cases:

- Dual dialogue.
- Parentheticals.
- Missing character cue.
- Transition lines.
- Non-dialogue notes excluded from read-aloud.

Privacy implications: Read-aloud data is local project structure. Future platform speech may process text through OS services and must be specified separately.

Data model implications: Requires read-aloud sequence records or derived view models, role references, optional voice preferences, and narratable element types.

Command system implications: Voice assignment changes, if implemented later, should be commands. Sequence generation is read-only.

Testability notes: Tests should verify document order, role association, missing voice fallback, and exclusion of notes.

### M3-FRIENDLY-WARNINGS-001: Friendly Warning Language

User story: As a beginner writer, I want warnings to be understandable and encouraging without technical jargon.

Beginner behavior: Warnings use plain language, identify the issue, explain why it may matter, and offer a next step without blocking the writer.

Advanced behavior: Advanced users may later inspect rule IDs, severity, and evidence details. Milestone 3 keeps rule metadata available but does not require advanced UI.

Acceptance criteria:

- Warning messages avoid blame and technical parser jargon.
- Each warning has a short title, friendly message, optional evidence, and optional suggested action.
- Warnings are advisory unless a future destructive operation requires confirmation.
- Warning language supports localization later by separating rule ID from message text.
- Incomplete data warnings explain uncertainty rather than presenting false certainty.

Given/When/Then scenarios:

- Given a spelling mismatch warning, when shown to a beginner, then the message says the names may refer to the same character rather than saying the script is invalid.
- Given incomplete data, when a warning is generated, then the message uses uncertainty such as `might` or `could`.
- Given an unresolved TODO note, when shown, then the warning links to the note and describes it as unfinished work.

Edge cases:

- False positives.
- Intentionally experimental scripts.
- Localization.
- Multiple warnings for same evidence.
- User dismisses warning later.

Privacy implications: Warning text should not expose hidden notes in exported contexts unless the user chooses to export report content.

Data model implications: Requires warning finding records separate from localized display text and evidence references.

Command system implications: Warning generation is read-only. Future dismiss or fix actions must be commands.

Testability notes: Tests should assert warning content shape, rule IDs, evidence references, and no mutation.

## Milestone 3 Exit Criteria

Milestone 3 is ready for implementation only when later prompts have produced data contracts for story setup, loglines, synopsis, beat sheets, AI suggestions, continuity findings, character consistency findings, and read-aloud sequence data.

Milestone 3 is complete when future implementation can demonstrate:

- Guided story setup without AI.
- Logline and synopsis creation manually.
- Beat sheet template application.
- Scene starter suggestion preview with FakeAIProvider.
- AI disabled mode with no provider calls.
- Accepted-only AI mutation policy.
- No mutation on AI rejection.
- Snapshot required before accepted AI rewrite.
- Continuity warnings for required examples.
- No crash on incomplete continuity data.
- Character consistency advisory checks.
- Read-aloud sequence data from semantic screenplay elements.
- Friendly warning message records.

## Deferred Work

Milestone 3 does not include real AI providers, network calls, provider account setup, cloud sync, plugin runtime, routines, full Pro Mode controls, final table-read UI, actual speech playback implementation, custom warning rule editing, or production app implementation.
