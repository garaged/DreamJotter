import DreamJotterCore
import Foundation
import Testing

@Suite("M13 Character Cue Engine")
struct CharacterCueEngineExecutableSpecs {
    @Test("Combined cues recognize supported separators and Unicode names")
    func combinedCueNames() {
        #expect(CharacterCueEngine.names(in: "SOFÍA / TOM") == ["SOFÍA", "TOM"])
        #expect(CharacterCueEngine.names(in: "@ÍÑIGO & DOÑA ÁNGELES") == ["ÍÑIGO", "DOÑA ÁNGELES"])
        #expect(CharacterCueEngine.names(in: "MARA Y ELENA") == ["MARA", "ELENA"])
        #expect(CharacterCueEngine.names(in: "MARA AND ELENA") == ["MARA", "ELENA"])
    }

    @Test("Canonical combined cue is stable and deduplicated")
    func canonicalCue() {
        #expect(
            CharacterCueEngine.canonicalCue(
                names: ["Sofía", "Tom", "SOFÍA"],
                explicit: true
            ) == "@SOFÍA / TOM"
        )
    }

    @Test("Suggestion context replaces only active combined-cue segment")
    func activeSegmentRange() {
        let line = "@SOFÍA / TO"
        let context = CharacterCueEngine.suggestionContext(
            in: line,
            lineStart: 100,
            cursorLocation: 100 + (line as NSString).length
        )

        #expect(context.query == "TO")
        #expect(context.existingNames == ["SOFÍA"])
        #expect(context.replacementRange == EditorTextRange(location: 109, length: 2))
    }

    @Test("Suggestions are accent insensitive ranked and exclude existing speakers")
    func robustSuggestions() {
        let context = CharacterCueSuggestionContext(
            query: "ang",
            replacementRange: EditorTextRange(location: 20, length: 3),
            existingNames: ["SOFÍA"]
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["Sofía", "Doña Ángeles", "Ángel", "Mara", "Ángel"]
        )

        #expect(suggestions.map(\.displayText) == ["Ángel", "Doña Ángeles"])
        #expect(suggestions.allSatisfy { $0.textRange == context.replacementRange })
        #expect(!suggestions.contains { $0.displayText == "Sofía" })
    }

    @Test("Combined cue parses as one cue while registering each character")
    func combinedCueParsing() {
        let document = ScreenplayParser.parse("""
        INT. ROOM - DAY

        SOFÍA / TOM
        We both saw it.
        """)

        #expect(document.elements.map(\.paragraphType) == [.sceneHeading, .characterCue, .dialogue])
        #expect(document.elements[1].text == "SOFÍA / TOM")
        #expect(document.characters.contains("SOFÍA"))
        #expect(document.characters.contains("TOM"))
    }

    @Test("Combined cue remains a character cue in PDF planning")
    func combinedCuePDFPlanning() throws {
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "combined-cue",
                title: "Combined Cue",
                createdAt: .distantPast,
                modifiedAt: .distantPast,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay"
            ),
            screenplay: ScreenplayParser.parse("SOFÍA / TOM\nWe agree.")
        )
        let preset = try #require(
            ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" }
        )
        let plan = PDFLayoutPlanner.plan(
            for: project,
            preset: preset,
            settings: PDFLayoutSettings(includeTitlePage: false)
        )
        let blocks = try #require(plan.contentPages.first?.blocks)

        #expect(blocks.map(\.role) == [.characterCue, .dialogue])
    }
}
