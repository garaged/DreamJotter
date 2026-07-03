import AppKit
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
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
