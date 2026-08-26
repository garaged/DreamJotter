import DreamJotterCore
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct IOSExportPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void

    @State private var sharedFileURL: URL?
    @State private var errorMessage: String?
    @State private var showsRestoreImporter = false
    @State private var showsRestoreConfirmation = false
    @State private var restoredProject: DreamJotterProject?

    var body: some View {
        List {
            Section("Screenplay") {
                exportButton("Fountain", systemImage: "doc.plaintext", extension: "fountain") {
                    Data(FountainIO.exportScreenplay(project.screenplay).utf8)
                }
                exportButton("Plain Text", systemImage: "text.document", extension: "txt") {
                    Data(ExportWorkflow.plainText(for: project).utf8)
                }
                exportButton("Markdown", systemImage: "text.badge.checkmark", extension: "md") {
                    guard let preset = preferredPreset(for: .markdown) else {
                        throw IOSExportError.missingPreset
                    }
                    return Data(ExportWorkflow.markdown(for: project, preset: preset).utf8)
                }
                exportButton("Final Draft XML", systemImage: "doc.badge.gearshape", extension: "fdx") {
                    FinalDraftExport.data(for: project)
                }
            }

            Section("Project") {
                exportButton("JSON Backup", systemImage: "archivebox", extension: "json") {
                    Data(try BackupRestoreWorkflow.jsonString(for: project, createdAt: Date()).utf8)
                }
                Button("Restore JSON Backup", systemImage: "arrow.counterclockwise") {
                    showsRestoreImporter = true
                }
            }

            Section("Production") {
                exportButton("PDF", systemImage: "doc.richtext", extension: "pdf") {
                    try pdfData()
                }
                Button("Print PDF", systemImage: "printer") {
                    printPDF()
                }
            }
        }
        .fileImporter(
            isPresented: $showsRestoreImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false,
            onCompletion: importBackup
        )
        .sheet(isPresented: Binding(
            get: { sharedFileURL != nil },
            set: { if !$0 { sharedFileURL = nil } }
        )) {
            if let sharedFileURL {
                IOSActivityView(items: [sharedFileURL])
            }
        }
        .confirmationDialog(
            "Replace this project with the backup?",
            isPresented: $showsRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("Replace Project", role: .destructive) {
                applyRestoredProject()
            }
            Button("Cancel", role: .cancel) {
                restoredProject = nil
            }
        } message: {
            Text("This replaces the current project with the selected backup. The replacement will be saved automatically.")
        }
        .alert("Export Failed", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func exportButton(
        _ title: String,
        systemImage: String,
        extension fileExtension: String,
        data: @escaping () throws -> Data
    ) -> some View {
        Button(title, systemImage: systemImage) {
            do {
                sharedFileURL = try writeTemporaryFile(
                    data: data(),
                    extension: fileExtension
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func importBackup(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let validation = BackupRestoreWorkflow.validateRestore(
                from: data,
                currentProjectIsDirty: false
            )
            guard validation.result.status == .restored,
                  let restored = validation.project else {
                throw IOSExportError.restoreRejected(validation.result.userMessage)
            }

            restoredProject = restored
            showsRestoreConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyRestoredProject() {
        guard let restoredProject else { return }
        project = restoredProject
        commitProjectChange(restoredProject)
        self.restoredProject = nil
    }

    private func pdfData() throws -> Data {
        guard let preset = preferredPreset(for: .pdf) else {
            throw IOSExportError.missingPreset
        }
        return ProductionPDFRenderer.renderOutput(project: project, preset: preset).data
    }

    private func printPDF() {
        do {
            let controller = UIPrintInteractionController.shared
            controller.printInfo = UIPrintInfo(dictionary: nil)
            controller.printInfo?.jobName = project.metadata.title
            controller.printingItem = try pdfData()
            controller.present(animated: true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func preferredPreset(for format: ExportFormat) -> ExportPreset? {
        project.exportPresets.first(where: { $0.allowedFormats.contains(format) })
            ?? project.exportPresets.first
    }

    private func writeTemporaryFile(data: Data, extension fileExtension: String) throws -> URL {
        let title = project.metadata.title
            .replacingOccurrences(of: "/", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let filename = (title.isEmpty ? "Untitled" : title) + "." + fileExtension
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DreamJotterExports", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }
}

private enum IOSExportError: LocalizedError {
    case missingPreset
    case restoreRejected(String)

    var errorDescription: String? {
        switch self {
        case .missingPreset:
            "No compatible export preset is available for this project."
        case .restoreRejected(let message):
            message
        }
    }
}

private struct IOSActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
