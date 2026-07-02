# Milestone 9 Acceptance

Status: specified
Milestone: M9

This file defines acceptance criteria for Milestone 9: Export, Review, and Script Health v1.

## Export Workflow

### A-M9-EXPORT-001: Fountain Export

Given an open project, when the user exports Fountain, then a Fountain file is produced.

Traceability: EXPORT-WORKFLOW-V1.

### A-M9-EXPORT-002: Markdown Export

Given an open project, when the user exports Markdown, then a readable Markdown file is produced.

Traceability: EXPORT-WORKFLOW-V1.

### A-M9-EXPORT-003: Plain Text Export

Given an open project, when the user exports plain text, then readable script text is produced.

Traceability: EXPORT-WORKFLOW-V1.

### A-M9-EXPORT-004: JSON Backup Export

Given an open project, when the user exports JSON backup, then a restorable backup artifact is produced.

Traceability: EXPORT-WORKFLOW-V1, BACKUP-RESTORE-WORKFLOW-V1.

### A-M9-EXPORT-005: Export Failure Is Friendly

Given an export failure, when the error is surfaced, then the app shows a friendly error and does not corrupt project state.

Traceability: EXPORT-WORKFLOW-V1.

### A-M9-EXPORT-006: Export Preserves Dirty State

Given a clean or dirty project, when export succeeds, then dirty state remains unchanged.

Traceability: EXPORT-WORKFLOW-V1, M9-PREVIOUS-MILESTONE-PRESERVATION.

## Export Presets

### A-M9-PRESET-001: Reader Copy

Given the user selects Reader Copy, then export defaults to a clean reader-facing script.

Traceability: EXPORT-PRESETS-V1.

### A-M9-PRESET-002: Contest Submission

Given the user selects Contest Submission, then export excludes internal notes and project-management metadata.

Traceability: EXPORT-PRESETS-V1.

### A-M9-PRESET-003: Writer Backup

Given the user selects Writer Backup, then export includes enough structured data to restore the project.

Traceability: EXPORT-PRESETS-V1.

### A-M9-PRESET-004: Plain Text Archive

Given the user selects Plain Text Archive, then export produces a readable plain text artifact.

Traceability: EXPORT-PRESETS-V1.

### A-M9-PRESET-005: Unsupported Combination

Given a preset does not support a chosen format, then the app shows a friendly constraint message.

Traceability: EXPORT-PRESETS-V1.

## Basic PDF Export

### A-M9-PDF-001: Simple PDF

Given a simple screenplay, when exported as PDF, then a readable PDF file is produced.

Traceability: BASIC-PDF-EXPORT-ADAPTER.

### A-M9-PDF-002: Multi-Scene Order

Given a multi-scene screenplay, when exported as PDF, then scenes appear in script order.

Traceability: BASIC-PDF-EXPORT-ADAPTER.

### A-M9-PDF-003: Internal Metadata Excluded

Given notes or internal metadata exist, when using Reader Copy or Contest Submission, then PDF excludes internal notes unless explicitly included.

Traceability: BASIC-PDF-EXPORT-ADAPTER, EXPORT-PRESETS-V1.

### A-M9-PDF-004: PDF Failure

Given PDF export fails, then the app shows a friendly error and dirty state is unchanged.

Traceability: BASIC-PDF-EXPORT-ADAPTER.

## Script Health Report

### A-M9-HEALTH-001: Scene Count

Given a project with scenes, when health report runs, then scene count is correct.

Traceability: SCRIPT-HEALTH-REPORT-V1.

### A-M9-HEALTH-002: Unresolved Characters

Given unresolved detected characters exist, then health report includes them.

Traceability: SCRIPT-HEALTH-REPORT-V1.

### A-M9-HEALTH-003: Unresolved Locations

Given unresolved detected locations exist, then health report includes them.

Traceability: SCRIPT-HEALTH-REPORT-V1.

### A-M9-HEALTH-004: TODO Count

Given TODO notes exist, then health report includes TODO count.

Traceability: SCRIPT-HEALTH-REPORT-V1.

### A-M9-HEALTH-005: Character Cue Without Dialogue

Given a character cue has no dialogue, then report includes a warning.

Traceability: SCRIPT-HEALTH-REPORT-V1, FORMATTING-WARNING-V1.

### A-M9-HEALTH-006: Health Is Read-Only

Given health report runs, then project dirty state is unchanged.

Traceability: SCRIPT-HEALTH-REPORT-V1.

### A-M9-HEALTH-007: Malformed Text Safe

Given malformed script text, health report does not crash.

Traceability: SCRIPT-HEALTH-REPORT-V1.

## Review Findings

### A-M9-FINDING-001: Unresolved Character Finding

Given unresolved characters exist, then review findings include warning-level entries.

Traceability: REVIEW-FINDINGS.

### A-M9-FINDING-002: TODO Finding

Given open TODO notes exist, then review findings include TODO entries.

Traceability: REVIEW-FINDINGS.

### A-M9-FINDING-003: Duplicate Scene Heading Finding

Given duplicate scene headings exist, then review findings include formatting entries.

Traceability: REVIEW-FINDINGS, FORMATTING-WARNING-V1.

### A-M9-FINDING-004: Finding Navigation

Given a finding links to a scene, when selected in Review Mode, then the app can navigate to that scene where practical.

Traceability: REVIEW-FINDINGS, REVIEW-NAVIGATION-INTEGRATION.

## Review Mode

### A-M9-REVIEW-001: Read-Only Preview

Given an open project, when user enters Review Mode, then the script appears read-only.

Traceability: REVIEW-MODE-V1.

### A-M9-REVIEW-002: Findings Visible

Given health findings exist, when Review Mode opens, then findings are visible.

Traceability: REVIEW-MODE-V1.

### A-M9-REVIEW-003: Export From Review

Given the user exports from Review Mode, then export workflow runs.

Traceability: REVIEW-MODE-V1, EXPORT-WORKFLOW-V1.

### A-M9-REVIEW-004: Return To Editing

Given the user returns to Script editor, then normal editing remains available.

Traceability: REVIEW-MODE-V1, M9-PREVIOUS-MILESTONE-PRESERVATION.

## Backup and Restore

### A-M9-BACKUP-001: Backup Produced

Given an open project, when the user exports backup, then a backup artifact is produced.

Traceability: BACKUP-RESTORE-WORKFLOW-V1.

### A-M9-BACKUP-002: Valid Restore

Given a valid backup, when the user restores it, then project data is loaded.

Traceability: BACKUP-RESTORE-WORKFLOW-V1.

### A-M9-BACKUP-003: Dirty Restore Protection

Given restore is attempted while current project is dirty, then unsaved changes are protected.

Traceability: BACKUP-RESTORE-WORKFLOW-V1.

### A-M9-BACKUP-004: Invalid Restore

Given an invalid backup, when restore is attempted, then the app shows a friendly error and keeps current state safe.

Traceability: BACKUP-RESTORE-WORKFLOW-V1.

### A-M9-BACKUP-005: Restored Data Persists

Given a restored project is saved and reopened, then restored data remains intact.

Traceability: BACKUP-RESTORE-WORKFLOW-V1.

## Formatting Warnings

### A-M9-FORMAT-001: Missing Time Of Day

Given a scene heading missing time of day, then warning appears.

Traceability: FORMATTING-WARNING-V1.

### A-M9-FORMAT-002: Character Cue Without Dialogue

Given a character cue without dialogue, then warning appears.

Traceability: FORMATTING-WARNING-V1.

### A-M9-FORMAT-003: Warnings Do Not Block Save

Given warnings exist, save still works.

Traceability: FORMATTING-WARNING-V1.

### A-M9-FORMAT-004: Warnings Do Not Mutate Text

Given the user ignores warnings, project text is unchanged.

Traceability: FORMATTING-WARNING-V1.

## Navigation and Preservation

### A-M9-NAV-001: Finding Navigates To Scene

Given a finding is linked to Scene 2, when selected, then Scene 2 is highlighted or navigated to.

Traceability: REVIEW-NAVIGATION-INTEGRATION.

### A-M9-NAV-002: Missing Target Is Graceful

Given the app cannot locate a finding target, then it fails gracefully.

Traceability: REVIEW-NAVIGATION-INTEGRATION.

### A-M9-PRESERVE-001: Prior Workflows Continue

Given the user edits in TextKit, saves, reopens, and exports, then content is preserved.

Traceability: M9-PREVIOUS-MILESTONE-PRESERVATION.

### A-M9-PRESERVE-002: M8 Metadata Safe

Given character/location/note metadata exists, export and backup do not corrupt it.

Traceability: M9-PREVIOUS-MILESTONE-PRESERVATION.
