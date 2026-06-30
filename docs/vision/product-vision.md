# Product Vision

DreamJotter is a screenplay writing app for people who think in scenes, characters, beats, revisions, and production intent rather than in software syntax. It should let a beginner start writing quickly while preserving a path to professional workflows.

## Audience

DreamJotter serves non-programmers first: screenwriters, students, filmmakers, playwright-adjacent writers, editors, and collaborators who need screenplay structure without technical friction.

Advanced users may eventually customize formatting, commands, routines, exports, and workflow automation. Those capabilities must be optional and should not define the first-run experience.

## Product Promise

DreamJotter keeps screenplay writing structured without making the writer manage structure manually.

The app should:

- Treat screenplay content as semantic elements, not only styled text.
- Preserve writer ownership through local-first project files.
- Make beginner workflows visible and advanced workflows discoverable.
- Support future automation without requiring programming knowledge.
- Keep project data portable beyond Apple platforms.

## Progressive Complexity

Simple Mode is the default beginner experience. It should expose the minimum controls needed to write, navigate, revise, and export a screenplay.

Pro Mode is for specialized users. It may expose detailed formatting options, advanced document metadata, command customization, routine automation, export controls, and eventually plugin configuration.

Simple Mode and Pro Mode should share the same semantic document model. Mode changes must not fork the project format.

## Non-Goals For MVP

- Arbitrary plugin runtime.
- Web-first editor.
- Cloud-only project storage.
- SwiftData as canonical project persistence.
- Rich-text-only screenplay documents.
- Production scheduling or budgeting as a core MVP requirement.
