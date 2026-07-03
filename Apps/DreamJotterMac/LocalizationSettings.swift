import DreamJotterCore
import SwiftUI

@MainActor
final class LocalizationSettings: ObservableObject {
    private static let defaultsKey = "dreamjotter.applicationLanguage"
    private static var processLanguagesKey: String {
        ["Apple", "Languages"].joined()
    }

    private let defaults: UserDefaults

    @Published var preference: ApplicationLanguagePreference {
        didSet {
            defaults.set(preference.rawValue, forKey: Self.defaultsKey)
            applyProcessLanguagePreference()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let rawValue = defaults.string(forKey: Self.defaultsKey)
        preference = rawValue.flatMap(ApplicationLanguagePreference.init(rawValue:)) ?? .system
        applyProcessLanguagePreference()
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

    private func applyProcessLanguagePreference() {
        switch preference {
        case .system:
            defaults.removeObject(forKey: Self.processLanguagesKey)
        case .english:
            defaults.set(["en"], forKey: Self.processLanguagesKey)
        case .spanishLatinAmerica:
            defaults.set(["es-MX", "es-419", "es"], forKey: Self.processLanguagesKey)
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

            Text(String(
                localized: "Quit and reopen DreamJotter after changing the language to update the entire interface.",
                table: "Settings"
            ))
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 460)
    }
}
