# Script Analysis Spec

Status: specified
Milestone: M2-M4
Traceability ID: SCRIPT-ANALYSIS-001

## Purpose

Script analysis provides read-only insight into screenplay structure and project health. It helps writers understand scope, balance, and likely formatting issues without mutating project data or blocking writing.

## Scope

Script analysis covers:

- Scene count.
- Character count.
- Note count.
- TODO count.
- Dialogue/action ratio.
- Longest scenes.
- Formatting warnings.
- Character introduced but unused.
- Read-only report behavior.

## Principles

- Analysis reads semantic screenplay/project data.
- Reports must not mutate project data.
- Warnings are advisory.
- Unicode and Spanish text are supported.
- Missing or incomplete project data must not crash analysis.
- Analysis findings should be reproducible for the same project state.

## Analysis Report

A script analysis report includes:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | Yes | Stable report ID. |
| `projectId` | Yes | Project analyzed. |
| `screenplayId` | Yes | Screenplay analyzed. |
| `generatedAt` | Yes | ISO-8601 timestamp. |
| `metrics` | Yes | Counts and ratios. |
| `findings` | Yes | Advisory warnings or observations. |
| `diagnostics` | No | Analysis failures or skipped checks. |

Reports may be generated on demand. Persisting reports, if ever supported, must go through CommandEngine.

## Scene Count

Counts semantic scene records or `sceneHeading` elements in document order.

Acceptance criteria:

- Empty screenplay returns scene count 0.
- One-scene screenplay returns scene count 1.
- Multi-scene screenplay returns the correct count.
- Invalid scene-like lines are not counted as valid scenes unless parser classified them as scene headings.

## Character Count

Counts known and detected character records according to project policy.

Rules:

- Character cue elements contribute to detected character count.
- Managed character records may contribute to total character count even if not used.
- Unicode names such as `NIÑA` and `JOSÉ` are counted normally.
- Aliases and spelling variants may be reported separately until resolved.

## Note Count

Counts project notes, scene notes, character notes, and inline parsed note elements when included by analysis scope.

Rules:

- Deleted or archived notes are excluded unless explicitly included.
- Notes linked to missing targets are counted and may produce diagnostics.

## TODO Count

Counts unresolved TODO markers from notes and screenplay text.

Sources:

- Explicit note text beginning with `TODO:`.
- Fountain notes such as `[[TODO: ...]]`.
- Plain text TODO lines when configured by parser/editor policy.

TODO count is advisory and does not change note state.

## Dialogue/Action Ratio

Dialogue/action ratio compares dialogue text volume to action text volume.

Initial calculation direction:

- Count words or characters in `dialogue` elements.
- Count words or characters in `action` elements.
- Report ratio and raw counts.
- Exclude notes, transitions, headings, and metadata.

Exact word-count algorithm is implementation detail but must be deterministic and Unicode-aware.

## Longest Scenes

Longest scenes identify scenes with the largest amount of screenplay text.

Possible measures:

- Element count.
- Word count.
- Character count.

Initial report may include top N longest scenes with scene heading, scene ID, and measured length. It must not assume final page count.

## Formatting Warnings

Formatting warnings identify likely screenplay structure issues.

Examples:

- Dialogue without clear character cue.
- Parenthetical outside dialogue context.
- Invalid scene heading pattern.
- Ambiguous uppercase line.
- Transition-like line not classified as transition.

Warnings must include friendly language and source references where possible.

## Character Introduced But Unused

A managed character is introduced but unused when the character exists in metadata but has no detected dialogue or referenced scene usage according to current analysis policy.

Rules:

- Do not auto-delete unused characters.
- Do not auto-merge spelling variants.
- Report as advisory.
- Preserve Unicode names in findings.

## Report Must Not Mutate Project

Script analysis is read-only. It must not:

- Create notes.
- Resolve TODOs.
- Rename characters.
- Change scene status.
- Add metadata.
- Create snapshots.
- Write storage files directly.

If analysis findings are later saved, that save requires a command.

## Given/When/Then Scenarios

### Empty Screenplay

Given an empty screenplay
When script analysis runs
Then scene, character, note, and TODO counts are 0
And no mutation occurs.

### Multi-Scene Script

Given a screenplay has three scene headings
When script analysis runs
Then scene count is 3
And longest scenes are computed from semantic scene content.

### TODO Count

Given notes and screenplay text include unresolved TODO markers
When script analysis runs
Then TODO count reports the unresolved markers
And the TODOs remain unchanged.

### Formatting Warning

Given a parenthetical appears outside dialogue context
When script analysis runs
Then a formatting warning is reported
And screenplay text remains unchanged.

### Unused Character

Given a managed character has no dialogue or references
When script analysis runs
Then the report includes an advisory unused-character finding
And the character record is not deleted.

## Non-Goals

- No production analysis implementation.
- No page-count-accurate timing.
- No automatic repairs.
- No AI calls.
- No mutation or command execution during report generation.

## Related Specs

- `docs/editor/screenplay-engine-spec.md`
- `docs/specs/continuity-analysis-spec.md`
- `docs/architecture/command-engine-spec.md`
- `docs/data-contracts/core-domain-model.md`
