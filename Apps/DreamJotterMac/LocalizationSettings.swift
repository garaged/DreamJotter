import DreamJotterCore
import SwiftUI

@MainActor
final class LocalizationSettings: ObservableObject {
    private static let defaultsKey = "dreamjotter.applicationLanguage"
    private let defaults: UserDefaults

    @Published var preference: ApplicationLanguagePreference {
        didSet {
            defaults.set(preference.rawValue, forKey: Self.defaultsKey)
            ApplicationLanguageOverride.apply(preference, defaults: defaults)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let rawValue = defaults.string(forKey: Self.defaultsKey)
        preference = rawValue.flatMap(ApplicationLanguagePreference.init(rawValue:)) ?? .system
        ApplicationLanguageOverride.apply(preference, defaults: defaults)
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

            Text("Quit and reopen DreamJotter after changing the language to update the entire interface.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 460)
    }
}
