# Export Presets v1 Spec

Status: specified
Milestone: M9
Traceability ID: EXPORT-PRESETS-V1

## User Goal

As a writer, I want understandable export choices so I do not have to know which metadata is safe to include.

## Scope

Required presets:

- Reader Copy
- Contest Submission
- Print Script
- Writer Backup
- Plain Text Archive

## Non-Goals

- No custom preset editor in M9.
- No production delivery package.

## User-Facing Behavior

Each preset defines display name, user goal, allowed formats, default format, metadata inclusion flags, filename suggestion, and privacy warnings.

## Acceptance Criteria

- Given Reader Copy, export defaults to a clean reader-facing script.
- Given Contest Submission, export excludes internal notes and project-management metadata.
- Given Writer Backup, export includes enough structured data to restore the project.
- Given Plain Text Archive, export produces a readable plain text artifact.
- Given a preset does not support a format, the app shows a friendly constraint message.

## Preset Rules

| Preset | Default Format | Internal Metadata | Notes | Purpose |
| --- | --- | --- | --- | --- |
| Reader Copy | PDF or Fountain | No | No | Shareable read. |
| Contest Submission | PDF or Fountain | No | No | Clean submission. |
| Print Script | PDF | No | Optional later | Personal print. |
| Writer Backup | JSON backup | Yes | Yes | Restore project. |
| Plain Text Archive | Plain text | No | No | Durable readable text. |

## Data Model Implications

Uses `ExportPreset` and `ExportRequest`.

## Testability Notes

Executable specs should verify metadata inclusion flags and unsupported combinations.

## Privacy Notes

Presets must make metadata inclusion explicit.

## Open Questions

- Should Reader Copy default to PDF once the basic PDF adapter exists, or Fountain until PDF is mature?
