import Foundation

enum LocalizedScreenplayParserFacade {
    static func parse(_ source: String, language: ScreenplayLanguageProfile) -> ScreenplayDocument {
        if language == .english {
            return LegacyScreenplayParser.parse(source)
        }
        return ScreenplayLocalizationTransform.parse(source, language: language)
    }
}
