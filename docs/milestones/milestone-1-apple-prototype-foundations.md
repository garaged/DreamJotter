# Milestone 1: Apple Prototype Foundations

## Goal

Prove the core writing experience and portable architecture foundations before advanced features, production UI, or platform expansion. Milestone 1 defines how a future Apple prototype can exercise the semantic screenplay model, basic parsing, local project creation, scene and autocomplete foundations, and export abstractions without coupling core behavior to SwiftUI, AppKit, UIKit, TextKit, SwiftData, or any plugin runtime.

## Scope Summary

Milestone 1 includes specification for:

- Portable core module plan.
- Semantic screenplay model.
- Basic screenplay parser.
- Basic Fountain import/export.
- Local project creation concept.
- Editor behavior model, not full UI.
- Scene list foundation.
- Character autocomplete foundation.
- Location autocomplete foundation.
- PDF export abstraction.
- macOS/iPad/iPhone app shell expectations, not detailed UI implementation.
- Architecture guardrails.

Milestone 1 does not implement production code, create app UI, create an Xcode project, create a Swift package, or introduce plugin architecture.

## Feature Specifications

### M1-CORE-001: Portable Core Module Plan

User story: As a future DreamJotter implementer, I need a portable core boundary so screenplay behavior can be tested independently from Apple UI.

Engineering behavior: The future core should be planned as UI-independent modules for screenplay model, parsing, Fountain mapping, project package contracts, editor commands, export intent, and validation. Apple adapters may call the core; the core must not import or reference Apple UI frameworks.

Acceptance criteria:

- Core responsibilities are documented separately from Apple app shell responsibilities.
- Core behavior can be described as pure data transformations where practical.
- No Milestone 1 spec requires SwiftUI, AppKit, UIKit, TextKit, SwiftData, or a plugin runtime in the core.

Given/When/Then scenarios:

- Given a screenplay text fixture, when the future parser runs, then the result can be represented without UI view types.
- Given an export request, when the core prepares export intent, then platform rendering details remain outside the core.
- Given an Apple document shell, when it opens a project, then it delegates screenplay loading and validation to core contracts.

Data contract implications: Define stable model records for project metadata, screenplay document, screenplay elements, parse diagnostics, export requests, and export results in later data-contract specs.

Testability notes: Future tests should instantiate core model and parser behavior without launching an app, loading SwiftUI, or touching platform document APIs.

Non-goals:

- Creating a Swift package in this prompt.
- Implementing modules.
- Designing final package names or target layout.

### M1-MODEL-001: Semantic Screenplay Model

User story: As a writer, I want screenplay content to behave like scenes, action, characters, and dialogue rather than generic styled paragraphs.

Engineering behavior: The model must represent screenplay elements by meaning. Minimum Milestone 1 element types are title metadata, scene heading, action, character cue, parenthetical, dialogue, transition, and unknown/malformed text. Elements must preserve original text, normalized meaning where available, order, identity, and diagnostics.

Acceptance criteria:

- Empty screenplay is valid as an empty document with metadata and no elements.
- One-scene screenplay produces one scene heading plus ordered child content.
- Multi-scene screenplay preserves scene order and element order.
- Spanish and Unicode text is preserved without ASCII-only assumptions.
- Malformed text is preserved as unknown or diagnostic content rather than discarded.

Given/When/Then scenarios:

- Given an empty screenplay, when represented as a document, then it contains zero screenplay elements and no data loss.
- Given `INT. CAFE - DAY`, when modeled, then it is a scene heading element with original text preserved.
- Given `MARIA` followed by `No puedo dormir.`, when modeled, then `MARIA` is a character cue candidate and the following line is dialogue.
- Given `CORTE A:`, when modeled, then it can be represented as a transition element.
- Given `EXT. ZOCALO - NOCHE` and `La ciudad respira bajo la lluvia.`, when modeled, then Spanish text and accents are preserved.

Data contract implications: Element identity, element type, original text, normalized fields, diagnostics, and ordering need a dedicated screenplay model contract.

Testability notes: Future fixtures should include empty, one-scene, multi-scene, Unicode, and malformed screenplays.

Non-goals:

- Full production breakdown fields.
- Full revision metadata.
- Full FDX mapping.
- Rich text styling as canonical data.

### M1-PARSER-001: Basic Screenplay Parser

User story: As a writer importing or typing a simple script, I want DreamJotter to identify common screenplay elements automatically.

Engineering behavior: The parser should convert plain screenplay-like text into semantic elements using conservative rules. It should detect common scene headings, character dialogue blocks, parentheticals, transitions, and action. It should emit diagnostics for ambiguous or malformed text without dropping content.

Acceptance criteria:

- Detects scene headings beginning with common prefixes such as `INT.`, `EXT.`, `INT./EXT.`, and Spanish-compatible text after the prefix.
- Detects transitions such as `CUT TO:`, `FADE OUT.`, and `CORTE A:` when they appear as standalone transition-like lines.
- Detects character dialogue when an uppercase cue is followed by dialogue or parenthetical plus dialogue.
- Treats unsupported or ambiguous lines as action or unknown with diagnostics according to later parser rules.
- Preserves line order and original text.

Given/When/Then scenarios:

- Given an empty string, when parsed, then the result is an empty screenplay document with no fatal error.
- Given `INT. KITCHEN - DAY`, when parsed, then one scene heading is emitted.
- Given two scene headings separated by action, when parsed, then two scene records are discoverable in order.
- Given `ANA` followed by `(susurra)` and `Estoy aqui.`, when parsed, then a character cue, parenthetical, and dialogue are emitted.
- Given `MATCH CUT MAYBE` without punctuation or context, when parsed, then the parser preserves it and may mark it ambiguous instead of forcing a transition.

Data contract implications: Parser result must include parsed document, diagnostics, source ranges or line references, and confidence or reason codes where useful.

Testability notes: Parser fixtures should assert element sequence, original text preservation, diagnostics, and Unicode handling.

Non-goals:

- Perfect industry parser.
- Full Fountain grammar.
- Machine learning classification.
- Destructive auto-correction.

### M1-FOUNTAIN-001: Basic Fountain Import/Export

User story: As a writer, I want basic compatibility with Fountain so I can bring in or share simple screenplay drafts.

Engineering behavior: Import should map a supported Fountain subset into semantic screenplay elements. Export should produce readable Fountain from semantic elements. Unsupported syntax should be preserved where practical or reported as a diagnostic.

Acceptance criteria:

- Imports scene headings, action, character cues, parentheticals, dialogue, and transitions from simple Fountain.
- Exports the same core element types to valid readable Fountain text.
- Preserves Spanish and Unicode screenplay text.
- Reports unsupported Fountain constructs without failing the whole import when content can be preserved.

Given/When/Then scenarios:

- Given an empty Fountain file, when imported, then an empty screenplay document is produced.
- Given a one-scene Fountain draft, when imported then exported, then the scene heading and dialogue remain readable.
- Given multi-scene Fountain, when imported, then scene order is preserved.
- Given malformed Fountain markup, when imported, then unsupported markup is diagnosed and source text is preserved where practical.

Data contract implications: Need import diagnostics, export options, supported subset declaration, and round-trip limitation notes.

Testability notes: Future tests should compare semantic element sequences rather than byte-identical Fountain round trips.

Non-goals:

- Full Fountain coverage.
- Full round-trip fidelity for every Fountain extension.
- FDX import/export.

### M1-STORAGE-001: Local Project Creation Concept

User story: As a writer, I want to create a local DreamJotter project that I own and can move or back up.

Engineering behavior: Milestone 1 specifies the creation concept for a `.dreamjotter` package containing project metadata and semantic screenplay data. SwiftData may not be required to reconstruct the project.

Acceptance criteria:

- Project creation concept names `.dreamjotter` as the canonical package extension.
- Project metadata includes at least project identity, title, created date, modified date, schema version, and primary screenplay document reference.
- Empty project creation results in a valid empty screenplay document.
- Package contents are treated as local-first canonical data.

Given/When/Then scenarios:

- Given a new project title, when project creation is requested, then a `.dreamjotter` package concept is produced with metadata and an empty screenplay document.
- Given a project package without SwiftData, when opened by a future compatible app, then canonical screenplay data can still be loaded.
- Given malformed package metadata, when validation runs, then the project reports diagnostics instead of silently inventing missing state.

Data contract implications: Requires a later `.dreamjotter` package layout contract and schema versioning rules.

Testability notes: Future contract tests should validate package manifests, missing file behavior, and schema version handling.

Non-goals:

- Implementing file I/O.
- Choosing final JSON, plist, or other internal serialization formats.
- Cloud sync.
- SwiftData-backed canonical storage.

### M1-EDITOR-001: Editor Behavior Model

User story: As a beginner screenwriter, I want to type normally while DreamJotter keeps screenplay structure understandable.

Engineering behavior: Milestone 1 defines editor behavior as model transformations, not UI. The editor behavior model should describe insert text, split element, merge element, change element type, preserve original text, and expose diagnostics. UI rendering and TextKit integration are deferred.

Acceptance criteria:

- Editor actions are described as transformations on semantic elements.
- Empty document editing can create the first element.
- Splitting and merging elements preserves order and text unless the user explicitly changes content.
- Changing element type updates semantics without losing original text.

Given/When/Then scenarios:

- Given an empty screenplay, when the user enters a scene heading, then the document contains one scene heading element.
- Given an action paragraph, when the user changes it to a character cue, then the element type changes and text remains available.
- Given a dialogue line, when the user splits it, then two ordered dialogue elements or a valid dialogue continuation behavior is defined by later editor specs.

Data contract implications: Requires element identity stable enough for editing, diagnostics, scene list references, and undo in later milestones.

Testability notes: Future editor behavior tests should operate without UI by applying commands to model fixtures.

Non-goals:

- Full editing UI.
- TextKit wrapper design.
- Collaborative editing.
- Undo/redo implementation.

### M1-SCENELIST-001: Scene List Foundation

User story: As a writer, I want to see and navigate the scenes in my script.

Engineering behavior: Scene list foundation derives scene records from semantic scene heading elements. It should preserve document order, expose display title, source element reference, and minimal normalized location/time fields where detectable.

Acceptance criteria:

- Empty screenplay produces an empty scene list.
- One-scene screenplay produces one scene list item.
- Multi-scene screenplay produces scene list items in script order.
- Malformed scene headings are preserved and may receive diagnostics.

Given/When/Then scenarios:

- Given no scene headings, when scene list is generated, then no scene items are returned.
- Given `INT. APARTMENT - NIGHT`, when scene list is generated, then one item appears with the original heading text.
- Given `EXT. PARK - DAY` followed by `INT. CAR - NIGHT`, when scene list is generated, then park appears before car.
- Given `EXT. ZOCALO - NOCHE`, when scene list is generated, then Unicode-capable text is preserved.

Data contract implications: Scene list items need stable references to source elements and optional normalized fields.

Testability notes: Future tests should assert scene count, order, references, and preservation of original heading text.

Non-goals:

- Scene cards.
- Drag-and-drop reordering.
- Production breakdown.

### M1-CHARACTER-001: Character Autocomplete Foundation

User story: As a writer, I want character names to be suggested after I introduce them.

Engineering behavior: Character autocomplete foundation derives candidate names from semantic character cue elements. Suggestions should be case-aware, preserve Unicode names, and avoid treating every uppercase line as a character when parser diagnostics indicate ambiguity.

Acceptance criteria:

- Character cues are collected from parsed screenplay elements.
- Duplicate names normalize to one suggestion while preserving display text rules to be specified later.
- Spanish and Unicode names are supported.
- Ambiguous uppercase action lines are not guaranteed to become suggestions.

Given/When/Then scenarios:

- Given `MARIA` followed by dialogue, when autocomplete candidates are generated, then `MARIA` is included.
- Given `JOSE` and `JOSE` repeated, when candidates are generated, then duplicate suggestions are collapsed.
- Given `NIÑA` followed by dialogue, when candidates are generated, then `NIÑA` is preserved.
- Given `CUT TO:` when candidates are generated, then it is not treated as a character suggestion.

Data contract implications: Character candidate records need display name, normalized key, source references, and confidence or diagnostic linkage.

Testability notes: Future tests should cover duplicate collapse, Unicode names, transition exclusion, and malformed blocks.

Non-goals:

- Full character database.
- Alias management.
- Character profiles.
- Continuity warnings.

### M1-LOCATION-001: Location Autocomplete Foundation

User story: As a writer, I want previously used locations suggested when writing scene headings.

Engineering behavior: Location autocomplete foundation derives location candidates from semantic scene headings. It should parse simple heading patterns and preserve original location text when normalization is uncertain.

Acceptance criteria:

- Location candidates are collected from scene headings.
- Duplicate locations normalize to one suggestion where obvious.
- Spanish and Unicode location names are preserved.
- Malformed headings do not crash candidate generation.

Given/When/Then scenarios:

- Given `INT. CAFE - DAY`, when location candidates are generated, then `CAFE` is included.
- Given `EXT. ZOCALO - NOCHE`, when candidates are generated, then `ZOCALO` is included.
- Given two headings with `KITCHEN`, when candidates are generated, then duplicate suggestions are collapsed.
- Given malformed heading text, when candidates are generated, then diagnostics are allowed and valid candidates still return.

Data contract implications: Location candidate records need display name, normalized key, source scene references, and parse confidence.

Testability notes: Future tests should cover INT/EXT prefixes, duplicate normalization, Unicode preservation, and malformed heading resilience.

Non-goals:

- Location database.
- Production location management.
- Scheduling or budgeting.

### M1-PDF-001: PDF Export Abstraction

User story: As a writer, I want the product direction to support exporting scripts to PDF without locking core behavior to one renderer.

Engineering behavior: Milestone 1 defines export intent and boundaries. The portable core should produce an export request or intermediate representation from semantic elements. Platform adapters may render PDF later.

Acceptance criteria:

- PDF export is specified as an abstraction, not a concrete renderer.
- Export input is semantic screenplay data.
- Export output contract can represent success, failure, diagnostics, and generated artifact metadata.
- Platform-specific pagination and font handling are outside core Milestone 1 behavior.

Given/When/Then scenarios:

- Given an empty screenplay, when PDF export intent is requested, then the result can report a valid empty-document export or a clear diagnostic according to later export rules.
- Given a one-scene screenplay, when export intent is requested, then semantic elements appear in export order.
- Given Unicode screenplay text, when export intent is requested, then text is preserved for the renderer.

Data contract implications: Requires export request, export diagnostic, export artifact metadata, and renderer capability contracts.

Testability notes: Future tests should assert export order and diagnostics without creating actual PDFs in core tests.

Non-goals:

- Actual PDF rendering.
- Final screenplay pagination.
- Font selection.
- Export presets.

### M1-APPSHELL-001: macOS/iPad/iPhone App Shell Expectations

User story: As a writer, I want the first Apple prototype to open into a native-feeling writing environment across Mac, iPad, and iPhone.

Engineering behavior: Milestone 1 defines shell expectations only. macOS is first priority. iPadOS and iOS should be considered for layout and document handling implications, but detailed UI implementation is deferred.

Acceptance criteria:

- App shell expectations identify document creation/opening, editor container, scene list access, and export entry points at a high level.
- macOS expectations take priority when platform tradeoffs exist.
- iPad and iPhone expectations call out adaptation needs without final layouts.
- Shell must use core contracts rather than owning screenplay behavior.

Given/When/Then scenarios:

- Given a future macOS shell, when it opens a `.dreamjotter` project, then core contracts load screenplay data.
- Given a future iPad shell, when the user navigates scenes, then scene list data comes from semantic model output.
- Given a future iPhone shell, when editing is constrained by screen size, then screenplay semantics remain identical to macOS.

Data contract implications: Shell needs project open/create request contracts and view-model-safe outputs from core, but those outputs must not become core UI dependencies.

Testability notes: Future UI tests should verify shell workflows separately from core model tests.

Non-goals:

- Creating UI files.
- Choosing final navigation layout.
- Building an Xcode project.
- Implementing platform-specific document browsers.

### M1-GUARDRAILS-001: Architecture Guardrails

User story: As a maintainer, I want early constraints that prevent short-term prototype decisions from undermining portability.

Engineering behavior: Milestone 1 guardrails constrain implementation choices for later prompts. Core specs must forbid UI-framework coupling, keep `.dreamjotter` canonical, treat SwiftData as derived-only if used later, and avoid plugin-first design.

Acceptance criteria:

- No Milestone 1 deliverable requires production app code.
- No Milestone 1 deliverable requires app UI.
- No Milestone 1 deliverable requires an Xcode project.
- No Milestone 1 deliverable requires SwiftData as canonical storage.
- No Milestone 1 deliverable requires real AI provider integration or plugin runtime.

Given/When/Then scenarios:

- Given a future implementation proposal imports SwiftUI into the core, when checked against this spec, then it is rejected or moved behind an adapter boundary.
- Given a future storage proposal makes SwiftData canonical, when checked against this spec, then it is rejected.
- Given a future automation proposal requires arbitrary plugin code, when checked against this spec, then it is deferred beyond Milestone 1.

Data contract implications: Contracts must be platform-neutral and versioned where they affect `.dreamjotter` compatibility.

Testability notes: Future validation can include static checks for disallowed imports in core modules after code exists.

Non-goals:

- Building enforcement scripts now.
- Designing plugin APIs.
- Defining real AI providers.

## Milestone 1 Exit Criteria

Milestone 1 is ready for implementation only when later prompts have produced detailed contracts or executable fixtures for the semantic model, parser, Fountain subset, `.dreamjotter` package concept, and model-level editor behavior.

Milestone 1 is complete when future implementation can demonstrate:

- Empty screenplay handling.
- One-scene screenplay handling.
- Multi-scene screenplay handling.
- Spanish and Unicode text preservation.
- Malformed text preservation with diagnostics.
- Character dialogue detection.
- Scene heading detection.
- Transition detection.
- Scene list derivation.
- Character and location candidate derivation.
- PDF export intent from semantic screenplay data.
- Core behavior independent from Apple UI frameworks.
