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
                    saveAsAction: saveProjectAs,
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
            saveProjectAs()
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
            Button("Discard Changes", role: .destructive) {
                confirmPendingReplacement()
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
            errorMessage = error.localizedDescription
        }
    }

    private func saveProject() {
        do {
            let result = try appModel.saveCurrentProject()
            if result == .requiresSaveAs {
                saveProjectAs()
            }
        } catch {
            errorMessage = error.localizedDescription
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

    private func confirmPendingReplacement() {
        do {
            let shouldCloseWindow = appModel.pendingReplacement == .closeWindow
            try appModel.confirmPendingReplacement()
            replacementConfirmationMessage = nil
            if shouldCloseWindow {
                allowWindowClose = true
                NSApp.keyWindow?.performClose(nil)
            }
        } catch {
            replacementConfirmationMessage = nil
            errorMessage = error.localizedDescription
        }
    }

    private func saveProjectAs() {
        guard let document = appModel.currentDocument else { return }
        let panel = NSSavePanel()
        panel.title = "Save DreamJotter Package"
        panel.nameFieldStringValue = "\(document.project.metadata.title).dreamjotter"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let selectedURL = panel.url else { return }
        let packageURL = selectedURL.pathExtension == "dreamjotter"
            ? selectedURL
            : selectedURL.appendingPathExtension("dreamjotter")

        do {
            try appModel.saveCurrentProject(to: packageURL)
        } catch {
            errorMessage = error.localizedDescription
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
            errorMessage = error.localizedDescription
        }
    }
}

extension Notification.Name {
    static let dreamJotterNewProject = Notification.Name("DreamJotterNewProject")
    static let dreamJotterOpenProject = Notification.Name("DreamJotterOpenProject")
    static let dreamJotterSaveProject = Notification.Name("DreamJotterSaveProject")
    static let dreamJotterSaveProjectAs = Notification.Name("DreamJotterSaveProjectAs")
    static let dreamJotterExportFountain = Notification.Name("DreamJotterExportFountain")
}
