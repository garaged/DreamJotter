import Foundation

public enum ScreenplayParsingContext {
    @TaskLocal public static var language: ScreenplayLanguageProfile = .automatic
}

public enum ScreenplayParser {
    public static func parse(_ source: String) -> ScreenplayDocument {
        LocalizedScreenplayParserFacade.parse(
            source,
            language: ScreenplayParsingContext.language
        )
    }

    public static func parse(
        _ source: String,
        language: ScreenplayLanguageProfile
    ) -> ScreenplayDocument {
        LocalizedScreenplayParserFacade.parse(source, language: language)
    }
}
