# Milestone 11 — FDX Interoperability Foundation

Status: implemented

## Goal

Add a portable, deterministic Final Draft XML interchange boundary without making FDX canonical storage or coupling the core screenplay model to Final Draft-specific types.

## Scope

- Export the supported screenplay semantic subset to UTF-8 FDX XML.
- Import supported FDX paragraph types into `ScreenplayDocument`.
- Preserve paragraph order, Unicode text, derived scene headings, and character cues.
- Escape XML-sensitive text safely.
- Omit private or internal DreamJotter-only elements with deterministic diagnostics.
- Preserve unknown FDX paragraph types as `.unknown` elements with warnings.
- Reject malformed XML without returning a partial screenplay.

## Supported Paragraph Mapping

| FDX paragraph type | DreamJotter element kind |
| --- | --- |
| Scene Heading | `sceneHeading` |
| Action / General | `action` |
| Character | `characterCue` |
| Parenthetical | `parenthetical` |
| Dialogue | `dialogue` |
| Transition | `transition` |
| Shot | `shot` |

Sections and synopses export as Action in the portable subset. Title-page records, note references, explicit page breaks, and unknown DreamJotter elements are omitted with warnings.

## Guardrails

- `.dreamjotter` remains canonical storage.
- FDX import and export remain adapter operations over `ScreenplayDocument`.
- No Final Draft SDK or external service is required.
- XML external-entity resolution stays disabled.
- Import returns a candidate document and never mutates an existing project directly.
- Unsupported content produces deterministic diagnostics rather than silent corruption.

## Acceptance

M11 is accepted when executable specs cover role mapping, Unicode and XML escaping, semantic round trip, unsupported-element diagnostics, unknown paragraph preservation, and malformed XML failure.
