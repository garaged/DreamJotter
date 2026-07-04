import Foundation

public enum ScreenplayParsingContext {
    @TaskLocal public static var language: ScreenplayLanguageProfile = .automatic
}

public enum ScreenplayParser {
    public static func parse(_ source: String) -> ScreenplayDocument {
        let prepared = CharacterCueParsingNormalizer.sourceForParsing(source)
        let parsed = LocalizedScreenplayParserFacade.parse(
            prepared,
            language: ScreenplayParsingContext.language
        )
        return CharacterCueParsingNormalizer.normalize(parsed)
    }

    public static func parse(
        _ source: String,
        language: ScreenplayLanguageProfile
    ) -> ScreenplayDocument {
        let prepared = CharacterCueParsingNormalizer.sourceForParsing(source)
        let parsed = LocalizedScreenplayParserFacade.parse(prepared, language: language)
        return CharacterCueParsingNormalizer.normalize(parsed)
    }
}
