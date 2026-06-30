# ADR 0003: Commands Before Routines Before Plugins

## Status

Accepted.

## Context

DreamJotter should eventually support powerful customization, but arbitrary plugins introduce security, compatibility, testing, and architecture complexity. MVP behavior should be understandable and useful without a plugin runtime.

## Decision

DreamJotter will define explicit commands first. Routines, meaning repeatable workflows built from commands, come second. Plugin APIs are future work and must not drive MVP architecture.

## Consequences

- MVP specs should focus on built-in commands and user-facing workflows.
- Routine specs should depend on stable command semantics.
- Plugin specs belong later, after commands and routines have proven extension points.
- Implementation must not create a plugin runtime until explicitly requested by a future milestone.
