import Foundation

public extension ScreenplayParser {
    static func parse(_ source: String, language: ScreenplayLanguageProfile) -> ScreenplayDocument {
        language == .english ? parse(source) : LocalizedScreenplayParser.parse(source, language: language)
    }
}

private enum LocalizedScreenplayParser {}
