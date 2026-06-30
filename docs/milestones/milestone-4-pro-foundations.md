# Milestone 4: Pro Apple Version Foundations

## Goal

Define pro features without compromising beginner usability or portable core architecture. Milestone 4 establishes professional screenplay workflows, command-driven routines, and future extension boundaries while preserving Simple Mode as the default and keeping plugins deferred.

Milestone 4 remains documentation-first in this prompt. It does not implement production code, create app UI, create a Swift package, create an Xcode project, implement a plugin runtime, allow arbitrary scripting, or execute external services.

## Scope Summary

Milestone 4 includes specifications for:

- Revision colors.
- Draft versions.
- Draft comparison.
- Production breakdown.
- Advanced export presets.
- Custom fields.
- Routine system v1.
- Routine runner safety.
- Command-engine integration.
- Pro Mode visibility.
- App extension points for future plugins, but no plugin runtime yet.

## Pro Boundary

Pro Mode surfaces advanced controls for writers and production-minded users. Simple Mode must remain clear and must not require users to understand revisions, production breakdowns, routines, custom fields, or future plugin concepts.

## Feature Specifications

### M4-REVISIONS-001: Revision Colors

User story: As a professional writer, I want revision colors so draft changes can be identified visually and in exports.

Pro user behavior: Pro Mode allows enabling revision tracking, selecting an active revision color, and associating changed semantic elements with a revision set.

Simple Mode behavior: Simple Mode hides revision controls by default. If a project already contains revision metadata, Simple Mode preserves it and may show a read-only indicator without exposing editing controls.

Acceptance criteria:

- Supported revision colors are blue, pink, yellow, green, goldenrod, cherry, and custom.
- Revision color assignments are stored as semantic metadata, not only text styling.
- Revision metadata can be associated with screenplay elements and draft versions.
- Custom colors require a stable stored value and display name.
- Revision tracking does not alter screenplay meaning.

Given/When/Then scenarios:

- Given Pro Mode is enabled, when the user selects blue as active revision color, then subsequent accepted changes can be associated with blue revision metadata.
- Given Simple Mode is active, when a project with revision metadata opens, then revision metadata is preserved and editing controls remain hidden or disabled.
- Given a custom revision color exists, when the project saves and loads, then the custom color value and label are preserved.

Data model implications: Requires revision set records with ID, label, color value, color type, created date, active status, and linked element change references.

Command system implications: Revision changes must be applied through commands that record element IDs, old/new values, revision set ID, and undo boundaries.

Storage implications: Revision metadata is canonical `.dreamjotter` data and must not rely on SwiftData or UI-only attributed text.

Safety rules:

- Disabling visible revision display must not delete revision metadata.
- Bulk accepting or clearing revisions is destructive and requires snapshot policy.
- Custom colors must be validated for portable representation.

Non-goals:

- Final visual styling implementation.
- Industry-specific revision page locking.
- Production code for tracked changes.

### M4-DRAFTS-001: Draft Versions

User story: As a professional writer, I want named draft versions so I can preserve and refer to major screenplay states.

Pro user behavior: Pro Mode allows creating, naming, listing, and selecting draft versions. Draft versions can reference snapshots and revision sets.

Simple Mode behavior: Simple Mode may show the current draft name but hides draft management unless the user enables Pro Mode later.

Acceptance criteria:

- Draft versions have stable ID, name, created date, source snapshot reference where available, and optional notes.
- Creating a draft version records current canonical screenplay state or references a snapshot according to future data contracts.
- Draft version names can duplicate only if disambiguated by date or ID.
- Loading a project with drafts preserves draft metadata in Simple Mode.

Given/When/Then scenarios:

- Given Pro Mode is enabled, when the user creates `Draft 2`, then a draft version record is stored.
- Given a draft references a snapshot, when the draft is listed, then the snapshot relationship is available for comparison.
- Given Simple Mode opens a project with multiple drafts, when saved, then draft metadata is not removed.

Data model implications: Requires draft version records, links to snapshots, optional revision set references, and current draft pointer.

Command system implications: Creating, renaming, selecting, and deleting draft versions must be commands. Deleting draft versions that own unique data requires snapshot or confirmation policy.

Storage implications: Draft records are canonical `.dreamjotter` data. Large draft content should use package-level snapshot or version storage contracts later.

Safety rules:

- Deleting a draft version is destructive and requires confirmation plus snapshot policy if unique content may be lost.
- Selecting a draft must not silently overwrite current work.

Non-goals:

- Full Git-like branching.
- Real-time multi-user versioning.
- Final storage optimization for large draft histories.

### M4-COMPARE-001: Draft Comparison

User story: As a professional writer, I want to compare drafts and understand what changed semantically.

Pro user behavior: Pro Mode allows comparing two drafts or snapshots and reviewing added, removed, moved, and changed screenplay elements.

Simple Mode behavior: Simple Mode hides comparison controls but preserves comparison-related metadata and draft data.

Acceptance criteria:

- Comparison operates on semantic elements, not only raw line text.
- Comparison can identify added, removed, changed, and moved elements where element identity allows.
- Formatting-only changes are distinguishable from semantic changes when data supports it.
- Comparison results are derived and do not mutate project data.
- Comparison can report unsupported or ambiguous cases with diagnostics.

Given/When/Then scenarios:

- Given two drafts exist, when comparison runs, then additions and removals are reported with element references.
- Given a scene moved from earlier to later, when comparison runs, then the result reports a move if stable IDs allow.
- Given text styling changes but semantic content is unchanged, when comparison runs, then the result can classify it as formatting-only or unsupported according to available data.

Data model implications: Requires comparison result records or derived view models with source draft IDs, target draft IDs, change type, element references, and diagnostics.

Command system implications: Running comparison is read-only. Applying a comparison result as a change must be a future command.

Storage implications: Comparison results are derived and should not be canonical unless a later report-history spec stores them.

Safety rules:

- Comparison must not alter drafts.
- Incomplete element identity must produce diagnostics rather than invented matches.

Non-goals:

- Production UI for diff review.
- Automatic merge.
- Real-time collaboration conflict resolution.

### M4-BREAKDOWN-001: Production Breakdown

User story: As a production-minded user, I want to track production elements by scene without burdening writers who do not need them.

Pro user behavior: Pro Mode exposes production breakdown categories and scene-level breakdown records.

Simple Mode behavior: Simple Mode hides production breakdown controls and preserves existing breakdown data if present.

Acceptance criteria:

- Supported categories are cast, extras, props, costumes, vehicles, animals, VFX, SFX, locations, makeup, stunts, music, and special equipment.
- Breakdown entries link to scenes or planned scene records.
- Breakdown data is optional and does not affect screenplay text.
- Unknown or future categories are preserved according to package compatibility rules where possible.
- Breakdown reports are derived from canonical breakdown records and screenplay scene data.

Given/When/Then scenarios:

- Given Pro Mode is enabled, when a prop is added to a scene breakdown, then a props entry links to that scene.
- Given Simple Mode opens the same project, when the project is saved, then breakdown data is preserved even though controls are hidden.
- Given a scene is deleted, when breakdown validation runs, then entries linked to the missing scene are reported as orphaned.

Data model implications: Requires production breakdown records with ID, scene reference, category, title, notes, quantity or status where specified later, and timestamps.

Command system implications: Add, edit, delete, and relink breakdown entries must be commands. Bulk deletion requires snapshot policy.

Storage implications: Breakdown data is canonical `.dreamjotter` project data. Derived reports or indexes are rebuildable.

Safety rules:

- Breakdown controls must not appear in beginner workflows by default.
- Deleting scene-linked breakdown data is destructive and requires confirmation.

Non-goals:

- Scheduling.
- Budgeting.
- Call sheets.
- Inventory management.

### M4-EXPORTPRESETS-001: Advanced Export Presets

User story: As a professional writer, I want reusable export presets for different recipients and workflow stages.

Pro user behavior: Pro Mode allows creating, duplicating, renaming, editing, validating, and selecting advanced export presets.

Simple Mode behavior: Simple Mode shows only safe built-in presets and hides advanced editing controls.

Acceptance criteria:

- Presets can target export types such as PDF, Fountain, package archive, or future formats.
- Presets store options as structured data, not UI-only state.
- Preset validation reports unavailable options or unsupported export capabilities.
- Built-in presets remain distinguishable from project-specific custom presets.
- Preset selection maps to export intent rather than platform-specific renderer details.

Given/When/Then scenarios:

- Given Pro Mode is enabled, when the user duplicates a built-in preset, then a project-specific preset record is created.
- Given an export capability is unavailable, when preset validation runs, then the preset reports unavailable status without corrupting data.
- Given Simple Mode is active, when export presets are listed, then advanced editing controls are hidden.

Data model implications: Requires export preset records with ID, title, export type, options, scope, validation status, and timestamps.

Command system implications: Preset create, duplicate, edit, delete, and select operations must be commands. Export execution should use CommandEngine where it mutates logs or output records.

Storage implications: Built-in presets may be app resources. Project-specific presets are canonical `.dreamjotter` data.

Safety rules:

- Invalid presets must not trigger partial export side effects.
- Export actions that overwrite files require confirmation or safe write policies.

Non-goals:

- Final PDF rendering.
- Full FDX support.
- Cloud publishing.

### M4-CUSTOMFIELDS-001: Custom Fields

User story: As an advanced user, I want structured metadata fields for projects, scenes, characters, and production records.

Pro user behavior: Pro Mode allows defining custom field schemas and assigning values to supported entities.

Simple Mode behavior: Simple Mode hides field editing and preserves existing field definitions and values.

Acceptance criteria:

- Supported field types are text, number, boolean, date, single select, and multi select.
- Field definitions have stable IDs, names, types, allowed targets, validation rules, and optional select options.
- Field values validate against their field definition.
- Field type changes require migration or validation diagnostics.
- Custom fields are searchable and exportable only where later specs enable them.

Given/When/Then scenarios:

- Given Pro Mode is enabled, when a text custom field is added to scenes, then scene records can store text values for that field.
- Given a single select field has allowed values, when an unsupported value is entered, then validation fails without corrupting existing data.
- Given Simple Mode opens a project with custom fields, when saved, then field definitions and values are preserved.

Data model implications: Requires custom field definition records, select option records, typed field values, target references, validation diagnostics, and schema versioning.

Command system implications: Field definition create/update/delete and field value changes must be commands. Destructive type changes require snapshot policy.

Storage implications: Custom field definitions and values are canonical `.dreamjotter` data. Search indexes are derived.

Safety rules:

- Deleting a field with values is destructive and requires confirmation plus snapshot policy.
- Invalid values must not be silently coerced.
- Simple Mode must not delete unknown custom fields.

Non-goals:

- Arbitrary scripts or formulas.
- Custom UI builder.
- Plugin-provided field types.

### M4-ROUTINES-001: Routine System v1

User story: As a power user, I want no-code routines that automate repeatable project tasks using approved commands.

Pro user behavior: Pro Mode allows viewing, enabling/disabling, and manually running routine definitions where supported.

Simple Mode behavior: Simple Mode hides routine authoring and execution controls. Built-in safe routines may run only if explicitly specified later and visible to the user.

Acceptance criteria:

- Routines are no-code automation definitions.
- Routines execute commands through CommandEngine.
- Routines must not directly mutate project internals.
- Routines can be disabled.
- Routine runs produce logs.
- Routine failures must not corrupt project state.
- Destructive routine actions require snapshot first.
- Supported triggers are manual, sceneStatusChanged, beforeExport, afterExport, and beforeAIRewrite.
- Supported conditions are sceneStatusEquals, projectHasOpenTODOs, and proModeEnabled.
- Supported actions are createSnapshot, addNote, runAnalysis, updateSceneStatus, and exportProject placeholder.

Given/When/Then scenarios:

- Given a disabled routine, when its trigger occurs, then no actions execute and a skipped state may be logged.
- Given a manual routine with createSnapshot and addNote actions, when it runs, then CommandEngine receives those command requests in order.
- Given a destructive action is included, when the routine runs, then snapshot policy is evaluated before mutation.
- Given an action fails, when the routine stops, then project state remains valid and the run log records failure.

Data model implications: Requires routine definition records, trigger records, condition records, action records, enabled flag, run logs, diagnostics, and schema version.

Command system implications: Routines are command orchestration only. They submit command requests to CommandEngine and never write project state directly.

Storage implications: Routine definitions and logs are canonical or project-associated `.dreamjotter` data according to later contract. Derived run summaries are rebuildable from logs.

Safety rules:

- No arbitrary scripting.
- No plugin execution.
- No network actions.
- No direct state mutation.
- Failures must leave the project valid.

Non-goals:

- Plugin runtime.
- User-authored code.
- Background daemon automation.
- Cross-project routines.

### M4-ROUTINE-RUNNER-001: Routine Runner Safety

User story: As a maintainer, I want routine execution to be predictable, logged, and recoverable.

Pro user behavior: Pro Mode shows routine run status, logs, skipped conditions, and failures in understandable language.

Simple Mode behavior: Simple Mode hides routine runner details unless a routine result directly affects a visible action and needs a friendly message.

Acceptance criteria:

- Every routine run has a run ID, routine ID, trigger, start time, end time, status, and ordered action results.
- Failure status is recorded without corrupting project state.
- Routine runner validates trigger, conditions, actions, and required capabilities before execution.
- Destructive actions require snapshot creation first.
- Routine runner can stop on failure according to definition policy specified later.

Given/When/Then scenarios:

- Given a routine action fails validation, when the routine runs, then no later mutation action executes unless failure policy allows it.
- Given snapshot creation fails before a destructive action, when the routine runs, then the destructive action does not execute.
- Given conditions are not met, when the trigger fires, then the run is skipped or not started according to later logging policy.

Data model implications: Requires routine run log records with action-level results, diagnostics, and optional snapshot references.

Command system implications: Routine runner wraps CommandEngine execution and records results; CommandEngine remains the only mutation boundary.

Storage implications: Run logs may be canonical project audit data or bounded project logs according to later data contract.

Safety rules:

- Routine failure must not leave partial invalid state.
- Logging must not expose hidden notes in contexts where Simple Mode hides them.
- Long-running routines need cancellation policy later.

Non-goals:

- Concurrent routine execution.
- Network automation.
- Script interpreter.

### M4-COMMANDENGINE-001: Command-Engine Integration

User story: As an implementer, I want all advanced mutations to pass through a command engine so undo, validation, snapshots, routines, and safety checks share one boundary.

Pro user behavior: Pro users benefit from consistent undo, logs, routine execution, and safety checks without managing command details.

Simple Mode behavior: Simple Mode also uses commands internally but does not expose command-engine concepts.

Acceptance criteria:

- CommandEngine is the only mutation boundary for Pro features.
- Commands declare inputs, target references, validation rules, safety level, snapshot requirements, and result diagnostics.
- Routines call CommandEngine instead of direct mutation.
- AI accepted suggestions and rewrites call CommandEngine.
- Command failures return diagnostics and leave canonical project state valid.

Given/When/Then scenarios:

- Given a routine wants to update scene status, when it runs, then it submits `updateSceneStatus` to CommandEngine.
- Given a command fails validation, when execution is attempted, then no canonical mutation is applied.
- Given a command is destructive, when executed, then snapshot policy is checked before mutation.

Data model implications: Requires command request, command result, diagnostic, safety level, snapshot policy, and optional audit log records.

Command system implications: This feature defines the command boundary used by Milestone 4 advanced features.

Storage implications: Command logs may be derived or canonical audit data depending on future contract. Mutations affect `.dreamjotter` canonical data through validated commands.

Safety rules:

- No direct mutation by routines, AI providers, future plugins, or UI shortcuts.
- Validation must run before mutation.
- Destructive commands require snapshot policy.

Non-goals:

- Implementing the command engine.
- Distributed command execution.
- Arbitrary command plugins.

### M4-PROMODE-001: Pro Mode Visibility

User story: As a beginner, I want advanced controls hidden until I need them; as a pro user, I want a clear way to access advanced tools.

Pro user behavior: Pro Mode exposes revision colors, draft versions, comparison, breakdown, advanced presets, custom fields, routines, and future extension-point visibility.

Simple Mode behavior: Simple Mode remains default and hides Pro controls. It preserves Pro data when opening projects created or edited in Pro Mode.

Acceptance criteria:

- Simple Mode is default unless a user or project preference later says otherwise.
- Pro controls are grouped and intentionally surfaced only in Pro Mode.
- Simple Mode can load and save projects containing Pro metadata without deleting it.
- Pro Mode visibility is product policy, not a separate project format.
- Enabling Pro Mode does not alter screenplay content.

Given/When/Then scenarios:

- Given Simple Mode is active, when project settings open, then revision, routines, and custom field authoring controls are hidden or disabled.
- Given Pro Mode is enabled, when project settings open, then advanced feature entry points are visible.
- Given a Pro project opens in Simple Mode, when saved, then Pro metadata remains in the package.

Data model implications: Requires mode policy records or preferences and capability visibility metadata. Project format remains shared.

Command system implications: Enabling or disabling Pro Mode, if stored, should be a command or settings mutation with validation.

Storage implications: Mode preference may be app metadata or project metadata later. It must not fork `.dreamjotter` schema.

Safety rules:

- Simple Mode must not silently delete Pro data.
- Pro controls must not become required for beginner writing workflows.

Non-goals:

- Final settings UI.
- Subscription or licensing model.
- Separate Pro project format.

### M4-PLUGIN-EXTENSIONS-001: Future Plugin Extension Points

User story: As a maintainer, I want future plugin boundaries identified without implementing a runtime or letting plugins drive current architecture.

Pro user behavior: No user-facing plugin runtime exists in Milestone 4. Pro users may see future extension-point concepts only in specs, not app behavior.

Simple Mode behavior: Simple Mode has no plugin controls.

Acceptance criteria:

- Future extension points are documented separately from routines.
- No arbitrary code execution is introduced.
- No plugin marketplace is introduced.
- No plugin API is required for Milestone 1-4 features.
- Future plugins, if ever added, must use command boundaries and cannot directly mutate project internals.

Given/When/Then scenarios:

- Given a future feature proposal requires arbitrary plugin code in Milestone 4, when checked against this spec, then it is rejected or deferred.
- Given a future plugin wants to mutate a scene, when architecture is later designed, then the mutation must go through CommandEngine.
- Given Simple Mode is active, when app settings are shown in Milestone 4, then no plugin controls are required.

Data model implications: Future plugin metadata is deferred. Extension-point docs may name possible surfaces but must not create runtime records yet.

Command system implications: Future plugins must use commands. Milestone 4 does not define plugin command registration.

Storage implications: No plugin runtime storage is added. `.dreamjotter` must not require plugin code to open project content.

Safety rules:

- No arbitrary scripting.
- No plugin runtime.
- No network-capable plugins.
- No third-party code execution.
- No project content that requires a plugin to be readable.

Non-goals:

- Plugin marketplace.
- Plugin package format.
- Plugin permissions.
- Plugin SDK.

## Milestone 4 Exit Criteria

Milestone 4 is ready for implementation only when later prompts have produced data contracts for revisions, drafts, comparison results, production breakdown, export presets, custom fields, routines, command requests/results, routine logs, Pro Mode policy, and future extension-point boundaries.

Milestone 4 is complete when future implementation can demonstrate:

- Revision metadata for blue, pink, yellow, green, goldenrod, cherry, and custom colors.
- Draft version records and safe draft selection behavior.
- Semantic draft comparison as read-only derived results.
- Production breakdown categories linked to scenes.
- Advanced export preset records and validation.
- Typed custom fields for text, number, boolean, date, single select, and multi select.
- Routine definitions using only supported triggers, conditions, and actions.
- Routine execution through CommandEngine only.
- Routine failure logs without project corruption.
- Snapshot policy before destructive routine actions.
- Pro Mode visibility without Simple Mode data loss.
- Future plugin extension points documented with no runtime.

## Deferred Work

Milestone 4 does not include production code, plugin runtime, arbitrary scripting, plugin marketplace, real external service calls, cloud sync, scheduling, budgeting, call sheets, full FDX, native Windows/Linux/Android apps, or final Pro UI implementation.
