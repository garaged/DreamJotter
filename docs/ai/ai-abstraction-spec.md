# AI Abstraction Spec

## Purpose

This spec defines DreamJotter's Milestone 3 AI boundary. It is conceptual and provider-neutral. It does not implement code, call external services, or choose a real AI provider.

## Scope

Milestone 3 AI scope includes:

- AIProvider conceptual behavior.
- FakeAIProvider for deterministic tests and executable specs.
- AI disabled mode.
- Suggestion request and response concepts.
- Accepted-only mutation policy.
- Snapshot-before-rewrite policy.
- Privacy and storage boundaries.

Milestone 3 AI scope excludes:

- External AI provider calls.
- API keys.
- Network access.
- Real model selection.
- Plugin-based AI providers.
- Automatic mutation of user text.

## AIProvider Concept

`AIProvider` is a future protocol-like boundary. It represents a component that receives a bounded suggestion request and returns a suggestion response or recoverable failure.

Conceptual behavior:

- Accepts provider-neutral request records.
- Returns provider-neutral response records.
- Does not directly mutate project data.
- Does not own command execution.
- Can report disabled, unavailable, invalid request, timeout, malformed response, or safety refusal states.
- Must be replaceable by FakeAIProvider in tests.

Conceptual request fields:

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable request ID. |
| `kind` | Yes | Suggestion kind such as logline, synopsis, scene starter, rewrite, or continuity wording. |
| `targetReference` | No | Project target such as scene, note, selected text, logline, or synopsis. |
| `context` | Yes | Minimal local context needed for the request. |
| `constraints` | No | Tone, length, format, or safety constraints. |
| `createdAt` | Yes | Request creation timestamp. |

Conceptual response fields:

| Field | Required | Description |
| --- | --- | --- |
| `id` | Yes | Stable response ID. |
| `requestId` | Yes | Request this response answers. |
| `providerId` | Yes | Provider identifier such as `fake-ai-provider`. |
| `status` | Yes | `success`, `failed`, `disabled`, `unavailable`, or `malformed`. |
| `suggestions` | No | One or more suggestion records. |
| `diagnostics` | No | Recoverable errors or warnings. |

## FakeAIProvider

`FakeAIProvider` is the only provider expected for Milestone 3 tests and executable specs.

Required behavior:

- Returns deterministic configured responses.
- Can simulate disabled mode.
- Can simulate failure.
- Can simulate timeout or unavailable state without network access.
- Can return malformed response fixtures for validation tests.
- Must never call external services.

Given/When/Then examples:

- Given FakeAIProvider is configured with a logline suggestion, when the logline request runs, then the configured suggestion is returned.
- Given FakeAIProvider is configured to fail, when a scene starter request runs, then a recoverable diagnostic is returned and project data remains unchanged.
- Given AI is disabled, when an AI request is attempted, then FakeAIProvider is not called or returns disabled according to the future test harness.

## Suggestion Lifecycle

Suggestion statuses:

- `pending`: suggestion exists outside canonical project text.
- `accepted`: user accepted the suggestion and a command may apply it.
- `rejected`: user rejected the suggestion and canonical data remains unchanged.
- `expired`: target or context became stale.
- `failed`: provider or validation failed.

Rules:

- Pending suggestions must not mutate user text.
- Rejecting suggestions must leave screenplay and project text unchanged.
- Accepting suggestions must route through commands.
- Accepted rewrite suggestions require a snapshot before mutation.
- Suggestions targeting missing or stale objects fail safely.

## AI Disabled Mode

AI must be optional and disableable.

Acceptance rules:

- If AI is disabled, no provider request is made.
- AI-dependent actions are unavailable or use local non-AI prompts only.
- Existing project data remains editable manually.
- AI disabled mode must not block logline, synopsis, beat sheet, notes, or screenplay editing.

## Snapshot Before Rewrite

Any AI rewrite that changes canonical project content requires a snapshot before mutation.

Applies to:

- Screenplay text rewrites.
- Scene starter insertion when it materially inserts generated text.
- Synopsis rewrite.
- Logline rewrite.
- Note rewrite.

Rules:

- Snapshot must complete before mutation command runs.
- Snapshot metadata must record AI rewrite acceptance as the reason.
- If snapshot creation fails, the rewrite must not apply.
- Snapshot is local `.dreamjotter` canonical project data.

## Privacy Boundary

Milestone 3 forbids external AI calls. All AI examples and tests use local fake responses.

Future provider work must define:

- User consent.
- Prompt context boundaries.
- Data retention policy.
- Provider diagnostics.
- Offline behavior.
- Disable controls.
- Privacy disclosure language.

## Command Boundary

AI providers do not mutate. Accepted suggestions become explicit command requests.

Expected command concepts later:

- `AcceptAISuggestionCommand`.
- `RejectAISuggestionCommand`.
- `CreateSnapshotCommand`.
- `ApplyAIRewriteCommand`.
- `InsertSceneStarterCommand`.
- `UpdateLoglineCommand`.
- `UpdateSynopsisCommand`.

Command ordering for rewrites:

1. Validate suggestion target.
2. Create snapshot.
3. Apply accepted mutation command.
4. Record suggestion as accepted.
5. Preserve diagnostics if any step fails.

## Testability

Future tests should verify:

- AI disabled mode makes no provider calls.
- FakeAIProvider deterministic success.
- FakeAIProvider deterministic failure.
- Pending suggestion causes no mutation.
- Rejected suggestion causes no mutation.
- Accepted suggestion creates command request.
- Accepted rewrite requires snapshot first.
- Snapshot failure prevents rewrite mutation.
- Missing target fails safely.
- Malformed provider response produces diagnostics.

## Related Specs

- `docs/milestones/milestone-3-friendly-writer-tools.md`
- `docs/acceptance/milestone-3-acceptance.md`
- `docs/constitution.md`
- `docs/adr/0003-commands-before-routines-before-plugins.md`
