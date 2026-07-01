import AppKit
import SwiftUI

@main
struct DreamJotterMacApp: App {
    @NSApplicationDelegateAdaptor(DreamJotterMacApplicationDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .windowStyle(.titleBar)
    }
}

final class DreamJotterMacApplicationDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
