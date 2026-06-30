# ADR 0001: Apple Native First, Portable Core

## Status

Accepted.

## Context

DreamJotter should feel excellent on macOS first, then iPadOS and iOS. Future Linux, Windows, and Android support remains desirable, so core behavior cannot be trapped inside Apple UI frameworks.

## Decision

DreamJotter will be Apple-native first with a portable core. Apple UI may use SwiftUI, AppKit, UIKit, and TextKit where appropriate. The portable core will own domain behavior and must not depend on Apple UI frameworks.

## Consequences

- The first user experience can be optimized for Mac, iPad, and iPhone.
- Screenplay model, storage, commands, routines, export, and AI abstractions remain platform-neutral.
- Specs must call out platform-specific behavior separately from core behavior.
- Future non-Apple platforms should be able to reuse project data and core rules.
