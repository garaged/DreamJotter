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

        var titlePageRegion = true
        var transformed: [String] = []
        for original in lines {
            let trimmed = original.trimmingCharacters(in: .whitespaces)
            let isTitleField = titlePageRegion && looksLikeTitlePageField(trimmed, lexicon: lexicon)
            if !trimmed.isEmpty, !isTitleField { titlePageRegion = false }
            let converted = transformedLine(original, lexicon: lexicon, allowUnknownTitleField: isTitleField)
            mapping[converted, default: []].append(original)
            transformed.append(converted)
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

    private static func transformedLine(
        _ original: String,
        lexicon: ScreenplayLexicon,
        allowUnknownTitleField: Bool
    ) -> String {
        let leading = String(original.prefix { $0 == " " || $0 == "\t" })
        let trailing = String(original.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())
        let line = original.trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty else { return original }

        if let title = transformedTitlePageLine(line, lexicon: lexicon, allowUnknown: allowUnknownTitleField) {
            return leading + title + trailing
        }

        let upper = line.uppercased()
        if upper.hasPrefix("I/E. ") {
            return leading + "INT./EXT. " + String(line.dropFirst(5)) + trailing
        }
        if upper.hasPrefix(".I/E. ") {
            return leading + ".INT./EXT. " + String(line.dropFirst(6)) + trailing
        }
        if let cue = transformedCueLine(line, lexicon: lexicon) {
            return leading + cue + trailing
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

    private static func transformedCueLine(_ line: String, lexicon: ScreenplayLexicon) -> String? {
        guard line == line.uppercased(), line.hasSuffix(")"), let open = line.lastIndex(of: "(") else { return nil }
        let end = line.index(before: line.endIndex)
        let extensionText = String(line[line.index(after: open)..<end]).trimmingCharacters(in: .whitespaces)
        guard lexicon.cueExtensions.contains(where: {
            TextNormalization.key(for: $0) == TextNormalization.key(for: extensionText)
        }) else { return nil }
        let base = String(line[..<open]).trimmingCharacters(in: .whitespaces)
        return base + " (V.O.)"
    }

    private static func isSpanishAlias(_ key: String, values: [String], englishValues: [String]) -> Bool {
        values.contains { TextNormalization.key(for: $0) == key }
            && !englishValues.contains { TextNormalization.key(for: $0) == key }
    }

    private static func looksLikeTitlePageField(_ line: String, lexicon: ScreenplayLexicon) -> Bool {
        guard let colon = line.firstIndex(of: ":"), colon != line.startIndex else { return false }
        let key = TextNormalization.key(for: line)
        guard !lexicon.transitions.contains(where: { TextNormalization.key(for: $0) == key }),
              !lexicon.shots.contains(where: { TextNormalization.key(for: $0) == key }) else {
            return false
        }
        let label = String(line[..<colon]).trimmingCharacters(in: .whitespaces)
        return label.unicodeScalars.contains { CharacterSet.letters.contains($0) }
    }

    private static func transformedTitlePageLine(
        _ line: String,
        lexicon: ScreenplayLexicon,
        allowUnknown: Bool
    ) -> String? {
        guard let colon = line.firstIndex(of: ":") else { return nil }
        let label = String(line[..<colon]).trimmingCharacters(in: .whitespaces)
        let value = String(line[line.index(after: colon)...])
        let semantic = lexicon.titlePageAliases[TextNormalization.key(for: label)]
        guard semantic != nil || allowUnknown else { return nil }

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
