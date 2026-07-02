# Milestone 9.5 Acceptance

Status: implemented
Milestone: M9.5

This file defines acceptance criteria for Milestone 9.5: Export UX and Release Readiness Polish.

Implementation coverage is provided by `Tests/DreamJotterMacTests/MacAppViewModelTests.swift` for adapter-neutral export state, feedback, dirty-state preservation, selected-format export, and backup restore protection. The Mac MVP manual QA checklist remains a release-readiness checklist artifact.

## Export Format Picker UI

### A-M9-5-FORMAT-001: Formats Are Visible

Given an open project, when the user opens export UI, then Fountain, PDF, Markdown, Plain Text, and JSON Backup formats are visible.

Traceability: EXPORT-FORMAT-PICKER-UI.

### A-M9-5-FORMAT-002: PDF Uses Existing Adapter

Given the user selects PDF, when export runs, then export uses the existing basic PDF export adapter.

Traceability: EXPORT-FORMAT-PICKER-UI.

### A-M9-5-FORMAT-003: Text Formats Use Existing Export

Given the user selects Fountain, Markdown, or Plain Text, when export runs, then export uses existing M9 export workflow behavior.

Traceability: EXPORT-FORMAT-PICKER-UI.

### A-M9-5-FORMAT-004: JSON Backup Uses Backup Workflow

Given the user selects JSON Backup, when export runs, then the backup export workflow is used.

Traceability: EXPORT-FORMAT-PICKER-UI, BACKUP-RESTORE-UI.

### A-M9-5-FORMAT-005: Export Is Read-Only

Given export succeeds or fails, then project content and dirty state are unchanged.

Traceability: EXPORT-FORMAT-PICKER-UI, M9-5-PREVIOUS-MILESTONE-PRESERVATION.

## Export Preset Picker UI

### A-M9-5-PRESET-001: Reader Copy Excludes Internal Metadata

Given the user selects Reader Copy, then internal notes and project metadata are excluded by default.

Traceability: EXPORT-PRESET-PICKER-UI.

### A-M9-5-PRESET-002: Contest Submission Excludes Internal Metadata

Given the user selects Contest Submission, then internal notes and project metadata are excluded.

Traceability: EXPORT-PRESET-PICKER-UI.

### A-M9-5-PRESET-003: Print Script Defaults To PDF

Given the user selects Print Script, then PDF is offered as the natural default format.

Traceability: EXPORT-PRESET-PICKER-UI.

### A-M9-5-PRESET-004: Writer Backup Defaults To JSON Backup

Given the user selects Writer Backup, then JSON Backup is offered as the natural default format.

Traceability: EXPORT-PRESET-PICKER-UI, BACKUP-RESTORE-UI.

### A-M9-5-PRESET-005: Incompatible Combination Is Explained

Given a selected format is incompatible with a preset, then the app disables it or shows a friendly explanation.

Traceability: EXPORT-PRESET-PICKER-UI, EXPORT-DESTINATION-FEEDBACK.

## Export Destination and Feedback

### A-M9-5-FEEDBACK-001: Success Feedback

Given export completes, then success feedback is visible and includes the exported filename or path where practical.

Traceability: EXPORT-DESTINATION-FEEDBACK, EXPORT-FEEDBACK.

### A-M9-5-FEEDBACK-002: Canceled Destination

Given the user cancels destination selection, then no error is shown and dirty state is unchanged.

Traceability: EXPORT-DESTINATION-FEEDBACK, EXPORT-FEEDBACK.

### A-M9-5-FEEDBACK-003: Friendly Failure

Given export fails due to permission or path issues, then a friendly error is shown.

Traceability: EXPORT-DESTINATION-FEEDBACK, EXPORT-FEEDBACK.

### A-M9-5-FEEDBACK-004: Reveal In Finder

Given export succeeds and an output path exists, then Reveal in Finder availability is represented.

Traceability: EXPORT-DESTINATION-FEEDBACK, EXPORT-FEEDBACK.

## Review Mode Export UX

### A-M9-5-REVIEW-001: Review Export Opens Picker

Given the user is in Review Mode, when export is selected, then the export picker opens.

Traceability: REVIEW-MODE-EXPORT-UX.

### A-M9-5-REVIEW-002: Reader PDF From Review Mode

Given the user exports Reader PDF from Review Mode, then PDF export runs and dirty state remains unchanged.

Traceability: REVIEW-MODE-EXPORT-UX.

### A-M9-5-REVIEW-003: Review Export Cancel

Given the user cancels export from Review Mode, then Review Mode remains open and unchanged.

Traceability: REVIEW-MODE-EXPORT-UX.

### A-M9-5-REVIEW-004: Review Export Failure

Given export fails from Review Mode, then friendly feedback is shown.

Traceability: REVIEW-MODE-EXPORT-UX, EXPORT-FEEDBACK.

## Backup and Restore UI

### A-M9-5-BACKUP-001: Create Backup

Given an open project, when the user selects Create Backup, then a backup artifact is produced.

Traceability: BACKUP-RESTORE-UI.

### A-M9-5-BACKUP-002: Backup Feedback

Given backup succeeds or fails, then understandable feedback is shown.

Traceability: BACKUP-RESTORE-UI, EXPORT-FEEDBACK.

### A-M9-5-BACKUP-003: Dirty Restore Protection

Given current project is dirty, when restore starts, then the app protects unsaved changes.

Traceability: BACKUP-RESTORE-UI.

### A-M9-5-BACKUP-004: Valid Restore

Given a valid backup is selected, when restore succeeds, then restored project opens.

Traceability: BACKUP-RESTORE-UI.

### A-M9-5-BACKUP-005: Invalid Restore

Given invalid backup is selected, then current project remains safe and a friendly error is shown.

Traceability: BACKUP-RESTORE-UI.

### A-M9-5-BACKUP-006: Restore Canceled

Given restore is canceled, then current project remains unchanged.

Traceability: BACKUP-RESTORE-UI.

## Manual QA Checklist

### A-M9-5-QA-001: Checklist Exists

Given release readiness planning begins, then a Mac MVP manual QA checklist exists for app launch, writing, save/reopen, editor behavior, project-object workflows, review, export, backup/restore, dirty state, and recent projects.

Traceability: MAC-MVP-MANUAL-QA-CHECKLIST.

## Preservation

### A-M9-5-PRESERVE-001: Metadata Survives Export

Given a project with characters, locations, notes, and scene metadata, when exported, then project metadata remains intact.

Traceability: M9-5-PREVIOUS-MILESTONE-PRESERVATION.

### A-M9-5-PRESERVE-002: Dirty State Survives Export

Given a project with unsaved edits, when export succeeds, then unsaved edits remain unsaved and dirty state is unchanged.

Traceability: M9-5-PREVIOUS-MILESTONE-PRESERVATION.

### A-M9-5-PRESERVE-003: Restore Cancel Is Safe

Given restore is canceled, then current project remains unchanged.

Traceability: M9-5-PREVIOUS-MILESTONE-PRESERVATION.

### A-M9-5-PRESERVE-004: Review Mode Returns To Editing

Given Review Mode is opened and closed, then normal editing remains available.

Traceability: M9-5-PREVIOUS-MILESTONE-PRESERVATION.
