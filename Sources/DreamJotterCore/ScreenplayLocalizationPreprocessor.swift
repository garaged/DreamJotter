import Foundation

struct ScreenplayLocalizationPreprocessingResult {
    let source: String
    let originalsByTransformedLine: [String: [String]]
}

enum ScreenplayLocalizationPreprocessor {
    static func transform(
        _ source: String,
        language: ScreenplayLanguageProfile
    ) -> ScreenplayLocalizationPreprocessingResult {
        let lexicon = ScreenplayLexiconCatalog.lexicon(for: language)
        var mapping: [String: [String]] = [:]
        let lines = source
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        let transformed = lines.map { original -> String in
            let converted = transformedLine(original, lexicon: lexicon)
            mapping[converted, default: []].append(original)
            return converted
        }
        return ScreenplayLocalizationPreprocessingResult(
            source: transformed.joined(separator: "\n"),
            originalsByTransformedLine: mapping
        )
    }

    static func scene(from heading: String, language: ScreenplayLanguageProfile) -> Scene {
        let lexicon = ScreenplayLexiconCatalog.lexicon(for: language)
        let prefix = lexicon.scenePrefixes
            .sorted { $0.count > $1.count }
            .first { heading.uppercased().hasPrefix($0.uppercased() + " ") }
        let body = prefix.map { String(heading.dropFirst($0.count)).trimmingCharacters(in: .whitespaces) } ?? heading
        let separator = [" - ", " – ", " — "].first { body.contains($0) }
        let parts = separator.map { body.components(separatedBy: $0) } ?? [body]
        return Scene(
            heading: heading,
            location: parts.first?.trimmingCharacters(in: .whitespaces) ?? body,
            timeOfDay: parts.count > 1 ? parts.last?.trimmingCharacters(in: .whitespaces) : nil
        )
    }

    private static func transformedLine(_ original: String, lexicon: ScreenplayLexicon) -> String {
        let leading = String(original.prefix { $0 == " " || $0 == "\t" })
        let trailing = String(original.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())
        let line = original.trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty else { return original }

        if let title = transformedTitlePageLine(line, lexicon: lexicon) {
            return leading + title + trailing
        }

        let upper = line.uppercased()
        if upper.hasPrefix("I/E. ") {
            return leading + "INT./EXT. " + String(line.dropFirst(5)) + trailing
        }
        if upper.hasPrefix(".I/E. ") {
            return leading + ".INT./EXT. " + String(line.dropFirst(6)) + trailing
        }

        let key = TextNormalization.key(for: line)
        if isSpanishAlias(key, values: lexicon.transitions, englishValues: ScreenplayLexiconCatalog.english.transitions) {
            return leading + "CUT TO:" + trailing
        }
        if isSpanishAlias(key, values: lexicon.shots, englishValues: ScreenplayLexiconCatalog.english.shots) {
            return leading + "CLOSE ON:" + trailing
        }
        return original
    }

    private static func isSpanishAlias(_ key: String, values: [String], englishValues: [String]) -> Bool {
        values.contains { TextNormalization.key(for: $0) == key }
            && !englishValues.contains { TextNormalization.key(for: $0) == key }
    }

    private static func transformedTitlePageLine(_ line: String, lexicon: ScreenplayLexicon) -> String? {
        guard let colon = line.firstIndex(of: ":") else { return nil }
        let label = String(line[..<colon]).trimmingCharacters(in: .whitespaces)
        let value = String(line[line.index(after: colon)...])
        guard let semantic = lexicon.titlePageAliases[TextNormalization.key(for: label)] else { return nil }

        let englishLabel: String
        switch semantic {
        case "title": englishLabel = "Title"
        case "credit": englishLabel = "Credit"
        case "author": englishLabel = "Author"
        case "source": englishLabel = "Source"
        case "draftDate": englishLabel = "Date"
        case "contact": englishLabel = "Contact"
        case "copyright": englishLabel = "Copyright"
        default: englishLabel = "Notes"
        }
        return englishLabel + ":" + value
    }
}
