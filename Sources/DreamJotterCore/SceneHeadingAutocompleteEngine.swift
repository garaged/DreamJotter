import Foundation

public enum SceneHeadingAutocompleteEngine {
    public static func suggestions(
        line: String,
        lineStart: Int,
        cursorLocation: Int,
        scenes: [Scene],
        language: ScreenplayLanguageProfile
    ) -> [EditorSuggestion] {
        let source = line as NSString
        let localCursor = min(max(0, cursorLocation - lineStart), source.length)
        let prefix = source.substring(with: NSRange(location: 0, length: localCursor))
        let upper = prefix.uppercased()

        if let prefixRange = headingPrefixRange(in: prefix) {
            let afterPrefix = source.substring(from: prefixRange.location + prefixRange.length)
            if let dashRange = afterPrefix.range(of: " - ", options: .backwards) {
                let nsAfter = afterPrefix as NSString
                let timeStart = nsAfter.range(of: String(afterPrefix[..<dashRange.upperBound])).length
                let query = nsAfter.substring(from: timeStart)
                return timeSuggestions(
                    query: query,
                    range: EditorTextRange(
                        location: lineStart + prefixRange.location + prefixRange.length + timeStart,
                        length: (query as NSString).length
                    ),
                    language: language
                )
            }

            let locationText = afterPrefix.trimmingCharacters(in: .whitespaces)
            let locationStart = lineStart + prefixRange.location + prefixRange.length
                + afterPrefix.prefix { $0 == " " || $0 == "\t" }.utf16.count
            return locationSuggestions(
                query: locationText,
                range: EditorTextRange(location: locationStart, length: (locationText as NSString).length),
                scenes: scenes
            )
        }

        let query = upper.trimmingCharacters(in: .whitespacesAndNewlines)
        let prefixes = ["INT.", "EXT.", "INT./EXT.", "EXT./INT.", "I/E."]
        return prefixes.compactMap { value in
            guard query.isEmpty || value.hasPrefix(query) else { return nil }
            return EditorSuggestion(
                id: "scene-prefix-\(value)",
                type: .sceneHeading,
                displayText: value,
                replacementText: "\(value) ",
                textRange: EditorTextRange(location: lineStart, length: localCursor),
                priority: value == query ? 1.0 : 0.9,
                source: .screenplaySyntax
            )
        }
    }

    private static func headingPrefixRange(in value: String) -> NSRange? {
        let source = value as NSString
        let match = source.range(
            of: #"^(INT\./EXT\.|EXT\./INT\.|INT\.|EXT\.|I/E\.)\s*"#,
            options: [.regularExpression, .caseInsensitive]
        )
        return match.location == NSNotFound ? nil : match
    }

    private static func locationSuggestions(
        query: String,
        range: EditorTextRange,
        scenes: [Scene]
    ) -> [EditorSuggestion] {
        let queryKey = normalized(query)
        var seen: Set<String> = []
        return scenes.compactMap(\.location).compactMap { raw in
            let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = normalized(value)
            guard !value.isEmpty, seen.insert(key).inserted else { return nil }
            guard queryKey.isEmpty || key.hasPrefix(queryKey) || key.contains(queryKey) else { return nil }
            return EditorSuggestion(
                id: "scene-location-\(key)",
                type: .location,
                displayText: value,
                replacementText: "\(value.uppercased()) - ",
                textRange: range,
                priority: key == queryKey ? 1.0 : (key.hasPrefix(queryKey) ? 0.9 : 0.7),
                source: .parsedLocations
            )
        }.sorted { ($0.priority ?? 0) > ($1.priority ?? 0) }
    }

    private static func timeSuggestions(
        query: String,
        range: EditorTextRange,
        language: ScreenplayLanguageProfile
    ) -> [EditorSuggestion] {
        let values: [String]
        switch language {
        case .spanishLatinAmerica:
            values = ["DÍA", "NOCHE", "MAÑANA", "TARDE", "CONTINUO", "MÁS TARDE"]
        case .automatic, .english:
            values = ["DAY", "NIGHT", "MORNING", "EVENING", "CONTINUOUS", "LATER"]
        }
        let queryKey = normalized(query)
        return values.compactMap { value in
            let key = normalized(value)
            guard queryKey.isEmpty || key.hasPrefix(queryKey) else { return nil }
            return EditorSuggestion(
                id: "scene-time-\(key)",
                type: .timeOfDay,
                displayText: value,
                replacementText: value,
                textRange: range,
                priority: key == queryKey ? 1.0 : 0.9,
                source: .screenplaySyntax
            )
        }
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .uppercased()
    }
}
