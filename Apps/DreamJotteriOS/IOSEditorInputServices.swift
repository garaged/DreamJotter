import DreamJotterCore
import Foundation

public enum IOSPasteNormalizer {
    public static func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{2028}", with: "\n")
            .replacingOccurrences(of: "\u{2029}", with: "\n\n")
    }
}

public struct IOSAutocompleteState: Equatable, Sendable {
    public private(set) var suggestions: [EditorSuggestion]
    public private(set) var selectedIndex: Int

    public init(suggestions: [EditorSuggestion] = [], selectedIndex: Int = 0) {
        self.suggestions = suggestions
        self.selectedIndex = suggestions.isEmpty ? 0 : min(max(0, selectedIndex), suggestions.count - 1)
    }

    public var selectedSuggestion: EditorSuggestion? {
        guard suggestions.indices.contains(selectedIndex) else { return nil }
        return suggestions[selectedIndex]
    }

    public var isPresented: Bool { !suggestions.isEmpty }

    public mutating func replaceSuggestions(_ suggestions: [EditorSuggestion]) {
        self.suggestions = suggestions
        selectedIndex = suggestions.isEmpty ? 0 : min(selectedIndex, suggestions.count - 1)
    }

    @discardableResult
    public mutating func moveSelection(by offset: Int) -> Bool {
        guard !suggestions.isEmpty else { return false }
        selectedIndex = (selectedIndex + offset % suggestions.count + suggestions.count) % suggestions.count
        return true
    }

    public mutating func dismiss() {
        suggestions = []
        selectedIndex = 0
    }
}

public enum IOSAutocompleteService {
    public static func suggestions(
        text: String,
        cursorLocation: Int,
        characters: [String],
        scenes: [Scene],
        language: ScreenplayLanguageProfile = .automatic
    ) -> [EditorSuggestion] {
        let line = EditorUsabilityService.currentLine(in: text, cursorLocation: cursorLocation)
        let lineStart = line.range.location
        let safeCursor = min(max(cursorLocation, lineStart), lineStart + (line.text as NSString).length)
        let prefix = (line.text as NSString).substring(
            with: NSRange(location: 0, length: safeCursor - lineStart)
        )
        let normalized = prefix.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scenePrefixes = ["INT.", "EXT.", "INT./EXT.", "EXT./INT.", "I/E."]
        if scenePrefixes.contains(where: { $0.hasPrefix(normalized) || normalized.hasPrefix($0) }) {
            return SceneHeadingAutocompleteEngine.suggestions(
                line: line.text,
                lineStart: lineStart,
                cursorLocation: safeCursor,
                scenes: scenes,
                language: language
            )
        }
        let context = CharacterCueEngine.suggestionContext(
            in: line.text,
            lineStart: lineStart,
            cursorLocation: safeCursor
        )
        return CharacterCueEngine.suggestions(context: context, characters: characters)
    }
}
