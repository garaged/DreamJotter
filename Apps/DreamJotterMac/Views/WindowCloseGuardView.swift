import AppKit
import SwiftUI

struct WindowCloseGuardView: NSViewRepresentable {
    @Binding var allowClose: Bool
    let shouldClose: () -> Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(allowClose: $allowClose, shouldClose: shouldClose)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.attach(to: window)
            }
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.allowClose = $allowClose
        context.coordinator.shouldClose = shouldClose
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.attach(to: window)
            }
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSWindowDelegate {
        var allowClose: Binding<Bool>
        var shouldClose: () -> Bool
        private weak var window: NSWindow?

        init(allowClose: Binding<Bool>, shouldClose: @escaping () -> Bool) {
            self.allowClose = allowClose
            self.shouldClose = shouldClose
        }

        func attach(to window: NSWindow) {
            guard self.window !== window else { return }
            self.window = window
            window.delegate = self
        }

        func windowShouldClose(_ sender: NSWindow) -> Bool {
            if allowClose.wrappedValue {
                allowClose.wrappedValue = false
                return true
            }
            return shouldClose()
        }
    }
}
