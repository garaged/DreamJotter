# M12.5 Complete Spanish UI Localization

Status: implemented pending local validation

## Purpose

Make the complete DreamJotter macOS interface usable by Spanish-speaking writers in Mexico and Latin America without requiring English comprehension. Application localization never translates screenplay text or user-entered project content.

## Supported Locales

- `en` — canonical source language;
- `es-MX` — primary Mexican Spanish experience;
- `es-419` — Latin American Spanish experience and fallback vocabulary.

Application language and screenplay language remain independent.

## Implementation

### Locale resources

The shipping translations are stored in:

- `Apps/DreamJotterMac/Resources/es-MX.lproj/Localizable.strings`;
- `Apps/DreamJotterMac/Resources/es-419.lproj/Localizable.strings`;
- `Apps/DreamJotterMac/Resources/es-MX.lproj/Errors.strings`;
- `Apps/DreamJotterMac/Resources/es-419.lproj/Errors.strings`.

Both locales contain the same complete key sets. The current implementation provides 293 general UI translations plus application error and recovery translations.

### Localized UI surfaces

Implemented localization covers:

- application commands and Settings;
- project creation, open, save, Save As, close, and unsaved-change confirmation;
- project library and recent projects;
- dashboard fields and metrics;
- script editor, search, suggestions, language selection, and empty guidance;
- character and location profiles, detections, filters, confirmations, and empty states;
- scene cards, planning order, statuses, filters, navigation, and screenplay reorder confirmation;
- notes, TODOs, statuses, targets, orphan handling, navigation, and bulk resolution;
- Review Mode, findings, severities, sources, suggested actions, and navigation;
- Health Report messages and severities;
- export formats, presets, destinations, warnings, success, cancellation, and failures;
- JSON backup creation, restore, confirmation, and errors;
- file panel titles and localized filename suggestions;
- accessibility labels for icon-only search, scene-order, navigation, and severity controls.

### Dynamic localization

Generated model and workflow text is localized at presentation time. Stable semantic values remain unlocalized internally.

Localized dynamic content includes:

- scene and note statuses;
- filter and target names;
- review finding titles, messages, sources, severities, and suggested actions;
- health messages;
- export preset and format descriptions;
- export and restore results;
- application errors and recovery suggestions;
- search result summaries;
- suggestion types;
- document save state and unsaved window titles.

## Spanish Terminology

The normative vocabulary is:

| English | Spanish |
| --- | --- |
| Screenplay | Guión cinematográfico |
| Script | Guión |
| Scene | Escena |
| Scene heading | Encabezado de escena |
| Character | Personaje |
| Location | Locación |
| Dialogue | Diálogo |
| Parenthetical | Acotación |
| Transition | Transición |
| Shot | Plano |
| Note | Nota |
| TODO | Pendiente |
| Review | Revisión |
| Finding | Hallazgo |
| Health report | Reporte de estado |
| Dashboard | Panel |
| Project | Proyecto |
| Draft | Borrador |
| Snapshot | Instantánea |
| Backup | Respaldo |
| Restore | Restaurar |
| Export | Exportar |
| Plotline | Trama |
| Summary | Resumen |
| Status | Estado |
| Target | Destino |
| Severity | Severidad |
| Settings | Configuración |

Technical product and format names such as DreamJotter, Fountain, FDX, PDF, JSON, Markdown, TextKit, and TextEditor remain unchanged.

## Localization Rules

- Every user-visible literal must resolve through localized resources.
- Raw enum values and implementation identifiers must not be shown directly.
- Dynamic messages use localized format strings rather than concatenated English fragments.
- Dates, numbers, and lists use locale-aware formatters.
- File paths, filenames, identifiers, and format syntax remain verbatim inside localized surrounding text.
- Technical details may remain English only when secondary to a localized primary message.
- Locale switching must never mutate project or screenplay content.
- Original accents, punctuation, capitalization, and Unicode graphemes are preserved.

## Accessibility

Icon-only or ambiguous controls require localized accessibility labels or hints. Implemented coverage includes:

- previous and next script-search results;
- scene move-earlier and move-later actions;
- scene navigation;
- review severity icons;
- suggestion acceptance;
- search icon decoration.

VoiceOver must not expose raw symbol names, enum values, or localization keys.

## Layout Requirements

Spanish labels must remain usable at the minimum supported window size. Validation must check:

- navigation and toolbar labels;
- segmented controls and pickers;
- confirmation dialogs;
- profile and scene forms;
- notes and review rows;
- export and restore sheets;
- accessibility text sizes.

Buttons may grow or wrap where appropriate. Primary actions must remain reachable without clipping.

## Automated Audit

The audit command is:

```text
python3 scripts/localization-check
```

It validates:

- common SwiftUI and `String(localized:)` literals;
- `es-MX` and `es-419` locale availability;
- complete key parity across every `.strings` table;
- missing or empty translations;
- duplicate keys;
- malformed `.strings` syntax;
- Unicode-safe source scanning.

Technical names are covered by an explicit allowlist.

## Automated Tests

`Tests/DreamJotterMacTests/LocalizationResourceTests.swift` verifies:

1. Mexican and Latin American Spanish key parity;
2. a minimum complete translation inventory;
3. critical writer workflow coverage;
4. region-appropriate Spanish locale naming;
5. application-language preference persistence.

M12.4 parser tests continue to verify that locale changes do not affect screenplay semantics or mutate original text.

## Manual Acceptance Journey

Complete this journey in both `es-MX` and `es-419`:

1. Launch DreamJotter and select Spanish.
2. Create and title a project.
3. Add a premise and synopsis.
4. Write and search a screenplay.
5. Create and edit character and location profiles.
6. Convert and ignore detected entities.
7. Edit scene cards and planning order.
8. Add, edit, resolve, reopen, and remove notes.
9. Navigate from notes and review findings to the script.
10. Review health findings.
11. Export Fountain and PDF.
12. Create and restore a JSON backup.
13. Save, close, and reopen the project.
14. Exercise Save, Discard, and Cancel for unsaved changes.

No required step may depend on English-only text.

## Acceptance Exit Criteria

M12.5 is accepted only when:

- the localization audit reports zero findings;
- all Swift tests and the macOS build pass;
- the complete manual journey succeeds in `es-MX` and `es-419`;
- no blocking truncation is found;
- VoiceOver exposes useful localized labels;
- export and restore round trips preserve Unicode content;
- a native Spanish speaker approves terminology and tone.

Until those checks pass, M12.5 remains implemented pending local validation.

## Out of Scope

- translation of screenplay dialogue or user-entered content;
- machine translation;
- languages other than English and Spanish;
- localization of developer-only logs;
- translation of interchange-format syntax or persistent identifiers.
