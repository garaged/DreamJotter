import DreamJotteriOS
import SwiftUI
import UniformTypeIdentifiers
import UIKit

@main
struct DreamJotteriOSApplication: App {
    var body: some Scene {
        WindowGroup {
            IOSDocumentBrowserRootView()
                .ignoresSafeArea()
        }
    }
}

struct IOSDocumentBrowserRootView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIDocumentBrowserViewController {
        let projectType = UTType(importedAs: IOSProductConfiguration.documentTypeIdentifier)
        let controller = UIDocumentBrowserViewController(forOpening: [projectType])
        controller.delegate = context.coordinator
        controller.allowsDocumentCreation = true
        controller.allowsPickingMultipleItems = false
        controller.shouldShowFileExtensions = true
        controller.browserUserInterfaceStyle = .automatic
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIDocumentBrowserViewController,
        context: Context
    ) {}

    @MainActor
    final class Coordinator: NSObject, UIDocumentBrowserViewControllerDelegate {
        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            didPickDocumentsAt documentURLs: [URL]
        ) {
            guard let packageURL = documentURLs.first else { return }
            presentWorkspace(for: packageURL, from: controller)
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
        ) {
            // The browser and entitlements are operational. Creation is deliberately
            // blocked until the package-creation adapter can produce a canonical,
            // schema-valid DreamJotter package rather than an empty directory.
            importHandler(nil, .none)
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            failedToImportDocumentAt documentURL: URL,
            error: any Error
        ) {
            presentError(error.localizedDescription, from: controller)
        }

        private func presentWorkspace(
            for packageURL: URL,
            from controller: UIDocumentBrowserViewController
        ) {
            let view = IOSWorkspacePlaceholderView(packageURL: packageURL)
            let hostingController = UIHostingController(rootView: view)
            hostingController.modalPresentationStyle = .fullScreen
            controller.present(hostingController, animated: true)
        }

        private func presentError(
            _ message: String,
            from controller: UIViewController
        ) {
            let alert = UIAlertController(
                title: "DreamJotter",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            controller.present(alert, animated: true)
        }
    }
}

private struct IOSWorkspacePlaceholderView: View {
    let packageURL: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Project Selected",
                systemImage: "doc.text",
                description: Text(packageURL.lastPathComponent)
            )
            .navigationTitle("DreamJotter")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Documents") { dismiss() }
                }
            }
        }
    }
}
