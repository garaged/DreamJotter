# M12.4 Localization and Spanish Screenplay Support

Status: implemented pending local validation

## Purpose

Provide a production-ready localization architecture for DreamJotter with English and Spanish support while preserving screenplay semantics, Unicode content, Fountain interoperability, deterministic parsing, local-first storage, search behavior, and export fidelity.

This slice covers two related but separate concerns:

1. **Application localization** — menus, buttons, labels, messages, diagnostics, accessibility text, onboarding, review findings, export UI, and system-facing copy.
2. **Screenplay-language support** — recognition and preservation of screenplay constructs written in English or Spanish, including scene headings, character cues, parentheticals, transitions, title-page fields, time-of-day labels, and editor suggestions.

Application language and screenplay language are independent. A writer may use the app in Spanish while writing an English screenplay, or use the app in English while writing a Spanish screenplay.

## Supported Locales

DreamJotter ships with:

- `en` — English base localization;
- `es-MX` — primary Spanish localization and terminology;
- `es-419` — Latin American Spanish fallback vocabulary and formatting behavior.

Fallback order:

1. exact locale, such as `es-MX`;
2. Latin American Spanish, `es-419`, for other Spanish locales in the Americas;
3. base Spanish resources when introduced;
4. English base resources;
5. stable localization key only in debug diagnostics, never as normal user-facing release text.

## Implementation Status

Implemented on `feature/m12-profile-management`:

- application-language override with System, English, and Spanish choices;
- English, `es-MX`, and `es-419` string resources;
- Automatic, English, and Latin American Spanish screenplay-language profiles;
- backward-compatible project-language persistence;
- English regression parser and bilingual semantic parser facade;
- Spanish scene-heading, transition, shot, title-page, TODO, and cue-extension lexicons;
- Unicode-safe character cues and title-page labels;
- original screenplay text restoration after semantic recognition;
- localized TODO projection for Notes and Dashboard;
- localized diagnostic message lookup;
- screenplay-language picker and localized editor guidance;
- executable parser and persistence coverage;
- English, Spanish, mixed-language, and invalid-input fixture files.

Local build, full test-suite, export round-trip, accessibility, layout, and native-speaker review remain required before acceptance.
