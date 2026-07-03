import Foundation

public enum ScreenplayLanguagePersistence {
    public static let definitionID = "dreamjotter.screenplay-language"
    public static let valueID = "dreamjotter.screenplay-language.value"

    public static func language(in project: DreamJotterProject) -> ScreenplayLanguageProfile {
        guard let value = project.pro.customFieldValues.first(where: { $0.definitionID == definitionID }) else {
            return .automatic
        }
        switch value.value {
        case .singleSelect(let raw), .text(let raw):
            return ScreenplayLanguageProfile(rawValue: raw) ?? .automatic
        default:
            return .automatic
        }
    }
}

public enum ScreenplayConstructs {
    public static func baseCharacterName(from cue: String, profile: ScreenplayLanguageProfile = .automatic) -> String {
        let lexicon = ScreenplayLexiconCatalog.lexicon(for: profile)
        let trimmed = cue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasSuffix(")"), let open = trimmed.lastIndex(of: "(") else { return trimmed }
        let end = trimmed.index(before: trimmed.endIndex)
        let extensionText = String(trimmed[trimmed.index(after: open)..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
        let isKnown = lexicon.cueExtensions.contains {
            TextNormalization.key(for: $0) == TextNormalization.key(for: extensionText)
        }
        return isKnown ? String(trimmed[..<open]).trimmingCharacters(in: .whitespacesAndNewlines) : trimmed
    }

    public static func containsTodoToken(_ text: String, profile: ScreenplayLanguageProfile = .automatic) -> Bool {
        let key = TextNormalization.key(for: text)
        return ScreenplayLexiconCatalog.lexicon(for: profile).todoTokens.contains {
            key.contains(TextNormalization.key(for: $0))
        }
    }
}
