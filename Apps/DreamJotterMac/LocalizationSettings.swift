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
            applyRuntimeLocalization()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let rawValue = defaults.string(forKey: Self.defaultsKey)
        preference = rawValue.flatMap(ApplicationLanguagePreference.init(rawValue:)) ?? .system
        applyProcessLanguagePreference()
        applyRuntimeLocalization()
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

    func relaunchApplication() {
        ApplicationLanguageRelaunch.relaunch(using: preference)
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

    private func applyRuntimeLocalization() {
        switch preference {
        case .system:
            RuntimeLocalizationBundle.apply(localeIdentifiers: Locale.preferredLanguages)
        case .english:
            RuntimeLocalizationBundle.apply(localeIdentifiers: nil)
        case .spanishLatinAmerica:
            RuntimeLocalizationBundle.apply(localeIdentifiers: ["es-MX", "es-419", "es"])
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
                localized: "Relaunch DreamJotter to apply the selected language to all menus and windows.",
                table: "Settings"
            ))
            .foregroundStyle(.secondary)

            Button(String(
                localized: "Relaunch DreamJotter",
                table: "Settings"
            )) {
                settings.relaunchApplication()
            }
        }
        .id(settings.preference)
        .padding()
        .frame(width: 460)
    }
}
