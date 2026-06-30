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
        #expect(expectations.count == 4)

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
