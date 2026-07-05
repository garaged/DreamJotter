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
        let projectType = UTType(exportedAs: IOSProductConfiguration.documentTypeIdentifier)
        let controller = UIDocumentBrowserViewController(forOpening: [projectType, .package])
        controller.delegate = context.coordinator
        controller.allowsDocumentCreation = true
        controller.allowsPickingMultipleItems = false
        controller.shouldShowFileExtensions = true
        controller.additionalLeadingNavigationBarButtonItems = [
            UIBarButtonItem(
                title: "Open Project Folder",
                style: .plain,
                target: context.coordinator,
                action: #selector(Coordinator.openProjectFolder)
            )
        ]
        context.coordinator.browserController = controller
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIDocumentBrowserViewController,
        context: Context
    ) {}

    @MainActor
    final class Coordinator: NSObject, @preconcurrency UIDocumentBrowserViewControllerDelegate, UIDocumentPickerDelegate {
        private let documentAdapter = IOSProjectDocumentAdapter()
        weak var browserController: UIDocumentBrowserViewController?

        @objc func openProjectFolder() {
            guard let browserController else { return }
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.folder],
                asCopy: false
            )
            picker.delegate = self
            picker.allowsMultipleSelection = false
            browserController.present(picker, animated: true)
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            guard let packageURL = urls.first,
                  let browserController else { return }
            controller.dismiss(animated: false)
            openProject(at: packageURL, from: browserController)
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            didPickDocumentsAt documentURLs: [URL]
        ) {
            guard let packageURL = documentURLs.first else { return }
            openProject(at: packageURL, from: controller)
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void
        ) {
            Task {
                let temporaryRoot = FileManager.default.temporaryDirectory
                    .appendingPathComponent("DreamJotter-New-\(UUID().uuidString)", isDirectory: true)
                let packageURL = temporaryRoot.appendingPathComponent("Untitled.dreamjotter", isDirectory: true)

                do {
                    try FileManager.default.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)
                    let creationAdapter = IOSProjectDocumentAdapter(
                        securityScopedAccess: .unrestricted,
                        coordination: .direct
                    )
                    _ = try await creationAdapter.createProject(
                        title: "Untitled",
                        at: packageURL
                    )
                    importHandler(packageURL, .move)
                } catch {
                    try? FileManager.default.removeItem(at: temporaryRoot)
                    importHandler(nil, .none)
                    presentError(error.localizedDescription, from: controller)
                }
            }
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            didImportDocumentAt sourceURL: URL,
            toDestinationURL destinationURL: URL
        ) {
            openProject(at: destinationURL, from: controller)
        }

        func documentBrowser(
            _ controller: UIDocumentBrowserViewController,
            failedToImportDocumentAt documentURL: URL,
            error: (any Error)?
        ) {
            presentError(error?.localizedDescription ?? "The document could not be imported.", from: controller)
        }

        private func openProject(
            at packageURL: URL,
            from controller: UIViewController
        ) {
            guard packageURL.pathExtension.lowercased() == "dreamjotter" else {
                presentError("Select a .dreamjotter project package or folder.", from: controller)
                return
            }

            Task {
                do {
                    let snapshot = try await documentAdapter.openProject(at: packageURL)
                    presentWorkspace(snapshot: snapshot, from: controller)
                } catch {
                    presentError(error.localizedDescription, from: controller)
                }
            }
        }

        private func presentWorkspace(
            snapshot: IOSProjectDocumentSnapshot,
            from controller: UIViewController
        ) {
            let hostingController = UIHostingController(
                rootView: IOSProjectEditorView(snapshot: snapshot)
            )
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
