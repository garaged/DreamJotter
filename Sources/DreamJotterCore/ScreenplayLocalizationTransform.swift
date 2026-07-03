import Foundation

enum ScreenplayLocalizationTransform {
    static func parse(_ source: String, language: ScreenplayLanguageProfile) -> ScreenplayDocument {
        let transformed = ScreenplayLocalizationPreprocessor.transform(source, language: language)
        let parsed = LegacyScreenplayParser.parse(transformed.source)
        var queues = transformed.originalsByTransformedLine
        var activeCharacter: String?
        var elements: [ScriptElement] = []
        var characters: [String] = []

        for element in parsed.elements {
            let text = restore(element.text, queues: &queues)
            switch element.kind {
            case .characterCue:
                let base = ScreenplayConstructs.baseCharacterName(from: text, profile: language)
                activeCharacter = base
                if !characters.contains(base) { characters.append(base) }
                elements.append(ScriptElement(kind: .characterCue, text: text))
            case .dialogue, .parenthetical:
                elements.append(ScriptElement(kind: element.kind, text: text, characterName: activeCharacter))
            default:
                activeCharacter = nil
                elements.append(ScriptElement(kind: element.kind, text: text, characterName: element.characterName))
            }
        }

        let scenes = elements.compactMap { element -> Scene? in
            guard element.kind == .sceneHeading else { return nil }
            return ScreenplayLocalizationPreprocessor.scene(from: element.text, language: language)
        }
        let diagnostics = parsed.diagnostics.map {
            ScreenplayDiagnostic(code: $0.code, message: $0.message, text: restore($0.text, queues: &queues))
        }
        return ScreenplayDocument(
            elements: elements,
            scenes: scenes,
            characters: characters.isEmpty ? parsed.characters : characters,
            diagnostics: diagnostics
        )
    }

    private static func restore(_ text: String, queues: inout [String: [String]]) -> String {
        text.split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
            .map { line in
                guard var values = queues[line], !values.isEmpty else { return line }
                let original = values.removeFirst()
                queues[line] = values
                return original.trimmingCharacters(in: .whitespaces)
            }
            .joined(separator: "\n")
    }
}
