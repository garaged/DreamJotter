import DreamJotterCore
import SwiftUI

@MainActor
final class LocalizationSettings: ObservableObject {
    private static let defaultsKey = "dreamjotter.applicationLanguage"

    @Published var preference: ApplicationLanguagePreference {
        didSet {
            UserDefaults.standard.set(preference.rawValue, forKey: Self.defaultsKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        let rawValue = defaults.string(forKey: Self.defaultsKey)
        preference = rawValue.flatMap(ApplicationLanguagePreference.init(rawValue:)) ?? .system
    }

    var locale: Locale {
        switch preference {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .spanishLatinAmerica:
            return Locale(identifier: "es-MX")
        }
    }
}

struct LocalizationSettingsView: View {
    @EnvironmentObject private var settings: LocalizationSettings

    var body: some View {
        Form {
            Picker("Language", selection: $settings.preference) {
                Text("System").tag(ApplicationLanguagePreference.system)
                Text("English").tag(ApplicationLanguagePreference.english)
                Text("Spanish (Latin America)").tag(ApplicationLanguagePreference.spanishLatinAmerica)
            }
        }
        .padding()
        .frame(width: 420)
    }
}
