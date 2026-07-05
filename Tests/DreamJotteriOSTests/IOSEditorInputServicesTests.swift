import DreamJotterCore
import DreamJotteriOS
import Testing

@Suite("iOS editor input services")
struct IOSEditorInputServicesTests {
    @Test("paste normalization removes platform-specific separators")
    func pasteNormalization() {
        let source = "A\r\nB\rC\u{00A0}D\u{2028}E\u{2029}F"
        #expect(IOSPasteNormalizer.normalize(source) == "A\nB\nC D\nE\n\nF")
    }

    @Test("autocomplete selection wraps and dismisses deterministically")
    func autocompleteSelectionState() {
        let first = EditorSuggestion(
            id: "one",
            type: .character,
            displayText: "ELENA",
            replacementText: "ELENA",
            textRange: EditorTextRange(location: 0, length: 1),
            source: .projectCharacters
        )
        let second = EditorSuggestion(
            id: "two",
            type: .character,
            displayText: "ELIAS",
            replacementText: "ELIAS",
            textRange: EditorTextRange(location: 0, length: 1),
            source: .projectCharacters
        )
        var state = IOSAutocompleteState(suggestions: [first, second])

        #expect(state.selectedSuggestion == first)
        #expect(state.moveSelection(by: -1))
        #expect(state.selectedSuggestion == second)
        #expect(state.moveSelection(by: 1))
        #expect(state.selectedSuggestion == first)
        state.dismiss()
        #expect(!state.isPresented)
        #expect(state.selectedSuggestion == nil)
    }

    @Test("replacing suggestions preserves a valid selection")
    func replacingSuggestionsClampsSelection() {
        let suggestions = (0..<3).map { index in
            EditorSuggestion(
                id: "s-\(index)",
                type: .character,
                displayText: "C\(index)",
                replacementText: "C\(index)",
                textRange: EditorTextRange(location: 0, length: 0),
                source: .projectCharacters
            )
        }
        var state = IOSAutocompleteState(suggestions: suggestions, selectedIndex: 2)
        state.replaceSuggestions(Array(suggestions.prefix(1)))
        #expect(state.selectedIndex == 0)
    }
}
