import DreamJotterCore
import SwiftUI

@MainActor
final class LocalizationSettings: ObservableObject {
    @AppStorage("dreamjotter.applicationLanguage") var rawPreference = ApplicationLanguagePreference.system.rawValue

    var preference: ApplicationLanguagePreference {
        get { ApplicationLanguagePreference(rawValue: rawPreference) ?? .system }
        set { rawPreference = newValue.rawValue }
    }

    var locale: Locale {
        switch preference {
        case .system:
            return .current
        case .english:
            return Locale(identifier: "en")
        case .spanishLatinAmerica:
            return Locale(identifier: "es-419")
        }
    }
}

struct LocalizationSettingsView: View {
    @EnvironmentObject private var settings: LocalizationSettings

    var body: some View {
        Form {
            Picker("Language", selection: Binding(
                get: { settings.preference },
                set: { settings.preference = $0 }
            )) {
                Text("System").tag(ApplicationLanguagePreference.system)
                Text("English").tag(ApplicationLanguagePreference.english)
                Text("Spanish (Latin America)").tag(ApplicationLanguagePreference.spanishLatinAmerica)
            }
        }
        .padding()
        .frame(width: 420)
    }
}
