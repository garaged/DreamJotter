# Milestone 4 Acceptance

## Purpose

This file defines acceptance examples for Milestone 4: Pro Apple Version Foundations. These examples are covered by executable specs for the portable core. They do not require plugin runtime, arbitrary scripting, external services, or app UI.

## Acceptance Fixture Set

### A-M4-REVISION-COLORS-001: Supported Revision Colors

Input:

```yaml
revision_colors:
  - blue
  - pink
  - yellow
  - green
  - goldenrod
  - cherry
  - custom
```

Expected result:

- Every listed color is accepted as a valid revision color type.
- Custom color preserves a portable value and display label.
- Revision color metadata links to revision sets, not only UI styling.

Given/When/Then:

- Given Pro Mode is enabled, when a revision color is selected, then the active revision set stores the selected color metadata.
- Given Simple Mode opens a project with revision colors, when saved, then revision metadata is preserved.

Traceability: M4-REVISIONS-001, PRD-REVISIONS-001.

### A-M4-DRAFT-VERSIONS-001: Draft Version Records

Input:

```yaml
action: create_draft_version
name: Draft 2
source_snapshot_id: snapshot-001
```

Expected result:

- Draft version record is created with stable ID, name, created date, and source snapshot reference.
- Draft creation does not overwrite current screenplay content.
- Simple Mode preserves draft metadata.

Given/When/Then:

- Given Pro Mode is enabled, when the user creates a draft version, then draft metadata is stored as canonical project data.

Traceability: M4-DRAFTS-001, PRD-VERSIONING-001.

### A-M4-DRAFT-COMPARE-001: Semantic Draft Comparison

Input:

```yaml
left_draft: Draft 1
right_draft: Draft 2
changes:
  - added scene
  - removed dialogue
  - moved scene
```

Expected result:

- Comparison result identifies added, removed, changed, and moved semantic elements where supported.
- Comparison is read-only.
- Ambiguous matches produce diagnostics rather than invented certainty.

Given/When/Then:

- Given two drafts exist, when comparison runs, then a derived comparison result is produced and no draft content changes.

Traceability: M4-COMPARE-001, PRD-COMPARE-001.

### A-M4-BREAKDOWN-CATEGORIES-001: Production Breakdown Categories

Input:

```yaml
categories:
  - cast
  - extras
  - props
  - costumes
  - vehicles
  - animals
  - VFX
  - SFX
  - locations
  - makeup
  - stunts
  - music
  - special equipment
```

Expected result:

- Every listed category is valid.
- Breakdown entries link to scene or planned scene references.
- Simple Mode hides controls and preserves data.

Given/When/Then:

- Given Pro Mode is enabled, when a props breakdown entry is added to a scene, then the entry stores category `props` and the scene reference.
- Given a scene is deleted, when breakdown validation runs, then orphaned breakdown entries are reported.

Traceability: M4-BREAKDOWN-001, PRD-BREAKDOWN-001.

### A-M4-EXPORT-PRESETS-001: Advanced Export Preset Validation

Input:

```yaml
preset:
  title: Production PDF
  export_type: pdf
  options:
    include_revision_colors: true
    include_title_page: true
```

Expected result:

- Preset is represented as structured export intent.
- Unsupported export options produce validation diagnostics.
- Simple Mode hides advanced preset editing.

Given/When/Then:

- Given Pro Mode is enabled, when a built-in preset is duplicated, then a project-specific preset record is created.
- Given an export capability is unavailable, when preset validation runs, then the preset reports unavailable status without starting export.

Traceability: M4-EXPORTPRESETS-001, PRD-EXPORTPRESETS-001.

### A-M4-CUSTOM-FIELDS-001: Supported Custom Field Types

Input:

```yaml
field_types:
  - text
  - number
  - boolean
  - date
  - single select
  - multi select
```

Expected result:

- Every listed type is valid.
- Field definitions have stable IDs and target scopes.
- Field values validate against definitions.
- Simple Mode preserves definitions and values without showing authoring controls.

Given/When/Then:

- Given a single select field has allowed values, when an unsupported value is saved, then validation fails without corrupting existing field data.
- Given a boolean field exists on a scene, when saved and loaded, then the boolean value remains typed.

Traceability: M4-CUSTOMFIELDS-001, PRD-CUSTOMFIELDS-001.

### A-M4-ROUTINE-MANUAL-001: Manual Routine Executes Commands

Input:

```yaml
routine:
  enabled: true
  trigger: manual
  actions:
    - createSnapshot
    - addNote
```

Expected result:

- Routine validates successfully.
- Routine runner submits command requests to CommandEngine in order.
- Routine does not directly mutate project internals.
- Run log records action results.

Given/When/Then:

- Given a manual routine is enabled, when the user runs it, then CommandEngine receives `createSnapshot` and `addNote` command requests in order.

Traceability: M4-ROUTINES-001, M4-ROUTINE-RUNNER-001, M4-COMMANDENGINE-001.

### A-M4-ROUTINE-DISABLED-001: Disabled Routine Does Not Run

Input:

```yaml
routine:
  enabled: false
  trigger: sceneStatusChanged
  actions:
    - addNote
```

Expected result:

- Trigger does not execute actions.
- No command requests are created.
- Run is skipped or absent according to later logging policy.

Given/When/Then:

- Given a routine is disabled, when its trigger fires, then no project mutation occurs.

Traceability: M4-ROUTINES-001, M4-ROUTINE-RUNNER-001.

### A-M4-ROUTINE-SUPPORTED-SURFACE-001: Supported Triggers, Conditions, And Actions

Input:

```yaml
triggers:
  - manual
  - sceneStatusChanged
  - beforeExport
  - afterExport
  - beforeAIRewrite
conditions:
  - sceneStatusEquals
  - projectHasOpenTODOs
  - proModeEnabled
actions:
  - createSnapshot
  - addNote
  - runAnalysis
  - updateSceneStatus
  - exportProject placeholder
```

Expected result:

- Listed triggers, conditions, and actions are recognized by Routine v1 validation.
- Unknown triggers, conditions, or actions fail validation.
- Routine remains no-code structured data.

Given/When/Then:

- Given a routine uses an unsupported action, when validation runs, then validation fails and no routine actions execute.

Traceability: M4-ROUTINES-001.

### A-M4-ROUTINE-SNAPSHOT-001: Destructive Routine Action Requires Snapshot

Input:

```yaml
routine:
  enabled: true
  trigger: manual
  actions:
    - updateSceneStatus
safety:
  destructive: true
snapshot_creation: fails
```

Expected result:

- Snapshot policy is evaluated before destructive mutation.
- If snapshot creation fails, updateSceneStatus does not execute.
- Run log records failure and project state remains valid.

Given/When/Then:

- Given a destructive routine action requires a snapshot, when snapshot creation fails, then CommandEngine does not perform the destructive mutation.

Traceability: M4-ROUTINE-RUNNER-001, M4-COMMANDENGINE-001, M2-SNAPSHOTS-001.

### A-M4-COMMANDENGINE-001: CommandEngine Is Mutation Boundary

Input:

```yaml
source: routine
action: updateSceneStatus
direct_mutation_attempted: true
```

Expected result:

- Direct mutation is rejected by architecture rules.
- Routine must submit a command request.
- Validation failure leaves project state unchanged.

Given/When/Then:

- Given a routine wants to update scene status, when it runs, then it must call CommandEngine rather than mutate project data directly.

Traceability: M4-COMMANDENGINE-001, ADR-0003.

### A-M4-PROMODE-001: Pro Mode Visibility And Simple Mode Preservation

Input:

```yaml
mode: Simple Mode
project_contains:
  revisions: true
  custom_fields: true
  routines: true
  production_breakdown: true
```

Expected result:

- Simple Mode hides Pro authoring controls.
- Existing Pro metadata is preserved on save.
- Enabling Pro Mode later can expose Pro entry points without changing project format.

Given/When/Then:

- Given Simple Mode opens a project with Pro metadata, when saved, then revision, custom field, routine, and breakdown data remain in the package.

Traceability: M4-PROMODE-001, M2-MODES-001, M2-PROMODE-001.

### A-M4-PLUGIN-DEFERRED-001: Future Plugin Extension Points Only

Input:

```yaml
proposal:
  requires_plugin_runtime: true
  requires_arbitrary_scripting: true
milestone: M4
```

Expected result:

- Proposal is rejected or deferred.
- No plugin runtime records are required.
- No arbitrary script runs.
- Project remains readable without plugins.

Given/When/Then:

- Given a Milestone 4 feature proposal requires arbitrary plugin code, when checked against extension-point policy, then it is deferred beyond Milestone 4.

Traceability: M4-PLUGIN-EXTENSIONS-001, ADR-0003, R-008.

## Cross-Cutting Acceptance Rules

- Simple Mode must remain default and must preserve Pro metadata without exposing authoring controls.
- `.dreamjotter` remains canonical project storage.
- SwiftData must not become canonical storage.
- Routine v1 is no-code structured automation only.
- Routine mutations must go through CommandEngine.
- Routine failures must not corrupt project state.
- Destructive routine actions require snapshot first.
- Future plugin extension points are documentation only.
- No arbitrary scripting, plugin runtime, or production code is allowed.

## Deferred Acceptance

The following are explicitly deferred beyond Milestone 4 acceptance:

- Plugin runtime.
- Plugin marketplace.
- Plugin SDK.
- Arbitrary scripting.
- Production app implementation.
- Final Pro UI.
- Scheduling, budgeting, call sheets, and inventory management.
- Cloud sync and real-time collaboration.
- Native Windows/Linux/Android apps.
