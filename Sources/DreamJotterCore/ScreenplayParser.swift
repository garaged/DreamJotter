import Foundation

public enum ScreenplayParser {
    public static func parse(_ source: String) -> ScreenplayDocument {
        LocalizedScreenplayParserFacade.parse(source, language: .automatic)
    }

    public static func parse(
        _ source: String,
        language: ScreenplayLanguageProfile
    ) -> ScreenplayDocument {
        LocalizedScreenplayParserFacade.parse(source, language: language)
    }
}
