import AppKit
import DreamJotterCore
import SwiftUI

@main
struct DreamJotterMacApp: App {
    @NSApplicationDelegateAdaptor(DreamJotterMacApplicationDelegate.self) private var appDelegate
    @StateObject private var localizationSettings = LocalizationSettings()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(localizationSettings)
                .environment(\.locale, localizationSettings.locale)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    NotificationCenter.default.post(name: .dreamJotterNewProject, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
            }

            CommandGroup(after: .newItem) {
                Button("Open...") {
                    NotificationCenter.default.post(name: .dreamJotterOpenProject, object: nil)
                }
                .keyboardShortcut("o", modifiers: [.command])
            }

            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    NotificationCenter.default.post(name: .dreamJotterSaveProject, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])

                Button("Save As...") {
                    NotificationCenter.default.post(name: .dreamJotterSaveProjectAs, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }

            CommandMenu("Export") {
                Button("Export...") {
                    NotificationCenter.default.post(name: .dreamJotterExportFountain, object: nil)
                }
            }
        }

        Settings {
            LocalizationSettingsView()
                .environmentObject(localizationSettings)
                .environment(\.locale, localizationSettings.locale)
        }
    }
}

final class DreamJotterMacApplicationDelegate: NSObject, NSApplicationDelegate {
    private static let preferenceKey = "dreamjotter.applicationLanguage"

    func applicationWillFinishLaunching(_ notification: Notification) {
        guard !ProcessInfo.processInfo.arguments.contains("-AppleLanguages") else {
            return
        }

        let rawPreference = UserDefaults.standard.string(forKey: Self.preferenceKey)
        let preference = rawPreference.flatMap(ApplicationLanguagePreference.init(rawValue:)) ?? .system
        guard preference != .system else { return }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = launchArguments(for: preference)

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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func launchArguments(for preference: ApplicationLanguagePreference) -> [String] {
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
