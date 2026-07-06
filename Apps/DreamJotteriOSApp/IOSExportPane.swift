import DreamJotterCore
import SwiftUI
import UIKit

struct IOSExportPane: View {
    let project: DreamJotterProject

    @State private var sharedFileURL: URL?
    @State private var errorMessage: String?

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
        .sheet(isPresented: Binding(
            get: { sharedFileURL != nil },
            set: { if !$0 { sharedFileURL = nil } }
        )) {
            if let sharedFileURL {
                IOSActivityView(items: [sharedFileURL])
            }
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

    var errorDescription: String? {
        switch self {
        case .missingPreset:
            "No compatible export preset is available for this project."
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
