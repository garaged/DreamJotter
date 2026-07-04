# M13 TextKit Consolidation Decision

Decision: retain the SwiftUI `TextEditor` adapter as a recovery and compatibility mode after Milestone 13.

## Rationale

TextKit is the default and feature-complete screenplay editor path. It owns native selection, undo integration, semantic command grouping, parser-driven styling, normalized paste, navigation, and accessibility metadata.

The fallback remains valuable while DreamJotter is tested across supported macOS releases, input methods, VoiceOver configurations, and very large scripts. Removing it now would eliminate the only in-app recovery path for an AppKit-specific regression.

## Constraints

- TextKit remains the default.
- The compatibility adapter edits the same canonical plain text and semantic project model.
- No new screenplay-specific behavior is implemented only in the fallback.
- The fallback is not presented as an equivalent editor architecture.
- Bugs that reproduce only in TextKit must be fixed in TextKit rather than worked around permanently in the fallback.

## Removal gate

The fallback may be removed in a later milestone after all of the following are true:

1. Undo, selection, paste, autocomplete, accessibility, and large-document acceptance matrices pass on every supported macOS release.
2. At least one external testing cycle reports no blocking TextKit-only editing failures.
3. Recovery telemetry or tester reports show that the fallback is no longer required.
4. Removal includes migration-safe preference handling and documentation updates.
