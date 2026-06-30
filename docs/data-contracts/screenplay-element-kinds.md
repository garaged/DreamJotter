# Screenplay Element Kinds

## Purpose

This contract defines the portable semantic kinds used by `ScriptElement`. Element kinds are screenplay meaning, not visual styling. Rendering systems may style elements, but styling is not the canonical source of truth.

## Required Rules

- `ScriptElement.kind` must be serialized as a string.
- Unknown future kinds must preserve original text and produce diagnostics instead of data loss.
- Element kind detection may be parser-derived, user-selected, or imported, but canonical storage records the semantic kind explicitly.
- Do not infer canonical meaning only from rich text, margins, fonts, or attributed spans.
- Unicode text must be preserved for every kind.

## Kind Reference

| Kind | Purpose | Typical Example | Validation Notes |
| --- | --- | --- | --- |
| `titlePage` | Title page or title metadata element. | `Title: La Noche Larga` | May later move to structured metadata. |
| `sceneHeading` | Scene heading. | `EXT. ZOCALO - NOCHE` | Should preserve original heading text. |
| `action` | Scene action or description. | `La lluvia golpea las ventanas.` | Default safe kind for prose. |
| `characterCue` | Speaker cue before dialogue. | `NIÑA` | Should link to Character where known. |
| `parenthetical` | Dialogue direction. | `(susurra)` | Usually appears between cue and dialogue. |
| `dialogue` | Spoken text. | `¿Dónde está José?` | May link to Character via preceding cue. |
| `transition` | Screenplay transition. | `CORTE A:` | Includes English and localized transitions where supported. |
| `section` | Organizational section. | `# Acto Uno` | Common from Fountain import. |
| `synopsis` | Inline synopsis/planning text. | `= Lucía encuentra una pista.` | Common from Fountain import. |
| `noteReference` | Reference to a Note record. | `note-001` | Note body belongs in `Note`, not element text. |
| `unknown` | Preserved unsupported or malformed text. | `INT HOUSE DAY` | Must preserve text and diagnostics. |

## Supported Transition Examples

- `CUT TO:`
- `FADE OUT.`
- `DISSOLVE TO:`
- `CORTE A:`

The transition set is intentionally not final. Unsupported transition-like text should be preserved as `action` or `unknown` with diagnostics according to parser rules.

## Scene Heading Examples

- `INT. KITCHEN - DAY`
- `EXT. ZOCALO - NOCHE`
- `INT./EXT. TRAIN - SUNSET`

Scene heading parsing may derive normalized location and time of day, but the original text remains canonical.

## Dialogue Block Example

```json
[
  {
    "id": "element-101",
    "kind": "characterCue",
    "text": "NIÑA",
    "createdAt": "2026-06-30T18:00:00Z",
    "updatedAt": "2026-06-30T18:00:00Z"
  },
  {
    "id": "element-102",
    "kind": "parenthetical",
    "text": "(susurra)",
    "createdAt": "2026-06-30T18:00:05Z",
    "updatedAt": "2026-06-30T18:00:05Z"
  },
  {
    "id": "element-103",
    "kind": "dialogue",
    "text": "¿Dónde está José?",
    "createdAt": "2026-06-30T18:00:10Z",
    "updatedAt": "2026-06-30T18:00:10Z"
  }
]
```

## Codable Expectation

Element kinds should be represented as a `Codable` string enum or equivalent portable representation. Decoding unknown cases must not discard the source element.

## Equatable Expectation

Element kind values should be `Equatable` for parser tests, import/export tests, and semantic diffing.

## Sendable Expectation

Element kind values should be `Sendable` where practical because they are immutable scalar values.

## Migration Notes

Adding a new kind is allowed only when older readers can preserve text through `unknown` or compatible fallback behavior. Removing or renaming kinds requires migration rules and diagnostics.

## Platform Neutrality Concerns

- No TextKit paragraph style names.
- No SwiftUI view types.
- No AppKit/UIKit font or color types.
- No SwiftData annotations.
