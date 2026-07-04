import DreamJotterCore
import Testing

@Suite("Scene Heading Autocomplete Engine")
struct SceneHeadingAutocompleteEngineSpecs {
    private let scenes = [
        Scene(heading: "INT. APARTMENT - NIGHT", location: "APARTMENT", timeOfDay: "NIGHT"),
        Scene(heading: "EXT. CITY STREET - DAY", location: "CITY STREET", timeOfDay: "DAY")
    ]

    @Test("Partial heading prefix suggests supported forms")
    func prefixStage() {
        let suggestions = SceneHeadingAutocompleteEngine.suggestions(
            line: "IN",
            lineStart: 10,
            cursorLocation: 12,
            scenes: scenes,
            language: .english
        )

        #expect(suggestions.map(\.replacementText).contains("INT. "))
        #expect(suggestions.allSatisfy { $0.textRange == EditorTextRange(location: 10, length: 2) })
    }

    @Test("Location stage replaces only location and appends separator")
    func locationStage() throws {
        let line = "INT. APA"
        let suggestions = SceneHeadingAutocompleteEngine.suggestions(
            line: line,
            lineStart: 20,
            cursorLocation: 20 + line.utf16.count,
            scenes: scenes,
            language: .english
        )
        let apartment = try #require(suggestions.first { $0.displayText == "APARTMENT" })

        #expect(apartment.replacementText == "APARTMENT - ")
        #expect(apartment.textRange == EditorTextRange(location: 25, length: 3))
    }

    @Test("Time stage uses localized values and active segment range")
    func timeStage() throws {
        let line = "INT. DEPARTAMENTO - MA"
        let suggestions = SceneHeadingAutocompleteEngine.suggestions(
            line: line,
            lineStart: 100,
            cursorLocation: 100 + line.utf16.count,
            scenes: [],
            language: .spanishLatinAmerica
        )
        let morning = try #require(suggestions.first { $0.displayText == "MAÑANA" })

        #expect(morning.replacementText == "MAÑANA")
        #expect(morning.textRange.location == 119)
        #expect(morning.textRange.length == 2)
    }

    @Test("Location matching is case and accent insensitive")
    func normalizedLocationMatching() {
        let accented = [Scene(heading: "INT. CAFÉ - DÍA", location: "CAFÉ", timeOfDay: "DÍA")]
        let suggestions = SceneHeadingAutocompleteEngine.suggestions(
            line: "INT. cafe",
            lineStart: 0,
            cursorLocation: 9,
            scenes: accented,
            language: .spanishLatinAmerica
        )

        #expect(suggestions.map(\.displayText) == ["CAFÉ"])
    }
}
