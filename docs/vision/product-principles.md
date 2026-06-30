# Product Principles

## Non-Programmers First

DreamJotter should not require users to understand markup, file schemas, scripting, package managers, or programming concepts to write a screenplay.

## Semantic Screenplays

A screenplay is made of meaningful elements: scenes, action, characters, dialogue, parentheticals, transitions, notes, metadata, and future production structures. Styling is a rendering of semantic content, not the source of truth.

## Local-First Ownership

The canonical project artifact is a `.dreamjotter` document package that can be stored, backed up, copied, and inspected locally. Cloud sync may be supported later as transport, not as the source of truth.

## Progressive Disclosure

Simple Mode should make the common path obvious. Pro Mode should expose specialized capabilities without adding noise to beginner workflows.

## Apple-Native Experience, Portable Core

The first app should feel native on macOS, iPadOS, and iOS. Core document behavior, storage, commands, routines, exports, and AI abstractions must stay independent from SwiftUI, AppKit, UIKit, and Apple-only persistence.

## Commands Before Routines Before Plugins

User actions should become explicit commands first. Repeatable sequences should become routines second. Arbitrary plugin APIs should come later, after the command and routine surfaces are stable.
