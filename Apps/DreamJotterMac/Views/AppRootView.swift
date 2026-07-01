import AppKit
import SwiftUI

struct AppRootView: View {
    @State private var appModel = MacAppViewModel()
    @State private var errorMessage: String?
    @State private var replacementConfirmationMessage: String?
    @State private var allowWindowClose = false

    var body: some View {
        Group {
            if appModel.hasOpenProject {
                ProjectWorkspaceView(
                    document: Binding(
                        get: { appModel.currentDocument! },
                        set: { appModel.currentDocument = $0 }
                    ),
                    saveAction: saveProject,
                    saveAsAction: { _ = saveProjectAs() },
                    openAction: openProject,
                    exportAction: exportFountain,
                    closeAction: closeProject
                )
            } else {
                ProjectLibraryView(
                    recentProjectURLs: appModel.recentProjectURLs,
                    createAction: createProject,
                    openAction: openProject,
                    openRecentAction: openRecentProject
                )
            }
        }
        .navigationTitle(windowTitle)
        .frame(minWidth: 1100, minHeight: 720)
        .background(WindowCloseGuardView(allowClose: $allowWindowClose, shouldClose: requestWindowClose))
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterNewProject)) { _ in
            createProject("Untitled")
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterOpenProject)) { _ in
            openProject()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterSaveProject)) { _ in
            saveProject()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterSaveProjectAs)) { _ in
            _ = saveProjectAs()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterExportFountain)) { _ in
            exportFountain()
        }
        .alert("DreamJotter", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Unsaved Changes", isPresented: Binding(
            get: { replacementConfirmationMessage != nil },
            set: { if !$0 { replacementConfirmationMessage = nil } }
        )) {
            Button("Save") {
                saveAndConfirmPendingReplacement()
            }
            Button("Discard Changes", role: .destructive) {
                discardPendingReplacement()
            }
            Button("Cancel", role: .cancel) {
                appModel.cancelPendingReplacement()
                replacementConfirmationMessage = nil
            }
        } message: {
            Text(replacementConfirmationMessage ?? "")
        }
    }

    private var windowTitle: String {
        guard let document = appModel.currentDocument else { return "DreamJotter" }
        let unsavedMarker = document.isDirty ? " *" : ""
        let location = document.packageURL == nil ? " - Unsaved" : ""
        return "\(document.project.metadata.title)\(unsavedMarker)\(location)"
    }

    private func createProject(_ title: String) {
        let decision = appModel.requestNewProject(title: title)
        presentReplacementDecision(decision)
    }

    private func openProject() {
        let panel = NSOpenPanel()
        panel.title = "Open DreamJotter Package"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        openRecentProject(url)
    }

    private func openRecentProject(_ url: URL) {
        do {
            let decision = try appModel.requestOpenPackage(at: url)
            presentReplacementDecision(decision)
        } catch {
            appModel.forgetInvalidRecentProject(url)
            present(error, operation: .recentProjectOpen)
        }
    }

    private func saveProject() {
        do {
            let result = try appModel.saveCurrentProject()
            if result == .requiresSaveAs {
                saveProjectAs()
            }
        } catch {
            present(error, operation: .save)
        }
    }

    private func closeProject() {
        let decision = appModel.requestCloseProject()
        presentReplacementDecision(decision)
    }

    private func requestWindowClose() -> Bool {
        let decision = appModel.requestCloseWindow()
        switch decision {
        case .replaced:
            return true
        case .requiresConfirmation(let message):
            replacementConfirmationMessage = message
            return false
        }
    }

    private func presentReplacementDecision(_ decision: ProjectReplacementDecision) {
        if case .requiresConfirmation(let message) = decision {
            replacementConfirmationMessage = message
        }
    }

    private func saveAndConfirmPendingReplacement() {
        let shouldCloseWindow = appModel.pendingReplacement == .closeWindow
        do {
            let result = try appModel.saveAndConfirmPendingReplacement()
            if result == .requiresSaveAs {
                _ = saveProjectAs {
                    finishPendingReplacementAfterSave(shouldCloseWindow: shouldCloseWindow)
                }
                return
            }
            replacementConfirmationMessage = nil
            closeWindowIfNeeded(shouldCloseWindow)
        } catch {
            replacementConfirmationMessage = nil
            present(error, operation: .save)
        }
    }

    private func discardPendingReplacement() {
        do {
            let shouldCloseWindow = appModel.pendingReplacement == .closeWindow
            try appModel.discardPendingReplacement()
            replacementConfirmationMessage = nil
            closeWindowIfNeeded(shouldCloseWindow)
        } catch {
            replacementConfirmationMessage = nil
            present(error, operation: .unknown)
        }
    }

    private func finishPendingReplacementAfterSave(shouldCloseWindow: Bool) {
        do {
            try appModel.confirmPendingReplacementAfterExternalSave()
            replacementConfirmationMessage = nil
            closeWindowIfNeeded(shouldCloseWindow)
        } catch {
            replacementConfirmationMessage = nil
            present(error, operation: .save)
        }
    }

    private func closeWindowIfNeeded(_ shouldCloseWindow: Bool) {
        if shouldCloseWindow {
            allowWindowClose = true
            NSApp.keyWindow?.performClose(nil)
        }
    }

    @discardableResult
    private func saveProjectAs(afterSuccessfulSave: (() -> Void)? = nil) -> SaveAsRequestResult {
        guard let document = appModel.currentDocument else { return .canceled }
        let panel = NSSavePanel()
        panel.title = "Save DreamJotter Package"
        panel.nameFieldStringValue = "\(document.project.metadata.title).dreamjotter"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return appModel.cancelSaveAs()
        }
        let packageURL = selectedURL.pathExtension == "dreamjotter"
            ? selectedURL
            : selectedURL.appendingPathExtension("dreamjotter")

        do {
            let result = try appModel.saveCurrentProject(to: packageURL)
            afterSuccessfulSave?()
            return result
        } catch {
            present(error, operation: .saveAs)
            return .canceled
        }
    }

    private func exportFountain() {
        guard let document = appModel.currentDocument else { return }
        let panel = NSSavePanel()
        panel.title = "Export Fountain"
        panel.nameFieldStringValue = "\(document.project.metadata.title).fountain"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let selectedURL = panel.url else { return }
        let exportURL = selectedURL.pathExtension == "fountain"
            ? selectedURL
            : selectedURL.appendingPathExtension("fountain")

        do {
            try appModel.exportCurrentProject(to: exportURL)
        } catch {
            present(error, operation: .export)
        }
    }

    private func present(_ error: Error, operation: AppErrorSourceOperation) {
        errorMessage = AppError.wrap(error, operation: operation).localizedDescription
    }
}

extension Notification.Name {
    static let dreamJotterNewProject = Notification.Name("DreamJotterNewProject")
    static let dreamJotterOpenProject = Notification.Name("DreamJotterOpenProject")
    static let dreamJotterSaveProject = Notification.Name("DreamJotterSaveProject")
    static let dreamJotterSaveProjectAs = Notification.Name("DreamJotterSaveProjectAs")
    static let dreamJotterExportFountain = Notification.Name("DreamJotterExportFountain")
}
