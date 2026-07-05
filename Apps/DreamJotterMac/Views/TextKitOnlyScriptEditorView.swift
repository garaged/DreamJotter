import DreamJotterCore
import SwiftUI

struct TextKitOnlyScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var searchText = ""
    @State private var selectedMatchIndex = 0
    @State private var suggestions: [EditorSuggestion] = []
    @State private var selectedSuggestionIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(document.project.metadata.title)
                .font(.title2.weight(.semibold))
                .lineLimit(1)
                .truncationMode(.tail)

            HStack(spacing: 10) {
                ScreenplayLanguagePicker(document: $document)
                Button("Refresh Parse") { document.refreshParseRespectingLanguage() }
                Spacer(minLength: 0)
            }

            searchBar

            TextKitScreenplayEditorView(
                text: Binding(
                    get: { document.scriptText },
                    set: { document.updateScriptTextRespectingLanguage($0) }
                ),
                navigationState: document.editorNavigationState,
                styleRuns: ScreenplayParagraphTypeControl.styleRuns(in: document.scriptText),
                onSmartEnter: { location in
                    document.performSmartEnterRespectingLanguage(at: location)
                    refreshSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
                },
                onTabCycle: { location in
                    document.performTabCycleRespectingLanguage(at: location)
                    refreshSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
                },
                onTextChanged: refreshSuggestions,
                onSelectionChanged: { location in
                    document.updateSelectedSceneForCursor(location: location)
                    refreshSuggestions(cursorLocation: location)
                },
                onSuggestionMove: moveSuggestionSelection,
                onSuggestionAccept: acceptSelectedSuggestion,
                onSuggestionDismiss: dismissSuggestions,
                onNavigationApplied: { document.clearEditorNavigationRequest() }
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(alignment: .topLeading) {
                if document.isEmptyEditorGuidanceVisible {
                    EmptyScriptGuidance(language: document.screenplayLanguage)
                        .padding(20)
                        .allowsHitTesting(false)
                }
            }

            SuggestionsPanel(
                suggestions: suggestions,
                selectedIndex: selectedSuggestionIndex,
                acceptAction: acceptSuggestion,
                ignoreAction: { _ = dismissSuggestions() }
            )
        }
        .padding()
        .onChange(of: searchText) { _, _ in
            selectedMatchIndex = 0
            navigateToSelectedMatch()
        }
        .onChange(of: document.scriptText) { _, _ in
            selectedMatchIndex = min(selectedMatchIndex, max(matches.count - 1, 0))
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Find in script", text: $searchText)
                .textFieldStyle(.roundedBorder)
            Text(matchSummary)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 72, alignment: .trailing)
            Button(action: selectPreviousMatch) { Image(systemName: "chevron.up") }
                .disabled(matches.isEmpty)
                .help("Previous match")
                .accessibilityLabel("Previous match")
            Button(action: selectNextMatch) { Image(systemName: "chevron.down") }
                .disabled(matches.isEmpty)
                .help("Next match")
                .accessibilityLabel("Next match")
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    selectedMatchIndex = 0
                }
            }
        }
    }

    private func refreshSuggestions(cursorLocation: Int) {
        let currentLine = EditorUsabilityService.currentLine(in: document.scriptText, cursorLocation: cursorLocation)
        let lineStart = currentLine.range.location
        let lineLength = (currentLine.text as NSString).length
        let safeCursor = min(max(cursorLocation, lineStart), lineStart + lineLength)
        let prefixLength = safeCursor - lineStart
        let prefix = (currentLine.text as NSString).substring(with: NSRange(location: 0, length: prefixLength))

        if isSceneHeadingDraft(prefix) {
            suggestions = SceneHeadingAutocompleteEngine.suggestions(
                line: currentLine.text,
                lineStart: lineStart,
                cursorLocation: safeCursor,
                scenes: document.scenes,
                language: document.screenplayLanguage
            )
        } else {
            let context = CharacterCueEngine.suggestionContext(
                in: currentLine.text,
                lineStart: lineStart,
                cursorLocation: safeCursor
            )
            suggestions = CharacterCueEngine.suggestions(
                context: context,
                characters: document.characters.map(\.displayName)
            )
        }
        selectedSuggestionIndex = suggestions.isEmpty ? 0 : min(selectedSuggestionIndex, suggestions.count - 1)
    }

    private func isSceneHeadingDraft(_ text: String) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !value.isEmpty else { return false }
        let prefixes = ["INT.", "EXT.", "INT./EXT.", "EXT./INT.", "I/E."]
        return prefixes.contains { $0.hasPrefix(value) || value.hasPrefix($0) }
    }

    private func moveSuggestionSelection(by offset: Int) -> Bool {
        guard !suggestions.isEmpty else { return false }
        selectedSuggestionIndex = (selectedSuggestionIndex + offset + suggestions.count) % suggestions.count
        return true
    }

    private func acceptSelectedSuggestion() -> Bool {
        guard suggestions.indices.contains(selectedSuggestionIndex) else { return false }
        acceptSuggestion(suggestions[selectedSuggestionIndex])
        return true
    }

    private func acceptSuggestion(_ suggestion: EditorSuggestion) {
        document.acceptEditorSuggestionRespectingLanguage(suggestion)
        document.requestNavigation(toTextRange: EditorTextRange(
            location: suggestion.textRange.location + (suggestion.replacementText as NSString).length,
            length: 0
        ))
        suggestions = []
        selectedSuggestionIndex = 0
    }

    private func dismissSuggestions() -> Bool {
        guard !suggestions.isEmpty else { return false }
        suggestions = []
        selectedSuggestionIndex = 0
        document.ignoreEditorSuggestions()
        return true
    }

    private var matches: [EditorTextRange] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        let source = document.scriptText as NSString
        var results: [EditorTextRange] = []
        var searchRange = NSRange(location: 0, length: source.length)
        while searchRange.length > 0 {
            let range = source.range(of: query, options: [.caseInsensitive, .diacriticInsensitive], range: searchRange)
            guard range.location != NSNotFound else { break }
            results.append(EditorTextRange(location: range.location, length: range.length))
            let next = range.location + max(range.length, 1)
            guard next <= source.length else { break }
            searchRange = NSRange(location: next, length: source.length - next)
        }
        return results
    }

    private var matchSummary: String {
        guard !searchText.isEmpty else { return "" }
        guard !matches.isEmpty else { return String(localized: "No matches") }
        return String(format: String(localized: "%lld of %lld"), selectedMatchIndex + 1, matches.count)
    }

    private func selectNextMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = (selectedMatchIndex + 1) % matches.count
        navigateToSelectedMatch()
    }

    private func selectPreviousMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = (selectedMatchIndex - 1 + matches.count) % matches.count
        navigateToSelectedMatch()
    }

    private func navigateToSelectedMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = min(max(selectedMatchIndex, 0), matches.count - 1)
        document.requestNavigation(toTextRange: matches[selectedMatchIndex])
    }
}
