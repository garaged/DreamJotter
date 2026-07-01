import AppKit
import SwiftUI

struct AppRootView: View {
    @State private var appModel = MacAppViewModel()
    @State private var errorMessage: String?

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
                    closeAction: { appModel.closeProject() }
                )
            } else {
                ProjectLibraryView(
                    createAction: createProject,
                    openAction: openProject
                )
            }
        }
        .frame(minWidth: 1100, minHeight: 720)
        .alert("DreamJotter", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func createProject(_ title: String) {
        appModel.createBlankProject(title: title)
    }

    private func openProject() {
        let panel = NSOpenPanel()
        panel.title = "Open DreamJotter Package"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try appModel.openPackage(at: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveProject() {
        guard var document = appModel.currentDocument else { return }
        if let packageURL = document.packageURL {
            do {
                try document.save(to: packageURL)
                appModel.currentDocument = document
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            saveProjectAs()
        }
    }

    private func saveProjectAs() {
        guard var document = appModel.currentDocument else { return }
        let panel = NSSavePanel()
        panel.title = "Save DreamJotter Package"
        panel.nameFieldStringValue = "\(document.project.metadata.title).dreamjotter"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let selectedURL = panel.url else { return }
        let packageURL = selectedURL.pathExtension == "dreamjotter"
            ? selectedURL
            : selectedURL.appendingPathExtension("dreamjotter")

        do {
            try document.save(to: packageURL)
            appModel.currentDocument = document
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
            try document.exportFountain(to: exportURL)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
