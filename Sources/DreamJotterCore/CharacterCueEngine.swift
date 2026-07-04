import Foundation

public struct CharacterCueSuggestionContext: Equatable, Sendable {
    public let query: String
    public let replacementRange: EditorTextRange
    public let existingNames: [String]
    public let isExplicitCue: Bool

    public init(
        query: String,
        replacementRange: EditorTextRange,
        existingNames: [String],
        isExplicitCue: Bool = false
    ) {
        self.query = query
        self.replacementRange = replacementRange
        self.existingNames = existingNames
        self.isExplicitCue = isExplicitCue
    }
}

public enum CharacterCueEngine {
    public static let canonicalSeparator = " / "

    public static func names(in cue: String) -> [String] {
        let plain = strippedCueMarker(cue)
        let unified = plain
            .replacingOccurrences(of: " AND ", with: canonicalSeparator, options: .caseInsensitive)
            .replacingOccurrences(of: " Y ", with: canonicalSeparator, options: .caseInsensitive)
            .replacingOccurrences(of: " & ", with: canonicalSeparator)
            .replacingOccurrences(of: " + ", with: canonicalSeparator)
        return normalizedNames(unified.components(separatedBy: "/"))
    }

    public static func canonicalCue(names: [String], explicit: Bool = false) -> String {
        let value = normalizedNames(names)
            .map { $0.uppercased() }
            .joined(separator: canonicalSeparator)
        return explicit ? "@\(value)" : value
    }

    public static func isPlausibleCue(_ cue: String) -> Bool {
        let values = names(in: cue)
        guard !values.isEmpty, values.count <= 6 else { return false }
        return values.allSatisfy { name in
            let words = name.split(whereSeparator: \.isWhitespace)
            let letters = name.unicodeScalars.filter { CharacterSet.letters.contains($0) }
            return !words.isEmpty
                && words.count <= 4
                && !letters.isEmpty
                && name == name.uppercased()
        }
    }

    public static func suggestionContext(
        in line: String,
        lineStart: Int,
        cursorLocation: Int
    ) -> CharacterCueSuggestionContext {
        let source = line as NSString
        let localCursor = min(max(0, cursorLocation - lineStart), source.length)
        let prefix = source.substring(with: NSRange(location: 0, length: localCursor))
        let isExplicitCue = prefix.hasPrefix("@")
        let markerOffset = isExplicitCue ? 1 : 0
        let separatorLocation = lastSeparatorEnd(in: prefix) ?? markerOffset
        let safeStart = min(max(markerOffset, separatorLocation), localCursor)
        let rawQuery = source.substring(with: NSRange(location: safeStart, length: localCursor - safeStart))
        let whitespace = rawQuery.prefix { $0 == " " || $0 == "\t" }.utf16.count
        let replacementStart = safeStart + whitespace
        let completed = source.substring(with: NSRange(location: markerOffset, length: max(0, safeStart - markerOffset)))

        return CharacterCueSuggestionContext(
            query: rawQuery.trimmingCharacters(in: .whitespacesAndNewlines),
            replacementRange: EditorTextRange(
                location: lineStart + replacementStart,
                length: localCursor - replacementStart
            ),
            existingNames: names(in: completed),
            isExplicitCue: isExplicitCue
        )
    }

    public static func suggestions(
        context: CharacterCueSuggestionContext,
        characters: [String]
    ) -> [EditorSuggestion] {
        guard context.isExplicitCue || !context.query.isEmpty else { return [] }

        let queryKey = normalizedKey(context.query)
        let excluded = Set(context.existingNames.map(normalizedKey))
        var seen: Set<String> = []

        return characters.compactMap { rawName in
            let displayName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = normalizedKey(displayName)
            guard !displayName.isEmpty,
                  !excluded.contains(key),
                  seen.insert(key).inserted else { return nil }
            let priority = matchPriority(key: key, query: queryKey)
            guard priority > 0 else { return nil }
            return EditorSuggestion(
                id: "character-cue-\(key)",
                type: .character,
                displayText: displayName,
                replacementText: displayName.uppercased(),
                textRange: context.replacementRange,
                priority: priority,
                source: .projectCharacters
            )
        }
        .sorted {
            if $0.priority != $1.priority { return ($0.priority ?? 0) > ($1.priority ?? 0) }
            return $0.displayText.localizedCaseInsensitiveCompare($1.displayText) == .orderedAscending
        }
    }

    private static func lastSeparatorEnd(in prefix: String) -> Int? {
        let source = prefix as NSString
        let candidates = ["/", "&", "+", " AND ", " Y "]
        return candidates.compactMap { token -> Int? in
            let range = source.range(of: token, options: [.backwards, .caseInsensitive])
            return range.location == NSNotFound ? nil : range.location + range.length
        }.max()
    }

    private static func matchPriority(key: String, query: String) -> Double {
        guard !query.isEmpty else { return 0.5 }
        if key == query { return 1.0 }
        if key.hasPrefix(query) { return 0.9 }
        if key.split(separator: " ").contains(where: { $0.hasPrefix(query) }) { return 0.8 }
        if key.contains(query) { return 0.65 }
        return 0
    }

    private static func strippedCueMarker(_ cue: String) -> String {
        let trimmed = cue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("@")
            ? String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
            : trimmed
    }

    private static func normalizedNames(_ names: [String]) -> [String] {
        var seen: Set<String> = []
        return names.compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = normalizedKey(trimmed)
            guard !trimmed.isEmpty, seen.insert(key).inserted else { return nil }
            return trimmed
        }
    }

    private static func normalizedKey(_ value: String) -> String {
        value.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        ).uppercased()
    }
}
