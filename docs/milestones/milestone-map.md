# Milestone Map

## Milestone 0: SDD Foundation

Goal: Establish documentation structure, product direction, architecture decisions, and traceability before implementation.

Acceptance focus:

- Repository explains vision, workflow, layout, and current status.
- ADRs record Apple-native-first, `.dreamjotter`, and command sequencing decisions.
- Traceability matrix links initial requirements to docs and future validation.

## Milestone 1: Semantic Screenplay And Project Contract

Goal: Specify the semantic screenplay model and the `.dreamjotter` package contract.

Expected specs:

- Screenplay element model.
- Document identity and metadata.
- `.dreamjotter` package layout.
- Validation rules.
- Example fixtures.

## Milestone 2: Core Commands And Editing Behavior

Goal: Specify core document commands and beginner editing behavior without committing to final UI implementation.

Expected specs:

- Create project.
- Add, change, split, merge, and reorder screenplay elements.
- Undo and redo behavior.
- Simple Mode editing rules.
- Pro Mode editing capabilities.

## Milestone 3: Native Apple App Foundation

Goal: Introduce the Apple app shell only after core specs define the expected behavior.

Expected specs:

- macOS-first app structure.
- Document open/save behavior for `.dreamjotter` packages.
- Native navigation and editor surface requirements.
- Platform adaptations for iPadOS and iOS.

## Milestone 4: Export, Routines, And Advanced Workflows

Goal: Specify export behavior, command-based routines, and advanced workflow customization.

Expected specs:

- Export pipeline and output formats.
- Routine definitions built from commands.
- Pro Mode customization surfaces.
- Plugin boundaries as future extension points, not MVP requirements.
