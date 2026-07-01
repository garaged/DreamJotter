# Mac Menu Commands Spec

Status: specified
Milestone: M6
Registry ID: APP-MENU-COMMANDS

## User Goal

A Mac writer can use expected menu commands and keyboard shortcuts for project lifecycle operations without learning custom controls.

## Scope

- New Project command.
- Open command.
- Save command.
- Save As command.
- Export Fountain command.
- Keyboard shortcuts for common commands.
- Routing commands through view-model or app-service actions.

## Non-Goals

- No full menu polish for every future feature.
- No document browser migration.
- No iPadOS/iOS command menus in this milestone.
- No plugin-contributed commands.

## Command Requirements

- Cmd+N starts New Project workflow.
- Cmd+O starts Open Project workflow.
- Cmd+S starts Save workflow.
- Shift+Cmd+S starts Save As workflow.
- Export Fountain is available from a command surface where practical.

## Architecture Rules

- Commands call the same app lifecycle actions as visible controls.
- Views may present file panels, but business decisions belong to view models or services.
- Command handlers must respect dirty replacement protection and Save As routing.

## Given/When/Then Examples

- Given the app is running, when Cmd+N is used, then New Project workflow starts.
- Given the app is running, when Cmd+O is used, then Open Project workflow starts.
- Given a dirty saved project, when Cmd+S is used, then Save workflow runs.
- Given an unsaved project, when Cmd+S is used, then Save As workflow is required.
- Given a project is open, when Export Fountain is chosen, then export uses the same core-backed action as the visible export control.

## Edge Cases

- Cmd+N while current project is dirty.
- Cmd+O while current project is dirty.
- Cmd+S with no open project.
- Export with no open project.
- Save panel cancel from a keyboard shortcut.

## UI Implications

Menu commands should be disabled, no-op, or show a friendly state when no project is available. They should not silently discard edits.

## Testability Notes

Tests should target the command destination methods or notification/action bridge, not the menu UI itself.

## Open Questions

- Should Export Fountain get a default keyboard shortcut in Milestone 6 or remain menu-only?
- Should New Project create immediately or return to a library confirmation flow when dirty?

## Executable Spec Plan

- Command destination starts New Project workflow.
- Command destination starts Open workflow.
- Save command routes to Save As for unsaved projects.
- Save command saves existing package projects.
- Export command does not mark project dirty.
