import AppKit
import DreamJotterCore
import SwiftUI

@main
struct DreamJotterMacApp: App {
    @NSApplicationDelegateAdaptor(DreamJotterMacApplicationDelegate.self) private var appDelegate
    @StateObject private var localizationSettings = LocalizationSettings()

    var body: some SwiftUI.Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(localizationSettings)
                .environment(\.locale, localizationSettings.locale)
        }
        .windowStyle(.titleBar)
        .commands {
            DreamJotterFileCommands()
            DreamJotterHelpCommands()
        }

        Window("About DreamJotter", id: "about-dreamjotter") {
            AboutDreamJotterView()
        }
        .windowResizability(.contentSize)

        Window("DreamJotter Help", id: "dreamjotter-help") {
            DreamJotterHelpView()
        }
        .defaultSize(width: 760, height: 640)

        Window("Privacy Statement", id: "privacy-statement") {
            PrivacyStatementView()
        }
        .defaultSize(width: 760, height: 560)

        Window("Welcome to DreamJotter", id: "onboarding") {
            OnboardingView()
        }
        .windowResizability(.contentSize)

        Settings {
            LocalizationSettingsView()
                .environmentObject(localizationSettings)
                .environment(\.locale, localizationSettings.locale)
        }
    }
}

struct DreamJotterFileCommands: Commands {
    var body: some Commands {
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
            .keyboardShortcut("e", modifiers: [.command, .shift])

            Divider()

            Button("Export Support Diagnostics...") {
                NotificationCenter.default.post(name: .dreamJotterExportDiagnostics, object: nil)
            }
        }
    }
}

struct DreamJotterHelpCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About DreamJotter") { openWindow(id: "about-dreamjotter") }
        }

        CommandGroup(replacing: .help) {
            Button("DreamJotter Help") { openWindow(id: "dreamjotter-help") }
                .keyboardShortcut("?", modifiers: [.command])
            Button("Keyboard Shortcuts") { openWindow(id: "dreamjotter-help") }
            Divider()
            Button("Privacy Statement") { openWindow(id: "privacy-statement") }
            Button("Show Welcome") { openWindow(id: "onboarding") }
            Divider()
            Button("Export Support Diagnostics...") {
                NotificationCenter.default.post(name: .dreamJotterExportDiagnostics, object: nil)
            }
        }
    }
}

final class DreamJotterMacApplicationDelegate: NSObject, NSApplicationDelegate {
    private static let preferenceKey = "dreamjotter.applicationLanguage"
    private var diagnosticsObserver: NSObjectProtocol?

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
        diagnosticsObserver = NotificationCenter.default.addObserver(
            forName: .dreamJotterExportDiagnostics,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.exportSupportDiagnostics()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let diagnosticsObserver {
            NotificationCenter.default.removeObserver(diagnosticsObserver)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        Task { @MainActor in
            NativeDocumentApplicationRouter.shared.enqueue(urls)
            application.activate(ignoringOtherApps: true)
        }
    }

    private func exportSupportDiagnostics() {
        let panel = NSSavePanel()
        panel.title = "Export Support Diagnostics"
        panel.nameFieldStringValue = "DreamJotter-Diagnostics.json"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let destination = panel.url else { return }
        let outputURL = destination.pathExtension.lowercased() == "json"
            ? destination
            : destination.appendingPathExtension("json")

        do {
            let diagnostics = SupportDiagnosticsBuilder.make(
                packageURL: nil,
                recentErrorSummary: nil
            )
            try SupportDiagnosticsBuilder.encode(diagnostics).write(to: outputURL, options: .atomic)
            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Diagnostics Export Failed"
            alert.informativeText = CrashSafePresentationPolicy.message(for: error, operation: .export)
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
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
