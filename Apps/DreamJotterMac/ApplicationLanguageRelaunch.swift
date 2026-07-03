import AppKit
import DreamJotterCore

@MainActor
enum ApplicationLanguageRelaunch {
    static func relaunch(using preference: ApplicationLanguagePreference) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = arguments(for: preference)

        NSWorkspace.shared.openApplication(
            at: Bundle.main.bundleURL,
            configuration: configuration
        ) { _, error in
            guard error == nil else { return }
            Task { @MainActor in
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private static func arguments(
        for preference: ApplicationLanguagePreference
    ) -> [String] {
        switch preference {
        case .system:
            return []
        case .english:
            return ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        case .spanishLatinAmerica:
            return [
                "-AppleLanguages", "(es-MX,es-419,es)",
                "-AppleLocale", "es_MX"
            ]
        }
    }
}
