# Review Findings Spec

Status: specified
Milestone: M9
Traceability ID: REVIEW-FINDINGS

## User Goal

As a writer, I want health and review issues displayed as understandable findings that can link back to the relevant part of my project.

## Scope

- Finding severity: info, warning, issue.
- Finding source: health report, formatting, unresolved character, unresolved location, TODO, storage.
- Optional linked entity and script range.
- Suggested action text where useful.

## Non-Goals

- No automatic fix application.
- No collaborative comment threads.

## Acceptance Criteria

- Given unresolved characters exist, review findings include warning-level entries.
- Given open TODO notes exist, review findings include TODO entries.
- Given duplicate scene headings exist, review findings include formatting entries.
- Given a finding links to a scene, selecting it can request navigation.

## Data Model Implications

Uses `ReviewFinding`.

## UI Implications

Findings should be grouped or filterable by severity/source in Review Mode eventually.

## Testability Notes

Executable specs should verify stable IDs, severity, source, and navigation link fields.

## Open Questions

- Which findings should have suggested actions in M9 versus later?
