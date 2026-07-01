import Foundation
import DreamJotterCore
import SpecSupport
import Testing

@Suite("Milestone 1 Executable Specs")
struct Milestone1ExecutableSpecs {
    @Test("Required foundation specs exist")
    func requiredFoundationSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-1-apple-prototype-foundations.md",
            "docs/acceptance/milestone-1-acceptance.md",
            "docs/specs/product-requirements.md",
            "docs/data-contracts/core-domain-model.md",
            "docs/data-contracts/screenplay-element-kinds.md",
            "docs/data-contracts/serialization-rules.md",
            "docs/storage/dreamjotter-package-format.md",
            "docs/editor/screenplay-engine-spec.md",
            "docs/editor/fountain-support-spec.md",
            "docs/editor/editor-behavior-spec.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Architecture docs preserve core guardrails")
    func architectureDocsPreserveCoreGuardrails() throws {
        let architectureCorpus = try [
            "docs/architecture/overview.md",
            "docs/architecture/apple-native-first.md",
            "docs/architecture/portable-core.md",
            "docs/architecture/command-engine-spec.md"
        ]
        .map { try SpecRepository.read($0) }
        .joined(separator: "\n")

        #expect(SpecRepository.contains(architectureCorpus, "Apple-native first"))
        #expect(SpecRepository.contains(architectureCorpus, "portable core"))
        #expect(SpecRepository.contains(architectureCorpus, ".dreamjotter"))
        #expect(SpecRepository.contains(architectureCorpus, "commands before routines before plugins"))
        #expect(SpecRepository.contains(architectureCorpus, "SwiftData is not canonical storage"))
    }

    @Test("Registry spec paths exist")
    func registrySpecPathsExist() throws {
        let registry = try SpecRepository.registry()

        for item in registry.items {
            #expect(try SpecRepository.pathExists(item.spec))
            if let acceptance = item.acceptance, !acceptance.isEmpty {
                #expect(try SpecRepository.pathExists(acceptance))
            }
        }
    }

    @Test("Screenplay parser fixture expectations exist and point to source fixtures")
    func screenplayParserFixtureExpectationsExist() throws {
        let expectations = try ScreenplayFixtureExpectations.loadAll()
        #expect(expectations.count >= 5)

        for expectation in expectations {
            #expect(try SpecRepository.pathExists(expectation.fixture))
            #expect(!expectation.description.isEmpty)
            #expect(!expectation.expectedElements.isEmpty)
        }
    }

    @Test("Expected screenplay elements use canonical semantic kinds")
    func expectedScreenplayElementsUseCanonicalSemanticKinds() throws {
        let expectations = try ScreenplayFixtureExpectations.loadAll()
        let canonicalKinds = ScreenplayFixtureExpectations.canonicalElementKinds

        for expectation in expectations {
            for element in expectation.expectedElements {
                #expect(canonicalKinds.contains(element.kind), "Unexpected kind: \(element.kind) in \(expectation.fixture)")
                #expect(!element.text.isEmpty)
            }
        }
    }

    @Test("Simple fixture specifies one-scene semantic sequence")
    func simpleFixtureSpecifiesOneSceneSemanticSequence() throws {
        let expectation = try ScreenplayFixtureExpectations.load("specs/fixtures/screenplay/expected/simple.json")
        let sequence = expectation.expectedElements.map { $0.kind }

        #expect(sequence == ["titlePage", "sceneHeading", "action", "characterCue", "dialogue", "transition"])
        #expect(expectation.expectedScenes.map(\.heading) == ["INT. KITCHEN - DAY"])
        #expect(expectation.expectedCharacters == ["MARIA"])
        #expect(expectation.expectedDiagnostics.isEmpty)
    }

    @Test("Multi-scene fixture preserves scene and character order")
    func multiSceneFixturePreservesSceneAndCharacterOrder() throws {
        let expectation = try ScreenplayFixtureExpectations.load("specs/fixtures/screenplay/expected/multi-scene.json")
        let sceneHeadings = expectation.expectedScenes.map(\.heading)
        let dialogueTexts = expectation.expectedElements.filter { $0.kind == "dialogue" }.map(\.text)

        #expect(sceneHeadings == ["EXT. PARK - MORNING", "INT. CAR - CONTINUOUS"])
        #expect(expectation.expectedCharacters == ["ANA"])
        #expect(dialogueTexts == ["We are late.", "Try again."])
    }

    @Test("Spanish Unicode fixture preserves accents and dialogue semantics")
    func spanishUnicodeFixturePreservesAccentsAndDialogueSemantics() throws {
        let expectation = try ScreenplayFixtureExpectations.load("specs/fixtures/screenplay/expected/spanish-unicode.json")
        let allText = expectation.expectedElements.map(\.text).joined(separator: "\n")

        #expect(allText.contains("NIÑA"))
        #expect(allText.contains("¿Dónde está José?"))
        #expect(allText.contains("CORTE A:"))
        #expect(expectation.expectedElements.contains(ExpectedScriptElement(kind: "parenthetical", text: "(susurra)", characterName: "NIÑA")))
        #expect(expectation.expectedCharacters == ["NIÑA"])
    }

    @Test("Malformed fixture preserves text and declares diagnostics")
    func malformedFixturePreservesTextAndDeclaresDiagnostics() throws {
        let expectation = try ScreenplayFixtureExpectations.load("specs/fixtures/screenplay/expected/malformed.json")
        let kinds = expectation.expectedElements.map(\.kind)
        let diagnosticCodes = expectation.expectedDiagnostics.map(\.code)

        #expect(kinds.contains("unknown"))
        #expect(kinds.contains("noteReference"))
        #expect(expectation.expectedScenes.isEmpty)
        #expect(diagnosticCodes.contains("ambiguousUppercaseLine"))
        #expect(diagnosticCodes.contains("invalidSceneHeading"))
        #expect(diagnosticCodes.contains("malformedParenthetical"))
    }

    @Test("Advanced Fountain fixture covers extended Milestone 1 semantic kinds")
    func advancedFountainFixtureCoversExtendedMilestone1SemanticKinds() throws {
        let expectation = try ScreenplayFixtureExpectations.load("specs/fixtures/screenplay/expected/advanced.json")
        let sequence = expectation.expectedElements.map(\.kind)

        #expect(sequence.contains("section"))
        #expect(sequence.contains("synopsis"))
        #expect(sequence.contains("shot"))
        #expect(sequence.contains("pageBreak"))
        #expect(expectation.expectedElements.contains(ExpectedScriptElement(kind: "characterCue", text: "McClane")))
        #expect(expectation.expectedElements.contains(ExpectedScriptElement(kind: "dialogue", text: "Welcome to México.", characterName: "McClane")))
    }

    @Test("Character dialogue detection handles parentheticals")
    func characterDialogueDetectionHandlesParentheticals() {
        let source = """
        INT. ROOM - NIGHT

        JOSE
        (sotto)
        We have one chance.
        """
        let document = ScreenplayParser.parse(source)

        #expect(document.elements == [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - NIGHT"),
            ScriptElement(kind: .characterCue, text: "JOSE"),
            ScriptElement(kind: .parenthetical, text: "(sotto)", characterName: "JOSE"),
            ScriptElement(kind: .dialogue, text: "We have one chance.", characterName: "JOSE")
        ])
        #expect(document.characters == ["JOSE"])
        #expect(ScreenplayDerivedData.characterSuggestions(from: document) == [
            AutocompleteSuggestion(displayText: "JOSE", normalizedKey: "JOSE", sourceCount: 1)
        ])
    }

    @Test("Mixed interior exterior scene headings derive locations")
    func mixedInteriorExteriorSceneHeadingsDeriveLocations() {
        let source = """
        INT./EXT. TRAIN - SUNSET

        The doors slide open.
        """
        let document = ScreenplayParser.parse(source)
        let sceneList = ScreenplayDerivedData.sceneList(from: document)

        #expect(document.elements == [
            ScriptElement(kind: .sceneHeading, text: "INT./EXT. TRAIN - SUNSET"),
            ScriptElement(kind: .action, text: "The doors slide open.")
        ])
        #expect(sceneList.map(\.location) == ["TRAIN"])
        #expect(ScreenplayDerivedData.locationSuggestions(from: document) == [
            AutocompleteSuggestion(displayText: "TRAIN", normalizedKey: "TRAIN", sourceCount: 1)
        ])
    }

    @Test("Supported standalone transitions are not character suggestions")
    func supportedStandaloneTransitionsAreNotCharacterSuggestions() {
        let source = """
        INT. OFFICE - DAY

        The phone rings.

        FADE OUT.
        """
        let document = ScreenplayParser.parse(source)

        #expect(document.elements == [
            ScriptElement(kind: .sceneHeading, text: "INT. OFFICE - DAY"),
            ScriptElement(kind: .action, text: "The phone rings."),
            ScriptElement(kind: .transition, text: "FADE OUT.")
        ])
        #expect(ScreenplayDerivedData.characterSuggestions(from: document).isEmpty)
    }

    @Test("Semantic screenplay model remains independent from rich text storage")
    func semanticScreenplayModelRemainsIndependentFromRichTextStorage() throws {
        let elementKinds = try SpecRepository.read("docs/data-contracts/screenplay-element-kinds.md")
        let screenplayEngine = try SpecRepository.read("docs/editor/screenplay-engine-spec.md")

        #expect(SpecRepository.contains(elementKinds, "semantic kinds"))
        #expect(SpecRepository.contains(elementKinds, "not visual styling"))
        #expect(SpecRepository.contains(elementKinds, "Do not infer canonical meaning only from rich text"))
        #expect(SpecRepository.contains(screenplayEngine, "semantic project data"))
        #expect(SpecRepository.contains(screenplayEngine, "Malformed input must be recoverable"))
    }

    @Test("Parser output matches Milestone 1 semantic fixture expectations")
    func parserOutputMatchesMilestone1SemanticFixtureExpectations() throws {
        for expectation in try ScreenplayFixtureExpectations.loadAll() {
            let source = try SpecRepository.read(expectation.fixture)
            let document = ScreenplayParser.parse(source)

            #expect(document.elements.map(\.expectedElement) == expectation.expectedElements)
            #expect(document.scenes.map(\.expectedScene) == expectation.expectedScenes)
            #expect(document.characters == expectation.expectedCharacters)
            #expect(document.diagnostics.map(\.expectedDiagnostic) == expectation.expectedDiagnostics)
        }
    }

    @Test("Empty screenplay parses without elements, scenes, characters, or diagnostics")
    func emptyScreenplayParsesWithoutElementsScenesCharactersOrDiagnostics() {
        let document = ScreenplayParser.parse("")

        #expect(document.elements.isEmpty)
        #expect(document.scenes.isEmpty)
        #expect(document.characters.isEmpty)
        #expect(document.diagnostics.isEmpty)
    }

    @Test("Fountain import uses semantic parser output")
    func fountainImportUsesSemanticParserOutput() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/simple.fountain")

        #expect(FountainIO.importScreenplay(source) == ScreenplayParser.parse(source))
    }

    @Test("Fountain export preserves supported semantic content")
    func fountainExportPreservesSupportedSemanticContent() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/spanish-unicode.fountain")
        let document = ScreenplayParser.parse(source)
        let exported = FountainIO.exportScreenplay(document)

        #expect(exported.contains("Title: La Noche Larga"))
        #expect(exported.contains("EXT. ZOCALO - NOCHE"))
        #expect(exported.contains("NIÑA"))
        #expect(exported.contains("¿Dónde está José?"))
        #expect(exported.contains("CORTE A:"))
    }

    @Test("Fountain semantic round trip preserves fixture elements")
    func fountainSemanticRoundTripPreservesFixtureElements() throws {
        for expectation in try ScreenplayFixtureExpectations.loadAll() {
            let source = try SpecRepository.read(expectation.fixture)
            let imported = FountainIO.importScreenplay(source)
            let exported = FountainIO.exportScreenplay(imported)
            let reimported = FountainIO.importScreenplay(exported)

            #expect(reimported.elements.map(\.expectedElement) == expectation.expectedElements)
            #expect(reimported.scenes.map(\.expectedScene) == expectation.expectedScenes)
            #expect(reimported.characters == expectation.expectedCharacters)
            #expect(reimported.diagnostics.map(\.expectedDiagnostic) == expectation.expectedDiagnostics)
        }
    }

    @Test("Scene list derives ordered scenes from semantic document")
    func sceneListDerivesOrderedScenesFromSemanticDocument() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/multi-scene.fountain")
        let document = ScreenplayParser.parse(source)
        let sceneList = ScreenplayDerivedData.sceneList(from: document)

        #expect(sceneList.map(\.index) == [0, 1])
        #expect(sceneList.map(\.heading) == ["EXT. PARK - MORNING", "INT. CAR - CONTINUOUS"])
        #expect(sceneList.map(\.location) == ["PARK", "CAR"])
        #expect(sceneList.map(\.timeOfDay) == ["MORNING", "CONTINUOUS"])
    }

    @Test("Character autocomplete collapses duplicates and preserves Unicode display names")
    func characterAutocompleteCollapsesDuplicatesAndPreservesUnicodeDisplayNames() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/spanish-unicode.fountain")
        let document = ScreenplayParser.parse(source)
        let suggestions = ScreenplayDerivedData.characterSuggestions(from: document)

        #expect(suggestions == [
            AutocompleteSuggestion(displayText: "NIÑA", normalizedKey: "NINA", sourceCount: 1)
        ])
    }

    @Test("Character autocomplete excludes ambiguous uppercase action and transitions")
    func characterAutocompleteExcludesAmbiguousUppercaseActionAndTransitions() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/malformed.fountain")
        let document = ScreenplayParser.parse(source)
        let suggestions = ScreenplayDerivedData.characterSuggestions(from: document)

        #expect(suggestions == [
            AutocompleteSuggestion(displayText: "JOSE", normalizedKey: "JOSE", sourceCount: 1)
        ])
    }

    @Test("Location autocomplete derives unique locations from scene headings")
    func locationAutocompleteDerivesUniqueLocationsFromSceneHeadings() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/multi-scene.fountain")
        let document = ScreenplayParser.parse(source)
        let suggestions = ScreenplayDerivedData.locationSuggestions(from: document)

        #expect(suggestions == [
            AutocompleteSuggestion(displayText: "PARK", normalizedKey: "PARK", sourceCount: 1),
            AutocompleteSuggestion(displayText: "CAR", normalizedKey: "CAR", sourceCount: 1)
        ])
    }

    @Test("Smart Enter predicts next semantic kind without UI dependencies")
    func smartEnterPredictsNextSemanticKindWithoutUIDependencies() {
        #expect(EditorBehavior.nextKindAfterReturn(from: nil) == .sceneHeading)
        #expect(EditorBehavior.nextKindAfterReturn(from: .sceneHeading) == .action)
        #expect(EditorBehavior.nextKindAfterReturn(from: .characterCue) == .dialogue)
        #expect(EditorBehavior.nextKindAfterReturn(from: .parenthetical) == .dialogue)
        #expect(EditorBehavior.nextKindAfterReturn(from: .dialogue, mode: .simple) == .action)
        #expect(EditorBehavior.nextKindAfterReturn(from: .dialogue, mode: .pro) == .characterCue)
        #expect(EditorBehavior.nextKindAfterReturn(from: .transition) == .sceneHeading)
    }

    @Test("Tab cycles screenplay element kind deterministically")
    func tabCyclesScreenplayElementKindDeterministically() {
        #expect(EditorBehavior.cycleKindAfterTab(from: .action) == .characterCue)
        #expect(EditorBehavior.cycleKindAfterTab(from: .sceneHeading) == .action)
        #expect(EditorBehavior.cycleKindAfterTab(from: .noteReference) == .action)
        #expect(EditorBehavior.cycleKindAfterTab(from: .unknown) == .action)
    }

    @Test("Scene heading prefix detection supports common prefixes")
    func sceneHeadingPrefixDetectionSupportsCommonPrefixes() {
        #expect(EditorBehavior.isSceneHeadingPrefix("INT."))
        #expect(EditorBehavior.isSceneHeadingPrefix("EXT."))
        #expect(EditorBehavior.isSceneHeadingPrefix("INT./EXT."))
        #expect(!EditorBehavior.isSceneHeadingPrefix("CUT TO:"))
    }

    @Test("TODO detection is advisory and preserves text")
    func todoDetectionIsAdvisoryAndPreservesText() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/malformed.fountain")
        let document = ScreenplayParser.parse(source)
        let todos = EditorBehavior.todoNotes(in: document)

        #expect(todos == ["TODO: clarify whether this is a note"])
        #expect(document.elements.contains(ScriptElement(kind: .noteReference, text: "TODO: clarify whether this is a note")))
    }

    @Test("Blank project creation produces local-first dreamjotter package concept")
    func blankProjectCreationProducesLocalFirstDreamJotterPackageConcept() {
        let createdAt = Date(timeIntervalSince1970: 1_782_777_600)
        let project = ProjectFactory.createBlankProject(
            title: "  La Noche Larga  ",
            projectID: "project-001",
            screenplayID: "screenplay-001",
            createdAt: createdAt
        )

        #expect(project.metadata.id == "project-001")
        #expect(project.metadata.title == "La Noche Larga")
        #expect(project.metadata.createdAt == createdAt)
        #expect(project.metadata.modifiedAt == createdAt)
        #expect(project.metadata.schemaVersion == ProjectFactory.currentSchemaVersion)
        #expect(project.metadata.primaryScreenplayID == "screenplay-001")
        #expect(project.metadata.packageExtension == ".dreamjotter")
        #expect(ProjectFactory.packageName(for: project) == "La Noche Larga.dreamjotter")
        #expect(project.screenplay.elements.isEmpty)
    }

    @Test("PDF export intent preserves semantic order without rendering")
    func pdfExportIntentPreservesSemanticOrderWithoutRendering() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/spanish-unicode.fountain")
        let document = ScreenplayParser.parse(source)
        let intent = ExportIntentBuilder.pdfIntent(for: document, title: "La Noche Larga")

        #expect(intent.format == .pdf)
        #expect(intent.documentTitle == "La Noche Larga")
        #expect(intent.elements == document.elements)
        #expect(intent.elements.map(\.text).contains("¿Dónde está José?"))
        #expect(intent.diagnostics.isEmpty)
    }

    @Test("Portable core value types support Codable round trip")
    func portableCoreValueTypesSupportCodableRoundTrip() throws {
        let source = try SpecRepository.read("specs/fixtures/screenplay/spanish-unicode.fountain")
        let document = ScreenplayParser.parse(source)
        let encodedDocument = try JSONEncoder().encode(document)
        let decodedDocument = try JSONDecoder().decode(ScreenplayDocument.self, from: encodedDocument)

        let project = ProjectFactory.createBlankProject(
            title: "Codable Project",
            projectID: "project-codable",
            screenplayID: "screenplay-codable",
            createdAt: Date(timeIntervalSince1970: 1_782_777_600)
        )
        let encodedProject = try JSONEncoder().encode(project)
        let decodedProject = try JSONDecoder().decode(DreamJotterProject.self, from: encodedProject)

        #expect(decodedDocument == document)
        #expect(decodedProject == project)
    }

    @Test("Portable core source avoids Apple UI storage and cloud framework imports")
    func portableCoreSourceAvoidsAppleUIStorageAndCloudFrameworkImports() throws {
        let sourceFiles = [
            "Sources/DreamJotterCore/EditorBehavior.swift",
            "Sources/DreamJotterCore/ExportIntent.swift",
            "Sources/DreamJotterCore/FountainIO.swift",
            "Sources/DreamJotterCore/ProjectFoundation.swift",
            "Sources/DreamJotterCore/ScreenplayDerivedData.swift",
            "Sources/DreamJotterCore/ScreenplayModel.swift",
            "Sources/DreamJotterCore/ScreenplayParser.swift",
            "Sources/DreamJotterCore/SemanticValidation.swift"
        ]
        let forbiddenImports = ["SwiftUI", "AppKit", "UIKit", "SwiftData", "CloudKit"]

        for sourceFile in sourceFiles {
            let source = try SpecRepository.read(sourceFile)
            for forbiddenImport in forbiddenImports {
                #expect(!source.contains("import \(forbiddenImport)"), "\(sourceFile) imports \(forbiddenImport)")
            }
        }
    }

    @Test("Semantic validation accepts parsed Milestone 1 fixtures")
    func semanticValidationAcceptsParsedMilestone1Fixtures() throws {
        for expectation in try ScreenplayFixtureExpectations.loadAll() {
            let source = try SpecRepository.read(expectation.fixture)
            let document = ScreenplayParser.parse(source)

            #expect(SemanticValidator.validate(document: document).isEmpty)
        }
    }

    @Test("Semantic validation reports broken dialogue and scene references")
    func semanticValidationReportsBrokenDialogueAndSceneReferences() {
        let document = ScreenplayDocument(
            elements: [
                ScriptElement(kind: .dialogue, text: "No cue yet.", characterName: "GHOST")
            ],
            scenes: [
                Scene(heading: "INT. LOST ROOM - NIGHT", location: "LOST ROOM", timeOfDay: "NIGHT")
            ],
            characters: [],
            diagnostics: []
        )
        let issues = SemanticValidator.validate(document: document)
        let codes = issues.map(\.code)

        #expect(codes.contains("unknownDialogueCharacter"))
        #expect(codes.contains("sceneWithoutHeadingElement"))
    }

    @Test("Project validation enforces dreamjotter package metadata")
    func projectValidationEnforcesDreamJotterPackageMetadata() {
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "",
                title: "Broken",
                createdAt: Date(timeIntervalSince1970: 1_782_777_600),
                modifiedAt: Date(timeIntervalSince1970: 1_782_777_600),
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "",
                packageExtension: ".txt"
            ),
            screenplay: ScreenplayDocument()
        )
        let codes = SemanticValidator.validate(project: project).map(\.code)

        #expect(codes.contains("missingProjectID"))
        #expect(codes.contains("missingPrimaryScreenplayID"))
        #expect(codes.contains("invalidPackageExtension"))
    }
}

private extension ScriptElement {
    var expectedElement: ExpectedScriptElement {
        ExpectedScriptElement(
            kind: kind.rawValue,
            text: text,
            characterName: characterName
        )
    }
}

private extension Scene {
    var expectedScene: ExpectedScene {
        ExpectedScene(
            heading: heading,
            location: location,
            timeOfDay: timeOfDay
        )
    }
}

private extension ScreenplayDiagnostic {
    var expectedDiagnostic: ExpectedDiagnostic {
        ExpectedDiagnostic(
            code: code,
            message: message,
            text: text
        )
    }
}
