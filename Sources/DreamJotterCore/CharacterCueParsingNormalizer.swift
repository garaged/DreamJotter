import Foundation

public enum CharacterCueParsingNormalizer {
    public static func sourceForParsing(_ source: String) -> String {
        let safeSource = ScreenplayParagraphTypeEngine.parserSafeSource(source)
        let paragraphs = ScreenplayParagraphTypeEngine.paragraphs(in: safeSource)
        var insertions: [Int] = []

        for index in paragraphs.indices {
            let paragraph = paragraphs[index]
            guard paragraph.type == .action else { continue }

            let lines = paragraph.sourceText
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            guard let cue = lines.first,
                  !cue.hasPrefix("@"),
                  CharacterCueEngine.names(in: cue).count > 1,
                  CharacterCueEngine.isPlausibleCue(cue) else { continue }

            let inlineDialogue = lines.dropFirst().first
            let detachedDialogue: String? = {
                guard index + 1 < paragraphs.count else { return nil }
                return paragraphs[index + 1].sourceText
            }()
            let candidate = inlineDialogue ?? detachedDialogue
            guard let candidate,
                  isPlausibleDialogue(candidate) else { continue }
            insertions.append(paragraph.textRange.location)
        }

        guard !insertions.isEmpty else { return safeSource }
        let mutable = NSMutableString(string: safeSource)
        for location in insertions.sorted(by: >) {
            mutable.insert("@", at: location)
        }
        return mutable as String
    }

    public static func normalize(_ document: ScreenplayDocument) -> ScreenplayDocument {
        var characters: [String] = []
        var seen: Set<String> = []

        func append(_ name: String) {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmed.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en_US_POSIX")
            ).uppercased()
            guard !trimmed.isEmpty, seen.insert(key).inserted else { return }
            characters.append(trimmed)
        }

        document.characters.forEach { name in
            CharacterCueEngine.names(in: name).forEach(append)
        }
        for element in document.elements where element.paragraphType == .characterCue {
            CharacterCueEngine.names(in: element.text).forEach(append)
        }

        return ScreenplayDocument(
            elements: document.elements,
            scenes: document.scenes,
            characters: characters,
            diagnostics: document.diagnostics
        )
    }

    private static func isPlausibleDialogue(_ text: String) -> Bool {
        let first = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? ""
        guard !first.isEmpty else { return false }
        if first.hasPrefix(":") || first.hasPrefix("(") { return true }
        if ScreenplayParagraphTypeEngine.explicitType(for: first) != nil { return false }
        let letters = first.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        return !letters.isEmpty && first != first.uppercased() && first.count <= 240
    }
}
