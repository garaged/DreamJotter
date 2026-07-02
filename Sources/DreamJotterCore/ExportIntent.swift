import Foundation

public enum ExportFormat: String, Codable, Equatable, Sendable {
    case pdf
    case fountain
    case plainText
    case markdown
    case jsonBackup
}

public struct ExportIntent: Codable, Equatable, Sendable {
    public let format: ExportFormat
    public let documentTitle: String
    public let elements: [ScriptElement]
    public let diagnostics: [ScreenplayDiagnostic]

    public init(
        format: ExportFormat,
        documentTitle: String,
        elements: [ScriptElement],
        diagnostics: [ScreenplayDiagnostic] = []
    ) {
        self.format = format
        self.documentTitle = documentTitle
        self.elements = elements
        self.diagnostics = diagnostics
    }
}

public enum ExportIntentBuilder {
    public static func pdfIntent(for document: ScreenplayDocument, title: String = "Untitled") -> ExportIntent {
        ExportIntent(
            format: .pdf,
            documentTitle: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : title,
            elements: document.elements,
            diagnostics: document.diagnostics
        )
    }
}

public enum ExportResultStatus: String, Codable, Equatable, Sendable {
    case success
    case failed
    case canceled
}

public struct ExportRequest: Codable, Equatable, Sendable {
    public let id: String
    public let projectID: String
    public let presetID: String
    public let format: ExportFormat
    public let destinationPath: String
    public let includeNotes: Bool
    public let includeMetadata: Bool
    public let createdAt: Date

    public init(
        id: String,
        projectID: String,
        presetID: String,
        format: ExportFormat,
        destinationPath: String,
        includeNotes: Bool,
        includeMetadata: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.projectID = projectID
        self.presetID = presetID
        self.format = format
        self.destinationPath = destinationPath
        self.includeNotes = includeNotes
        self.includeMetadata = includeMetadata
        self.createdAt = createdAt
    }
}

public struct ExportResult: Codable, Equatable, Sendable {
    public let id: String
    public let requestID: String
    public let status: ExportResultStatus
    public let artifactPath: String?
    public let format: ExportFormat
    public let userMessage: String
    public let technicalDetail: String?
    public let generatedAt: Date
    public let dirtyStateChanged: Bool

    public init(
        id: String,
        requestID: String,
        status: ExportResultStatus,
        artifactPath: String?,
        format: ExportFormat,
        userMessage: String,
        technicalDetail: String? = nil,
        generatedAt: Date,
        dirtyStateChanged: Bool = false
    ) {
        self.id = id
        self.requestID = requestID
        self.status = status
        self.artifactPath = artifactPath
        self.format = format
        self.userMessage = userMessage
        self.technicalDetail = technicalDetail
        self.generatedAt = generatedAt
        self.dirtyStateChanged = dirtyStateChanged
    }
}

public enum ExportWorkflow {
    public static func validate(_ request: ExportRequest, preset: ExportPreset) -> [String] {
        var diagnostics: [String] = []
        if !preset.allowedFormats.contains(request.format) {
            diagnostics.append("This preset does not support the selected export format.")
        }
        if request.destinationPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            diagnostics.append("Choose where to save the export.")
        }
        if !preset.includesInternalIDs && request.includeMetadata && preset.id != "writer-backup" {
            diagnostics.append("This preset does not include internal project metadata.")
        }
        return diagnostics
    }

    public static func exportText(for project: DreamJotterProject, request: ExportRequest, preset: ExportPreset, generatedAt: Date = Date()) -> (text: String?, result: ExportResult) {
        let diagnostics = validate(request, preset: preset)
        guard diagnostics.isEmpty else {
            return (nil, ExportResult(
                id: "export-result-\(request.id)",
                requestID: request.id,
                status: .failed,
                artifactPath: nil,
                format: request.format,
                userMessage: diagnostics[0],
                technicalDetail: diagnostics.joined(separator: "\n"),
                generatedAt: generatedAt
            ))
        }

        switch request.format {
        case .fountain:
            return success(FountainIO.exportScreenplay(project.screenplay), request: request, generatedAt: generatedAt)
        case .plainText:
            return success(plainText(for: project), request: request, generatedAt: generatedAt)
        case .markdown:
            return success(markdown(for: project, preset: preset), request: request, generatedAt: generatedAt)
        case .pdf:
            return (nil, unavailable("Basic PDF export is not implemented yet.", request: request, generatedAt: generatedAt))
        case .jsonBackup:
            do {
                return success(try BackupRestoreWorkflow.jsonString(for: project, createdAt: generatedAt), request: request, generatedAt: generatedAt)
            } catch {
                return (nil, ExportResult(
                    id: "export-result-\(request.id)",
                    requestID: request.id,
                    status: .failed,
                    artifactPath: nil,
                    format: request.format,
                    userMessage: "DreamJotter could not create the backup export.",
                    technicalDetail: String(describing: error),
                    generatedAt: generatedAt
                ))
            }
        }
    }

    public static func exportData(for project: DreamJotterProject, request: ExportRequest, preset: ExportPreset, generatedAt: Date = Date()) -> (data: Data?, result: ExportResult) {
        let diagnostics = validate(request, preset: preset)
        guard diagnostics.isEmpty else {
            return (nil, ExportResult(
                id: "export-result-\(request.id)",
                requestID: request.id,
                status: .failed,
                artifactPath: nil,
                format: request.format,
                userMessage: diagnostics[0],
                technicalDetail: diagnostics.joined(separator: "\n"),
                generatedAt: generatedAt
            ))
        }

        switch request.format {
        case .pdf:
            return (BasicPDFExportAdapter.render(project: project, preset: preset, generatedAt: generatedAt), successResult(request: request, generatedAt: generatedAt))
        case .fountain, .plainText, .markdown, .jsonBackup:
            let export = exportText(for: project, request: request, preset: preset, generatedAt: generatedAt)
            return (export.text.map { Data($0.utf8) }, export.result)
        }
    }

    public static func plainText(for project: DreamJotterProject) -> String {
        FountainIO.exportScreenplay(project.screenplay)
    }

    public static func markdown(for project: DreamJotterProject, preset: ExportPreset) -> String {
        var lines: [String] = ["# \(project.metadata.title)", ""]
        if let logline = project.story.logline?.text, !logline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("> \(logline)")
            lines.append("")
        }
        lines.append("```fountain")
        lines.append(FountainIO.exportScreenplay(project.screenplay))
        lines.append("```")

        if preset.includesNotes, !project.notes.isEmpty {
            lines.append("")
            lines.append("## Notes")
            for note in project.notes {
                lines.append("- \(note.body)")
            }
        }
        return lines.joined(separator: "\n")
    }

    private static func success(_ text: String, request: ExportRequest, generatedAt: Date) -> (text: String?, result: ExportResult) {
        (text, successResult(request: request, generatedAt: generatedAt))
    }

    private static func successResult(request: ExportRequest, generatedAt: Date) -> ExportResult {
        ExportResult(
            id: "export-result-\(request.id)",
            requestID: request.id,
            status: .success,
            artifactPath: request.destinationPath,
            format: request.format,
            userMessage: "Export complete.",
            generatedAt: generatedAt
        )
    }

    private static func unavailable(_ message: String, request: ExportRequest, generatedAt: Date) -> ExportResult {
        ExportResult(
            id: "export-result-\(request.id)",
            requestID: request.id,
            status: .failed,
            artifactPath: nil,
            format: request.format,
            userMessage: message,
            generatedAt: generatedAt
        )
    }
}
