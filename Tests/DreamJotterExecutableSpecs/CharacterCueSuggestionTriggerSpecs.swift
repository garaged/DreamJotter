import DreamJotterCore
import Testing

@Suite("Character Cue Suggestion Triggers")
struct CharacterCueSuggestionTriggerSpecs {
    @Test("Empty paragraph does not activate suggestions")
    func emptyParagraphDoesNotSuggest() {
        let context = CharacterCueEngine.suggestionContext(
            in: "",
            lineStart: 40,
            cursorLocation: 40
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["Alex", "Sofia", "Tom"]
        )

        #expect(context.query.isEmpty)
        #expect(!context.isExplicitCue)
        #expect(suggestions.isEmpty)
    }

    @Test("Explicit cue marker can request all characters")
    func explicitCueMarkerSuggests() {
        let context = CharacterCueEngine.suggestionContext(
            in: "@",
            lineStart: 12,
            cursorLocation: 13
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["Alex", "Sofia", "Tom"]
        )

        #expect(context.query.isEmpty)
        #expect(context.isExplicitCue)
        #expect(suggestions.map(\.displayText) == ["Alex", "Sofia", "Tom"])
    }
}
