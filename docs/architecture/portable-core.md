# Portable Core

The portable core is the future home for domain behavior that should work beyond Apple UI frameworks.

## Responsibilities

The portable core should eventually own:

- Semantic screenplay document model.
- Project package read/write contracts.
- Validation rules.
- Command definitions and command execution semantics.
- Routine definitions built from commands.
- Export pipeline abstractions.
- AI provider abstractions and data boundaries.

## Exclusions

The portable core must not depend on:

- SwiftUI.
- AppKit.
- UIKit.
- TextKit view types.
- SwiftData as canonical persistence.
- Apple-only document UI concepts.

Apple-specific adapters may call into the portable core, but the core should not call into Apple UI frameworks.

## Data Model Expectations

Core screenplay data should encode meaning. For example, a character cue should be stored as a character cue, not as centered uppercase text. Dialogue should be dialogue, not a paragraph with margins. Scene headings should be typed and parseable, not just styled strings.

## Future Portability

The first implementation may be Swift, but specifications should keep platform-neutral behavior clear enough that future Linux, Windows, Android, or alternate UI implementations can read the same project format and follow the same screenplay rules.
