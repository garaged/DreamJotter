# Milestone 11 Acceptance — FDX Interoperability Foundation

Status: implemented

Milestone 11 is accepted when:

- `FDXInterchange.export` emits UTF-8 Final Draft XML for the supported screenplay subset.
- Scene headings, action, character cues, parentheticals, dialogue, transitions, and shots map deterministically.
- XML-sensitive characters and Unicode text survive export and import.
- Supported content round-trips without changing semantic element order or text.
- DreamJotter-only note references and explicit page breaks are omitted with warnings.
- Unknown FDX paragraph types remain visible as `.unknown` elements with deterministic warnings.
- Malformed XML returns no partial screenplay and includes an error diagnostic.
- Imported scene headings and character cues rebuild derived scene and character data.
- Network and external-resource lookup stay disabled during parsing.
- `.dreamjotter` remains canonical storage and import returns a candidate `ScreenplayDocument`.

## Executable Coverage

`Tests/DreamJotterExecutableSpecs/FDXInterchangeExecutableSpecs.swift` covers paragraph mapping, XML escaping, Unicode import, semantic round trip, omission warnings, unknown paragraph types, and malformed XML.

## Deferred Beyond M11

- title-page metadata mapping;
- Final Draft revision metadata;
- dual dialogue and advanced formatting spans;
- application-level import presentation and project integration;
- compatibility fixtures from multiple Final Draft application versions.
