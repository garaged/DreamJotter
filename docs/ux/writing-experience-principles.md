# Writing Experience Principles

Status: specified
Milestone: M1-M4
Traceability ID: UX-WRITING-001

## Purpose

This document defines the experience principles for DreamJotter's writing surface. It guides future editor UI, TextKit adapters, accessibility, keyboard behavior, and Simple Mode/Pro Mode decisions without implementing UI.

## Primary Principle

DreamJotter should feel like a writing app first and a production tool second. It should help writers create screenplay structure without making them manage implementation details.

## Audience

The writing experience must serve:

- Beginner screenwriters who do not know screenplay formatting rules.
- Casual storytellers who want a low-friction place to draft scenes.
- Professional writers who need fast keyboard-driven editing.
- Indie filmmakers who need practical scene, character, and location organization.
- Production-minded users who eventually need breakdown and revision data.
- Advanced customization users who want power without forcing complexity on everyone else.

## Experience Rules

### Keep Writing Central

The screenplay text should remain the primary object on screen. Supporting controls should help the current writing decision rather than compete with the page.

### Prefer Suggestions Over Interruptions

Smart formatting, autocomplete, TODO detection, and diagnostics should appear as lightweight suggestions. They must not block typing or force modal correction during drafting.

### Preserve User Text

The editor may suggest structure, but it must not discard or rewrite user-authored text. Malformed screenplay text should remain recoverable with friendly diagnostics.

### Make Structure Visible But Not Technical

Beginners should benefit from semantic screenplay structure without needing to understand internal element kinds. Pro users may inspect and override element kinds when useful.

### Let Simple Mode Stay Simple

Simple Mode should expose the core writing loop: write scenes, manage characters, add notes, search, and export. It should hide revision colors, production breakdown, custom fields, routines, and future plugin concepts unless the user enters Pro Mode.

### Let Pro Mode Be Precise

Pro Mode may expose explicit element controls, advanced keyboard workflows, production metadata, revision behavior, and automation entry points. It must use the same project data and editor behavior as Simple Mode.

### Keep Autocomplete Trustworthy

Autocomplete should suggest known characters and locations from project data and detected screenplay content. It should not create canonical entities or mutate metadata without explicit acceptance.

### Make Diagnostics Friendly

Warnings should describe what DreamJotter noticed and how the writer can fix it. They should avoid blame, jargon, or alarmist language. Incomplete drafts should not be treated as failures.

### Support Unicode From The Start

Names, locations, notes, and dialogue must preserve Unicode text. Spanish text such as `NIÑA`, `JOSÉ`, and `¿Dónde está?` must behave like normal screenplay content.

### Respect Platform Conventions

The Mac editor should feel native on macOS. iPad and iPhone editing should respect touch selection, software keyboard behavior, and hardware keyboard workflows. Platform-specific adapters may differ visually while sharing portable editor behavior.

### Keep The Core Portable

Experience design must not require screenplay semantics to live in SwiftUI, AppKit, UIKit, TextKit, SwiftData, or CloudKit. Platform UI should adapt the portable editor controller, not replace it.

## Distraction-Free Writing

Distraction-free writing mode should reduce visible panels, toolbars, and secondary metadata while preserving essential safety and navigation.

It should keep:

- The writing surface.
- Current context where useful.
- Save or sync status where applicable.
- Accessible exits and commands.
- Non-blocking diagnostics.

It should hide:

- Nonessential project panels.
- Pro-only metadata surfaces.
- Routine and future extension controls.
- Dense production views.

## Accessibility Principles

- Keyboard-only writing must be practical.
- Screen reader users should be able to understand current element kind and diagnostics.
- Suggestions must be reachable, readable, and dismissible.
- Color must never be the only signal for meaning.
- Distraction-free mode must not remove required accessibility affordances.
- Unicode and accented text must remain navigable by grapheme clusters.

## Acceptance Direction

- A beginner can start typing a screenplay without setting up formats first.
- A writer can ignore suggestions and keep writing.
- Known characters and locations are suggested without forced metadata management.
- Spanish and Unicode writing behave as first-class input.
- Simple Mode hides advanced surfaces while preserving project data.
- Pro Mode exposes precision without changing the canonical format.

## Non-Goals

- This document does not define visual design details.
- This document does not create UI code.
- This document does not define TextKit wrappers.
- This document does not define production breakdown UI.
- This document does not define plugin or marketplace UX.
