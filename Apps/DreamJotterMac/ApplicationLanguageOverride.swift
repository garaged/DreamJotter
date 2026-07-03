import DreamJotterCore
import Foundation

enum ApplicationLanguageOverride {
    private static var languagePreferenceKey: String {
        ["Apple", "Languages"].joined()
    }

    static func apply(
        _ preference: ApplicationLanguagePreference,
        defaults: UserDefaults
    ) {
        switch preference {
        case .system:
            defaults.removeObject(forKey: languagePreferenceKey)
        case .english:
            defaults.set(["en"], forKey: languagePreferenceKey)
        case .spanishLatinAmerica:
            defaults.set(["es-MX", "es-419", "es"], forKey: languagePreferenceKey)
        }
    }
}
