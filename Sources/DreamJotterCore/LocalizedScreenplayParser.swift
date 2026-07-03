import Foundation

public extension ScreenplayParser {
    static func parse(_ source: String, language: ScreenplayLanguageProfile) -> ScreenplayDocument {
        language == .english ? LegacyScreenplayParser.parse(source) : LocalizedScreenplayParser.parse(source, language: language)
    }
}

private enum LocalizedScreenplayParser {
    static func parse(_ source: String, language: ScreenplayLanguageProfile) -> ScreenplayDocument {
        let transformed = transform(source, language: language)
        let parsed = LegacyScreenplayParser.parse(transformed.source)
        var queues = transformed.originalsByTransformedLine
        var activeCharacter: String?
        var restoredElements: [ScriptElement] = []
        var restoredCharacters: [String] = []

        for element in parsed.elements {
            let restoredText = restore(element.text, queues: &queues)
            switch element.kind {
            case .characterCue:
                let base = ScreenplayConstructs.baseCharacterName(from: restoredText, profile: language)
                activeCharacter = base
                if !restoredCharacters.contains(base) { restoredCharacters.append(base) }
                restoredElements.append(ScriptElement(kind: .characterCue, text: restoredText))
            case .dialogue, .parenthetical:
                restoredElements.append(ScriptElement(kind: element.kind, text: restoredText, characterName: activeCharacter))
            default:
                if element.kind != .dialogue && element.kind != .parenthetical { activeCharacter = nil }
                restoredElements.append(ScriptElement(kind: element.kind, text: restoredText, characterName: element.characterName))
            }
        }

        let scenes = restoredElements.compactMap { element -> Scene? in
            guard element.kind == .sceneHeading else { return nil }
            return scene(from: element.text, language: language)
        }
        let diagnostics = parsed.diagnostics.map {
            ScreenplayDiagnostic(code: $0.code, message: $0.message, text: restore($0.text, queues: &queues))
        }
        return ScreenplayDocument(
            elements: restoredElements,
            scenes: scenes,
            characters: restoredCharacters.isEmpty ? parsed.characters : restoredCharacters,
            diagnostics: diagnostics
        )
    }

    private struct Transformation {
        let source: String
        let originalsByTransformedLine: [String: [String]]
    }

    private static func transform(_ source: String, language: ScreenplayLanguageProfile) -> Transformation {
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
        return Transformation(source: transformed.joined(separator: "\n"), originalsByTransformedLine: mapping)
    }

    private static func transformedLine(_ original: String, lexicon: ScreenplayLexicon) -> String {
        let leading = String(original.prefix { $0 == " " || $0 == "\t" })
        let trailing = String(original.reversed().prefix { $0 == " " || $0 == "\t" }.reversed())
        let line = original.trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty else { return original }

        if let titleReplacement = transformedTitlePageLine(line, lexicon: lexicon) {
            return leading + titleReplacement + trailing
        }

        let upper = line.uppercased()
        if upper.hasPrefix("I/E. ") {
            return leading + "INT./EXT. " + String(line.dropFirst(5)) + trailing
        }
        if upper.hasPrefix(".I/E. ") {
            return leading + ".INT./EXT. " + String(line.dropFirst(6)) + trailing
        }

        let key = TextNormalization.key(for: line)
        if lexicon.transitions.contains(where: { TextNormalization.key(for: $0) == key })
            && !ScreenplayLexiconCatalog.english.transitions.contains(where: { TextNormalization.key(for: $0) == key }) {
            return leading + "CUT TO:" + trailing
        }
        if lexicon.shots.contains(where: { TextNormalization.key(for: $0) == key })
            && !ScreenplayLexiconCatalog.english.shots.contains(where: { TextNormalization.key(for: $0) == key }) {
            return leading + "CLOSE ON:" + trailing
        }
        return original
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
        case "notes": englishLabel = "Notes"
        default: englishLabel = "Notes"
        }
        return englishLabel + ":" + value
    }

    private static func restore(_ text: String, queues: inout [String: [String]]) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        return lines.map { line in
            guard var values = queues[line], !values.isEmpty else { return line }
            let original = values.removeFirst()
            queues[line] = values
            return original.trimmingCharacters(in: .whitespaces)
        }.joined(separator: "\n")
    }

    private static func scene(from heading: String, language: ScreenplayLanguageProfile) -> Scene {
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
}
