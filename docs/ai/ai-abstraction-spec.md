# AI Abstraction Spec

Status: specified
Milestone: M3-M4
Traceability IDs: M3-AI-ABSTRACTION-001, AI-ABSTRACTION-001

## Purpose

This spec defines DreamJotter's AI boundary through Milestone 4. It is provider-neutral and safety-first. It does not implement code, call external services, choose a real AI provider, or allow AI output to mutate user text directly.

## Scope

AI scope through Milestone 4 includes:

- Provider protocol concept.
- Fake provider for tests and executable specs.
- AIRequest.
- AIResponse.
- AISuggestion.
- Accept/reject flow.
- Snapshot before applying rewrite.
- Privacy expectations.
- Offline and AI-disabled behavior.

AI scope through Milestone 4 excludes:

- Real provider integration.
- External AI calls.
- API keys.
- Network access.
- Plugin-provided AI providers.
- Automatic mutation of user text.
- Training or telemetry behavior.

## No Real Provider Through Milestone 4

No real AI provider is allowed through Milestone 4. AI behavior is specified as contracts and may be tested with deterministic fake providers only. Any future real provider requires separate specs, privacy review, user consent design, and ADRs.

## Provider Protocol Concept

`AIProvider` is a future protocol-like boundary. It receives provider-neutral requests and returns provider-neutral responses.

Conceptual responsibilities:

- Accept `AIRequest` values.
- Return `AIResponse` values.
- Report disabled, unavailable, invalid request, timeout, malformed response, and safety refusal states.
- Avoid direct project mutation.
- Avoid command execution.
- Avoid storage writes.
- Be replaceable by `FakeAIProvider` in tests.

Conceptual non-responsibilities:

- No direct CommandEngine access.
- No direct `.dreamjotter` file access.
- No UI presentation.
- No snapshot creation.

## Fake Provider For Tests

`FakeAIProvider` is the only provider expected through Milestone 4 tests and executable specs.

Required behavior:

- Returns deterministic configured responses.
- Can simulate success, failure, disabled mode, unavailable mode, timeout, malformed response, and safety refusal.
- Never calls external services.
- Never reads files outside supplied request context.
- Never mutates project state.

Acceptance examples:

- Given FakeAIProvider is configured with a logline suggestion, when the request runs, then that configured suggestion is returned.
- Given FakeAIProvider is configured to fail, when a scene starter request runs, then a recoverable diagnostic is returned and project data remains unchanged.
- Given AI is disabled, when an AI request is attempted, then no provider call is made or a disabled response is returned by the local harness.

## AIRequest

`AIRequest` describes a bounded suggestion request.

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable request ID. |
| `kind` | Yes | `logline`, `synopsis`, `sceneStarter`, `rewrite`, `continuityWording`, or future safe kind. |
| `projectId` | Yes | Project context ID. |
| `targetReference` | No | Scene, note, selected text, logline, synopsis, or element target. |
| `context` | Yes | Minimal local context needed for the request. |
| `constraints` | No | Tone, length, format, language, or safety constraints. |
| `privacyLevel` | Yes | Intended privacy boundary such as `localOnly` through Milestone 4. |
| `createdAt` | Yes | ISO-8601 timestamp. |

Requests must use minimal context. They must not include entire projects by default when a smaller target is enough.

## AIResponse

`AIResponse` reports provider output or failure.

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable response ID. |
| `requestId` | Yes | Request this response answers. |
| `providerId` | Yes | Provider identifier such as `fake-ai-provider`. |
| `status` | Yes | `success`, `failed`, `disabled`, `unavailable`, `timeout`, `malformed`, or `refused`. |
| `suggestions` | No | One or more `AISuggestion` records. |
| `diagnostics` | No | Recoverable errors, warnings, or refusal reasons. |
| `completedAt` | Yes | ISO-8601 timestamp. |

A failed response must not create or apply project mutations.

## AISuggestion

`AISuggestion` is a proposed change or text draft that lives outside canonical project text until accepted.

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable suggestion ID. |
| `requestId` | Yes | Origin request. |
| `kind` | Yes | Suggestion kind. |
| `targetReference` | No | Intended project target. |
| `proposedText` | Yes | Suggested text or structured text payload. |
| `status` | Yes | `pending`, `accepted`, `rejected`, `expired`, or `failed`. |
| `diagnostics` | No | Safety, stale target, or validation warnings. |
| `createdAt` | Yes | ISO-8601 timestamp. |

Rules:

- Pending suggestions do not mutate user text.
- Rejected suggestions leave screenplay and project text unchanged.
- Accepted suggestions become command requests.
- Rewrite suggestions require snapshot before mutation.
- Suggestions targeting stale or missing objects fail safely.

## Accept/Reject Flow

Reject flow:

1. User rejects suggestion.
2. Suggestion status becomes `rejected`.
3. No project mutation occurs.
4. No snapshot is required.

Accept flow for non-mutating suggestions:

1. User accepts suggestion for a field or insertion target.
2. Target is validated.
3. CommandEngine receives an explicit command request.
4. CommandResult determines whether project data changed.

Accept flow for rewrites:

1. User accepts a rewrite suggestion.
2. Target and scope are validated.
3. CommandEngine creates a snapshot first.
4. If snapshot succeeds, CommandEngine applies the accepted rewrite command.
5. If snapshot fails, no rewrite mutation occurs.

## Snapshot Before Applying Rewrite

Any AI suggestion that changes canonical project content requires a snapshot before mutation.

Applies to:

- Screenplay text rewrites.
- Scene starter insertion that adds generated text.
- Synopsis rewrite.
- Logline rewrite.
- Note rewrite.

Snapshot metadata should record that the snapshot was created before accepted AI rewrite application.

## Privacy Expectations

Through Milestone 4:

- No external AI calls are allowed.
- No project content leaves the device for AI.
- No API keys are stored.
- No provider telemetry is defined.
- Fake provider context is local and deterministic.

Future provider work must define consent, prompt context boundaries, data retention, logging, offline behavior, disable controls, and privacy disclosure language.

## Offline And AI-Disabled Behavior

AI must be optional and disableable.

Rules:

- If AI is disabled, AI actions are unavailable or return disabled diagnostics.
- Offline mode behaves the same as disabled mode unless a future local provider is explicitly specified.
- Manual writing, logline editing, synopsis editing, beat sheets, notes, and screenplay editing must continue without AI.
- Existing suggestions remain viewable only if stored by future policy, but cannot auto-apply.

## Command Boundary

AI providers do not mutate. Accepted suggestions become explicit command requests, commonly `applyAISuggestion` through CommandEngine.

Expected command ordering for rewrites:

1. Validate suggestion target.
2. Create snapshot.
3. Apply accepted mutation command.
4. Record suggestion as accepted.
5. Preserve diagnostics if any step fails.

## Given/When/Then Scenarios

### AI Disabled

Given AI is disabled
When the writer requests a scene starter
Then no external service is called
And the response reports disabled or the action is unavailable.

### Reject Suggestion

Given an AI suggestion is pending
When the writer rejects it
Then screenplay text remains unchanged
And no snapshot is created.

### Accept Rewrite

Given an AI rewrite suggestion is pending
When the writer accepts it
Then CommandEngine creates a snapshot first
And applies the rewrite only if the snapshot succeeds.

### Fake Provider Failure

Given FakeAIProvider is configured to fail
When an AIRequest is sent
Then AIResponse reports failure with diagnostics
And project data remains unchanged.

## Testability

Future tests should verify:

- AI disabled mode makes no external calls.
- FakeAIProvider deterministic success.
- FakeAIProvider deterministic failure.
- Pending suggestion causes no mutation.
- Rejected suggestion causes no mutation.
- Accepted suggestion creates command request.
- Accepted rewrite requires snapshot first.
- Snapshot failure prevents rewrite mutation.
- Missing target fails safely.
- Malformed provider response produces diagnostics.

## Non-Goals

- No real provider implementation.
- No external service calls.
- No model selection.
- No prompt engineering for production providers.
- No plugin AI providers.
- No telemetry design.

## Related Specs

- `docs/milestones/milestone-3-friendly-writer-tools.md`
- `docs/architecture/command-engine-spec.md`
- `docs/acceptance/milestone-3-acceptance.md`
- `docs/constitution.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
