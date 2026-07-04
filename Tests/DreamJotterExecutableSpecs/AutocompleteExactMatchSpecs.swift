import DreamJotterCore
import Testing

@Suite("Autocomplete Exact Match Suppression")
struct AutocompleteExactMatchSpecs {
    @Test("Completed character name is not suggested again")
    func completedCharacterNameIsSuppressed() {
        let context = CharacterCueEngine.suggestionContext(
            in: "SOFÍA",
            lineStart: 0,
            cursorLocation: 5
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["SOFÍA", "SOFÍA (V.O.)", "TOM"]
        )

        #expect(suggestions.isEmpty)
    }

    @Test("Exact matching is case and accent insensitive")
    func normalizedExactMatchIsSuppressed() {
        let context = CharacterCueSuggestionContext(
            query: "sofia",
            replacementRange: EditorTextRange(location: 0, length: 5),
            existingNames: []
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["SOFÍA", "TOM"]
        )

        #expect(suggestions.isEmpty)
    }

    @Test("Partial character name still suggests completion")
    func partialNameStillSuggests() {
        let context = CharacterCueSuggestionContext(
            query: "sof",
            replacementRange: EditorTextRange(location: 0, length: 3),
            existingNames: []
        )
        let suggestions = CharacterCueEngine.suggestions(
            context: context,
            characters: ["SOFÍA", "TOM"]
        )

        #expect(suggestions.map(\.displayText) == ["SOFÍA"])
    }
}
