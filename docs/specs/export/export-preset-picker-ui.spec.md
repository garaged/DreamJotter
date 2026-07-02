# Export Preset Picker UI Spec

Status: specified
Milestone: 9.5
Traceability ID: EXPORT-PRESET-PICKER-UI

## User Goal

A writer can choose an export purpose first, then choose only compatible formats.

## Scope

- Reader Copy.
- Contest Submission.
- Print Script.
- Writer Backup.
- Plain Text Archive.
- Preset descriptions and metadata inclusion warnings.
- Format compatibility constraints.

## Non-Goals

- No custom preset authoring in Milestone 9.5.
- No pro production export presets beyond current M9 set.

## User-Facing Behavior

Each preset should show:

- Name.
- Intended use.
- Default format.
- Compatible formats.
- Whether notes, scene metadata, character/location metadata, unresolved items, internal IDs, or app version are included.
- Privacy warning when applicable.

## Acceptance Criteria

- Given Reader Copy is selected, then internal metadata is excluded.
- Given Contest Submission is selected, then notes and internal metadata are excluded.
- Given Print Script is selected, then PDF is the default.
- Given Writer Backup is selected, then JSON Backup is the default.
- Given a selected format is incompatible, then the UI disables it or explains why.

## Given/When/Then Examples

- Given Writer Backup is selected, when the picker refreshes, then JSON Backup is selected and other formats are unavailable.
- Given Contest Submission is selected, when PDF is selected, then export is allowed and notes remain excluded.

## Edge Cases

- Preset missing from project package.
- Legacy project with older preset fields.
- User changes format first and then selects incompatible preset.

## Data Model Implications

Uses `ExportUIState.selectedPresetID`, `selectedFormat`, and `disabledFormats`.

## Storage Implications

No canonical storage changes. Export presets remain project data as already implemented.

## Command Implications

No mutation command required.

## UI Implications

Preset and format pickers should update each other through view-model logic.

## Testability Notes

Tests should validate default format selection and disabled reasons for incompatible formats.

## Platform Implications

Picker state should be platform-neutral for later Apple UI reuse.

## Security and Privacy Notes

Internal IDs and project-management metadata must be opt-in and naturally limited to Writer Backup.

## Open Questions

- Should advanced/pro presets be hidden in Simple Mode until a later milestone?
