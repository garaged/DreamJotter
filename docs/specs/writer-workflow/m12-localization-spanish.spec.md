# M12.4 Localization and Spanish Screenplay Support

Status: specified

## Purpose

Provide a production-ready localization architecture for DreamJotter with English and Spanish support while preserving screenplay semantics, Unicode content, Fountain interoperability, deterministic parsing, local-first storage, search behavior, and export fidelity.

This slice covers two related but separate concerns:

1. **Application localization** — menus, buttons, labels, messages, diagnostics, accessibility text, onboarding, review findings, export UI, and system-facing copy.
2. **Screenplay-language support** — recognition and preservation of screenplay constructs written in English or Spanish, including scene headings, character cues, parentheticals, transitions, title-page fields, time-of-day labels, and editor suggestions.

Application language and screenplay language are independent. A writer may use the app in Spanish while writing an English screenplay, or use the app in English while writing a Spanish screenplay.

## Supported Locales

DreamJotter must ship with:

- `en` — English base localization;
- `es-MX` — primary Spanish localization and terminology;
- `es-419` — Latin American Spanish fallback vocabulary and formatting behavior.

Fallback order:

1. exact locale, such as `es-MX`;
2. Latin American Spanish, `es-419`, for other Spanish locales in the Americas;
3. base Spanish resources when introduced;
4. English base resources;
5. stable localization key only in debug diagnostics, never as normal user-facing release text.

The implementation must use Apple localization mechanisms appropriate for macOS 14 and Swift 6, including String Catalogs or equivalent generated localization resources. User-facing strings must not be assembled from translated fragments when grammar or word order can vary.

## Locale Selection

- By default, the app follows the macOS preferred language.
- The app may expose an explicit language override in Settings: System, English, Español (México/Latinoamérica).
- Changing the application language must not modify screenplay content, project metadata, export presets, or parser configuration unless the writer separately changes screenplay-language settings.
- Language selection must persist as app preference, not inside the canonical `.dreamjotter` screenplay content.

## Project Screenplay-Language Setting

Each project may declare a screenplay-language profile:

- `automatic` — detect accepted constructs per line without translating or rewriting text;
- `english`;
- `spanishLatinAmerica`.

The setting influences editor suggestions, validation messages, accepted aliases, title-page templates, and default generated examples. It does not translate existing screenplay text.

For backward compatibility, existing projects without a screenplay-language field decode as `automatic`.

## Canonical Semantic Rule

Localized screenplay text maps to the existing language-neutral semantic model:

- `sceneHeading`;
- `action`;
- `characterCue`;
- `dialogue`;
- `parenthetical`;
- `transition`;
- `shot`;
- `section`;
- `synopsis`;
- `noteReference`;
- `titlePage`;
- `pageBreak`.

The semantic kind is canonical. The original screenplay text remains canonical presentation content and must be preserved exactly, including accents, capitalization, punctuation, spacing, and chosen language.

The parser must never translate `INT. CASA - NOCHE` into English, remove the accent from `SOFÍA`, or replace a writer's Spanish transition with an English equivalent.

## Unicode and Name Rules

Character cues and other uppercase-like constructs must support the full Unicode alphabet, including:

- `SOFÍA`;
- `ÍÑIGO`;
- `JOSÉ LUIS`;
- `DOÑA ÁNGELES`;
- `EL NIÑO`;
- composed and decomposed accent sequences;
- `Ñ`, `Ü`, and other Latin-script diacritics.

Uppercase recognition must use Unicode case properties rather than ASCII-only ranges. Search, duplicate detection, and autocomplete matching use `TextNormalization.key` only for comparison. Original graphemes remain unchanged in storage and export.

## Scene Heading Grammar

### Shared production prefixes

The following prefixes are accepted case-insensitively in English and Spanish screenplay profiles:

- `INT.`
- `EXT.`
- `INT./EXT.`
- `EXT./INT.`
- `I/E.` as an optional Spanish shorthand alias when enabled by the language profile
- forced Fountain scene headings using a leading `.` followed by a supported prefix

Examples:

```text
INT. CASA DE SOFÍA - NOCHE
EXT. PARQUE - DÍA
INT./EXT. AUTO - CONTINUO
.I/E. EDIFICIO - AMANECER
```

### Location and time separation

The preferred separator remains ` - ` for Fountain compatibility. The parser may accept an en dash or em dash surrounded by whitespace as a tolerant input alias, but export must preserve the original source punctuation unless the writer explicitly requests normalization.

### Spanish time-of-day vocabulary

The Spanish profile recognizes, without requiring translation:

- `DÍA`
- `NOCHE`
- `AMANECER`
- `ATARDECER`
- `MEDIODÍA`
- `MADRUGADA`
- `CONTINUO`
- `MOMENTOS DESPUÉS`
- `MÁS TARDE`
- `MISMO TIEMPO`

English values such as `DAY`, `NIGHT`, `DAWN`, `DUSK`, `CONTINUOUS`, `LATER`, and `SAME TIME` remain valid in every profile for Fountain interoperability and mixed-language scripts.

Time-of-day values are stored as writer-entered text. The language profile supplies suggestions and normalized comparison categories; it does not rewrite the heading.

## Character Cue Grammar

A character cue such as `SOFÍA` is recognized when:

- the line is Unicode uppercase-like;
- it satisfies the existing dialogue-context rules;
- it is not a scene heading, transition, or known shot construct;
- its base character name remains within the supported cue-length policy;
- optional cue extensions are parsed without stripping the original text.

Supported extensions include:

- `(V.O.)`
- `(O.S.)`
- `(O.C.)`
- `(CONT'D)`
- `(CONT.)`
- `(VOZ EN OFF)`
- `(FUERA DE CAMPO)`
- `(CONTINÚA)`

The core character identity must be derivable separately from the presentation cue so `SOFÍA (V.O.)` and `SOFÍA (VOZ EN OFF)` can resolve to the same canonical character profile when the writer chooses that behavior.

Forced character cues using Fountain `@` remain valid for names that are mixed case, long, numeric, or otherwise ambiguous:

```text
@Doña Sofía de la Cruz
```

## Parentheticals

Parentheticals remain delimited by parentheses and may contain any Unicode text:

```text
(susurrando)
(en español)
(a Íñigo)
(con una sonrisa)
```

Localized editor suggestions may include common Spanish parentheticals, but parser semantics depend on delimiters and dialogue context rather than a fixed word list.

Malformed parentheticals must preserve original text and produce a localized diagnostic.

## Transition Grammar

The Spanish profile recognizes these common transition forms case-insensitively while preserving original text:

- `CORTE A:`
- `CORTE DIRECTO A:`
- `DISOLVENCIA A:`
- `ENCADENA A:`
- `FUNDIDO A:`
- `FUNDIDO A NEGRO.`
- `FUNDIDO A BLANCO.`
- `ABRE DE NEGRO:`

English Fountain-compatible transitions remain accepted:

- `CUT TO:`
- `DISSOLVE TO:`
- `SMASH CUT TO:`
- `MATCH CUT TO:`
- `FADE IN:`
- `FADE OUT.`

Forced transitions using Fountain `>` remain language-neutral and always valid.

The transition vocabulary must be data-driven by screenplay-language profile rather than hard-coded as an expanding conditional inside the parser.

## Shot Grammar

Spanish shot aliases may be recognized as `shot` elements:

- `PRIMER PLANO:`
- `PLANO GENERAL:`
- `PLANO DETALLE:`
- `ÁNGULO SOBRE:`
- `INSERTAR:`
- `PUNTO DE VISTA:`

English shot forms remain accepted. Forced action using `!` must override ambiguous automatic classification.

## Title Page Localization

The title-page parser must support Unicode field labels and a locale-aware alias table.

Canonical title-page fields include:

| Semantic field | English aliases | Spanish aliases |
| --- | --- | --- |
| title | `Title` | `Título`, `Titulo` |
| credit | `Credit` | `Crédito`, `Credito` |
| author | `Author`, `Authors`, `Written by` | `Autor`, `Autores`, `Escrito por` |
| source | `Source` | `Fuente`, `Basado en` |
| draftDate | `Draft date`, `Date` | `Fecha de borrador`, `Fecha` |
| contact | `Contact` | `Contacto` |
| copyright | `Copyright` | `Derechos`, `Derechos de autor` |
| notes | `Notes` | `Notas` |

Aliases map to language-neutral semantic fields. The original label and value must remain available for lossless import/export. Unknown Unicode labels ending in `:` are preserved as custom title-page fields rather than discarded.

The current ASCII-only title-page-label rule must be replaced with Unicode letter support.

## Sections, Synopses, Notes, and Page Breaks

Fountain control markers remain language-neutral:

- `#` sections;
- `=` synopsis;
- `[[...]]` notes and TODO references;
- `===` page breaks;
- `!` forced action;
- `@` forced character;
- `>` forced transition;
- `.` forced scene heading.

Localized templates and editor help may describe these markers in Spanish, but the markers themselves are not translated.

TODO detection must accept configurable localized tokens while avoiding accidental conversion of normal dialogue. Initial accepted explicit tokens:

- `TODO:`
- `PENDIENTE:`
- `POR HACER:`

Example:

```text
[[PENDIENTE: revisar diálogo de SOFÍA]]
```

The note body remains exactly as written.

## Parser Architecture

Localization-sensitive parser vocabulary must be represented through portable data structures, for example:

- `ScreenplayLanguageProfile`;
- `SceneHeadingLexicon`;
- `TransitionLexicon`;
- `ShotLexicon`;
- `TitlePageFieldLexicon`;
- `TimeOfDayLexicon`;
- `TodoTokenLexicon`.

The parser receives a language profile or automatic composite profile. It must not depend on Foundation locale-sensitive casing that changes behavior unpredictably with the current app UI locale.

Recognition precedence remains deterministic:

1. notes and control markers;
2. forced Fountain constructs;
3. scene headings;
4. transitions;
5. shots;
6. character cues;
7. parentheticals/dialogue context;
8. action fallback.

Adding Spanish aliases must not reclassify existing accepted English fixtures.

## Automatic and Mixed-Language Parsing

`automatic` uses a deterministic union of English and Spanish lexicons.

Rules:

- acceptance of a construct must not depend on the user's macOS UI language;
- mixed-language scripts are supported;
- ambiguous lines preserve content and emit a diagnostic rather than being silently translated;
- automatic detection is line-oriented and does not change the project's declared screenplay language;
- explicit Fountain markers always take precedence over vocabulary detection.

## Editor Suggestions

Suggestions depend on the project screenplay-language profile:

- scene heading prefixes;
- location names from project data;
- English or Spanish time-of-day values;
- character names with accents preserved;
- transition suggestions;
- optional parenthetical suggestions;
- localized empty-editor examples.

For `automatic`, suggestions prioritize the most recently used construct language in the current document while still offering both languages through secondary results.

Autocomplete matching is case-insensitive and diacritic-insensitive, but accepted replacement text preserves the canonical project value or chosen localized suggestion.

## Search and Navigation

All M12 search surfaces must remain Unicode-aware under both locales. Search behavior must not change because the application UI language changes.

Examples:

- `sofia` matches `SOFÍA`;
- `cafe` matches `CAFÉ`;
- `corazon` matches `Corazón`;
- selecting a result navigates to the same semantic element regardless of locale.

## Diagnostics and Review Findings

Parser diagnostics use stable language-neutral codes and localized presentation messages.

Example codes:

- `invalidSceneHeading`;
- `ambiguousUppercaseLine`;
- `malformedParenthetical`;
- `unknownTitlePageField`;
- `ambiguousLocalizedConstruct`.

Rules:

- persisted diagnostics store code, source text, and structured arguments rather than only an English sentence;
- UI resolves the message in the current application locale;
- changing app language updates rendered diagnostic text without reparsing or mutating screenplay content;
- accessibility labels and suggested actions are localized;
- logs and support exports may include both stable code and localized message.

## UI Localization Scope

Every user-facing string in the macOS app must use localization resources, including:

- workspace section names;
- buttons and confirmation dialogs;
- search placeholders, filters, counts, and empty states;
- profile, note, scene, script, review, health, export, backup, restore, and library views;
- menu commands and keyboard-shortcut descriptions;
- error alerts and validation messages;
- accessibility labels, help text, and VoiceOver descriptions;
- onboarding and empty-editor examples;
- date, number, and list formatting.

Developer-facing identifiers, file extensions, semantic enum raw values, diagnostic codes, and interchange-format syntax are not localized.

## Formatting and Grammar

- Use locale-aware pluralization through String Catalog variations, not manual `count == 1` branching in localized UI.
- Use locale-aware list formatting for character and tag lists where presentation permits.
- Do not concatenate translated fragments to build sentences.
- Preserve product names, `.dreamjotter`, Fountain, FDX, JSON, PDF, and keyboard symbols unless a product glossary explicitly provides a localized term.
- Spanish terminology should be neutral and understandable in Mexico and Latin America; avoid Spain-only terms when a broadly understood alternative exists.

Initial terminology guidance:

| English | Spanish |
| --- | --- |
| Script | Guion |
| Screenplay | Guion cinematográfico |
| Scene | Escena |
| Character | Personaje |
| Location | Locación |
| Notes | Notas |
| Review | Revisión |
| Finding | Hallazgo |
| Draft | Borrador |
| Export | Exportar |
| Backup | Respaldo |
| Restore | Restaurar |
| Plotline | Trama |

Final Spanish copy must receive native-speaker review before release.

## Storage and Migration

- Existing project content remains valid without migration.
- New screenplay-language metadata must be optional and backward compatible.
- App-language preference is stored outside canonical project content.
- Localized UI strings are never persisted as semantic enum raw values.
- Stable codes and identifiers remain English-like implementation identifiers.
- Import/export must not depend on the current application locale.

## Export and Interoperability

- Fountain export preserves original screenplay text and accepted control syntax.
- FDX import/export preserves Unicode character names, dialogue, scene headings, and transitions.
- PDF layout supports Spanish glyphs and does not substitute or drop accents.
- Plain text, Markdown, JSON backup, and package persistence remain UTF-8.
- Exported dates and labels follow the selected export preset or document language, not accidentally the current UI locale.
- No export silently translates screenplay content.

## Accessibility

- Localized controls provide localized accessibility labels and hints.
- VoiceOver reading order remains stable in English and Spanish.
- Layout supports longer Spanish strings without clipping at the minimum supported window size.
- Dynamic text and control resizing must not hide primary actions.

## Executable Specification Matrix

Executable coverage must include at least:

1. `INT. CASA - NOCHE` parses as a scene heading.
2. `EXT. PARQUE - DÍA` preserves `DÍA`.
3. `SOFÍA` parses as a character cue before Spanish dialogue.
4. `ÍÑIGO (V.O.)` preserves the cue and resolves the base name.
5. `(susurrando)` parses as a parenthetical.
6. `CORTE A:` and `FUNDIDO A NEGRO.` parse as transitions.
7. `PRIMER PLANO:` parses as a shot.
8. `Título: El corazón de Sofía` parses as a title-page field.
9. Unknown Unicode title-page labels are preserved.
10. `[[PENDIENTE: revisar escena]]` remains a note/TODO projection.
11. English fixtures produce the same semantic result before and after Spanish support.
12. Mixed English/Spanish scripts parse deterministically in automatic mode.
13. Composed and decomposed accents compare equally for search without altering storage.
14. Save/reopen preserves locale metadata and all Unicode screenplay text.
15. Fountain, FDX, PDF, JSON backup, Markdown, and plain-text round trips preserve accents.
16. Diagnostics render in English and Spanish from the same stable code.
17. UI localization keys exist for every shipped English string.
18. Spanish pluralization is correct for zero, one, and multiple results.
19. Search and navigation return identical semantic targets under English and Spanish UI locales.
20. No localization key or untranslated English fallback appears in the normal Spanish UI smoke test.

## Fixtures

Add paired fixtures under `specs/fixtures/localization/`:

- `english-screenplay.fountain`;
- `spanish-mexico-screenplay.fountain`;
- `mixed-language-screenplay.fountain`;
- `unicode-normalization-screenplay.fountain`;
- `spanish-title-page.fountain`;
- `spanish-transitions-and-shots.fountain`;
- `spanish-malformed-constructs.fountain`.

Every fixture requires expected semantic elements, scenes, character identities, diagnostics, and round-trip expectations.

## Manual Acceptance

- Launch macOS in English and Spanish.
- Verify every workspace and dialog uses the chosen language.
- Create and edit a Spanish screenplay containing `INT. CASA - NOCHE`, `SOFÍA`, Spanish dialogue, parentheticals, transitions, shots, and TODO notes.
- Search without accents and navigate to accented results.
- Save, close, and reopen the package.
- Export Fountain, FDX, PDF, JSON backup, Markdown, and plain text.
- Confirm no accents, punctuation, or original construct wording are lost.
- Switch application language without changing screenplay content or semantic classification.
- Verify VoiceOver labels and long Spanish strings in narrow and standard window widths.

## Out of Scope

- Automatic machine translation of screenplay content;
- translating character names, locations, dialogue, or action;
- Spanish dubbing or subtitle generation;
- locale-specific screenplay pagination standards beyond glyph and label support;
- cloud translation services;
- languages other than English and Spanish in this slice.
