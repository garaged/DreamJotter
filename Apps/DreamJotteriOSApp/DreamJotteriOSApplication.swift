import DreamJotteriOS
import SwiftUI
import UniformTypeIdentifiers
import UIKit

@main
struct DreamJotteriOSApplication: App {
    var body: some Scene {
        WindowGroup {
            IOSApplicationRootView()
                .ignoresSafeArea()
        }
    }
}

struct IOSApplicationRootView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> IOSRootContainerController {
        IOSRootContainerController()
    }

    func updateUIViewController(
        _ uiViewController: IOSRootContainerController,
        context: Context
    ) {}
}

@MainActor
final class IOSRootContainerController: UIViewController,
    @preconcurrency UIDocumentBrowserViewControllerDelegate,
    UIDocumentPickerDelegate {

    private let documentAdapter = IOSProjectDocumentAdapter()
    private lazy var browserController: UIDocumentBrowserViewController = makeBrowserController()
    private var activeController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        showBrowser(animated: false)
    }

    private func makeBrowserController() -> UIDocumentBrowserViewController {
        let projectType = UTType(exportedAs: IOSProductConfiguration.documentTypeIdentifier)
        let controller = UIDocumentBrowserViewController(forOpening: [projectType, .package])
        controller.delegate = self
        controller.allowsDocumentCreation = true
        controller.allowsPickingMultipleItems = false
        controller.shouldShowFileExtensions = true
        controller.additionalLeadingNavigationBarButtonItems = [
            UIBarButtonItem(
                title: "Open Project Folder",
                style: .plain,
                target: self,
                action: #selector(openProjectFolder)
            )
        ]
        return controller
    }

    @objc private func openProjectFolder() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.folder],
            asCopy: false
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let packageURL = urls.first else { return }
        controller.dismiss(animated: true)
        openProject(at: packageURL)
    }

    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        didPickDocumentsAt documentURLs: [URL]
    ) {
        guard let packageURL = documentURLs.first else { return }
        openProject(at: packageURL)
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
                presentError(error.localizedDescription)
            }
        }
    }

    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        didImportDocumentAt sourceURL: URL,
        toDestinationURL destinationURL: URL
    ) {
        openProject(at: destinationURL)
    }

    func documentBrowser(
        _ controller: UIDocumentBrowserViewController,
        failedToImportDocumentAt documentURL: URL,
        error: (any Error)?
    ) {
        presentError(error?.localizedDescription ?? "The document could not be imported.")
    }

    private func openProject(at packageURL: URL) {
        guard packageURL.pathExtension.lowercased() == "dreamjotter" else {
            presentError("Select a .dreamjotter project package or folder.")
            return
        }

        Task {
            do {
                let snapshot = try await documentAdapter.openProject(at: packageURL)
                showWorkspace(snapshot: snapshot)
            } catch {
                presentError(error.localizedDescription)
            }
        }
    }

    private func showWorkspace(snapshot: IOSProjectDocumentSnapshot) {
        let hostingController = UIHostingController(
            rootView: IOSProjectEditorView(
                snapshot: snapshot,
                onClose: { [weak self] in
                    self?.showBrowser(animated: true)
                }
            )
        )
        hostingController.view.backgroundColor = .systemBackground
        replaceActiveController(with: hostingController, animated: true)
    }

    private func showBrowser(animated: Bool) {
        replaceActiveController(with: browserController, animated: animated)
    }

    private func replaceActiveController(
        with nextController: UIViewController,
        animated: Bool
    ) {
        guard activeController !== nextController else { return }

        let previousController = activeController
        addChild(nextController)
        nextController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextController.view)
        NSLayoutConstraint.activate([
            nextController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nextController.view.topAnchor.constraint(equalTo: view.topAnchor),
            nextController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        nextController.didMove(toParent: self)
        activeController = nextController

        guard let previousController else { return }

        let removePrevious = {
            previousController.willMove(toParent: nil)
            previousController.view.removeFromSuperview()
            previousController.removeFromParent()
        }

        guard animated else {
            removePrevious()
            return
        }

        nextController.view.alpha = 0
        UIView.animate(
            withDuration: 0.22,
            animations: {
                nextController.view.alpha = 1
                previousController.view.alpha = 0
            },
            completion: { _ in
                previousController.view.alpha = 1
                removePrevious()
            }
        )
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(
            title: "DreamJotter",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
