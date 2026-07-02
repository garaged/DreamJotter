import DreamJotterCore
import Foundation

enum ExportSourceContext: String, Codable, Equatable {
    case workspace
    case reviewMode
    case backup
}

enum ExportFeedbackKind: String, Codable, Equatable {
    case success
    case warning
    case error
    case canceled
}

struct ExportFeedback: Codable, Equatable, Identifiable {
    let id: String
    let kind: ExportFeedbackKind
    let userMessage: String
    let technicalDetail: String?
    let outputPath: String?
    let canRevealInFinder: Bool
    let sourceOperation: String
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        kind: ExportFeedbackKind,
        userMessage: String,
        technicalDetail: String? = nil,
        outputPath: String? = nil,
        canRevealInFinder: Bool = false,
        sourceOperation: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.userMessage = userMessage
        self.technicalDetail = technicalDetail
        self.outputPath = outputPath
        self.canRevealInFinder = canRevealInFinder && outputPath != nil
        self.sourceOperation = sourceOperation
        self.timestamp = timestamp
    }

    static func from(_ result: ExportResult, timestamp: Date = Date()) -> ExportFeedback {
        let kind: ExportFeedbackKind
        switch result.status {
        case .success:
            kind = .success
        case .failed:
            kind = .error
        case .canceled:
            kind = .canceled
        }

        return ExportFeedback(
            id: result.id,
            kind: kind,
            userMessage: result.userMessage,
            technicalDetail: result.technicalDetail,
            outputPath: result.artifactPath,
            canRevealInFinder: result.artifactPath != nil && result.status == .success,
            sourceOperation: "export",
            timestamp: timestamp
        )
    }

    static func canceled(sourceOperation: String, timestamp: Date = Date()) -> ExportFeedback {
        ExportFeedback(
            kind: .canceled,
            userMessage: "Export canceled.",
            sourceOperation: sourceOperation,
            timestamp: timestamp
        )
    }
}

struct DisabledExportFormat: Codable, Equatable, Identifiable {
    let format: ExportFormat
    let reason: String

    var id: String { format.rawValue }
}

struct ExportUIState: Codable, Equatable {
    var selectedPresetID: String
    var selectedFormat: ExportFormat
    var availableFormats: [ExportFormat]
    var disabledFormats: [DisabledExportFormat]
    var destinationPath: String?
    var isExporting: Bool
    var lastSuccessFeedbackID: String?
    var lastErrorFeedbackID: String?
    var lastFeedback: ExportFeedback?
    var sourceContext: ExportSourceContext
    var isCanceled: Bool

    init(
        selectedPresetID: String,
        selectedFormat: ExportFormat,
        availableFormats: [ExportFormat] = ExportFormat.uiVisibleFormats,
        disabledFormats: [DisabledExportFormat] = [],
        destinationPath: String? = nil,
        isExporting: Bool = false,
        lastSuccessFeedbackID: String? = nil,
        lastErrorFeedbackID: String? = nil,
        lastFeedback: ExportFeedback? = nil,
        sourceContext: ExportSourceContext,
        isCanceled: Bool = false
    ) {
        self.selectedPresetID = selectedPresetID
        self.selectedFormat = selectedFormat
        self.availableFormats = availableFormats
        self.disabledFormats = disabledFormats
        self.destinationPath = destinationPath
        self.isExporting = isExporting
        self.lastSuccessFeedbackID = lastSuccessFeedbackID
        self.lastErrorFeedbackID = lastErrorFeedbackID
        self.lastFeedback = lastFeedback
        self.sourceContext = sourceContext
        self.isCanceled = isCanceled
    }

    static func initial(
        presets: [ExportPreset] = ExportPresetCatalog.builtInPresets(),
        sourceContext: ExportSourceContext = .workspace
    ) -> ExportUIState {
        let preferredID = sourceContext == .backup ? "writer-backup" : "reader-copy"
        let preset = presets.first { $0.id == preferredID } ?? presets[0]
        return ExportUIState(
            selectedPresetID: preset.id,
            selectedFormat: preset.format,
            sourceContext: sourceContext
        ).reconciled(with: presets)
    }

    var selectedDestinationURL: URL? {
        guard let destinationPath else { return nil }
        return URL(fileURLWithPath: destinationPath)
    }

    func selectedPreset(in presets: [ExportPreset]) -> ExportPreset? {
        presets.first { $0.id == selectedPresetID }
    }

    func disabledReason(for format: ExportFormat) -> String? {
        disabledFormats.first { $0.format == format }?.reason
    }

    mutating func selectPreset(_ presetID: String, presets: [ExportPreset]) {
        selectedPresetID = presetID
        if let preset = selectedPreset(in: presets), !preset.allowedFormats.contains(selectedFormat) {
            selectedFormat = preset.format
        }
        self = reconciled(with: presets)
    }

    mutating func selectFormat(_ format: ExportFormat, presets: [ExportPreset]) {
        selectedFormat = format
        self = reconciled(with: presets)
    }

    mutating func setDestination(_ url: URL?) {
        destinationPath = url?.path
        if url == nil {
            applyFeedback(.canceled(sourceOperation: "exportDestination"))
        }
    }

    mutating func beginExport() {
        isExporting = true
        isCanceled = false
    }

    mutating func applyFeedback(_ feedback: ExportFeedback) {
        isExporting = false
        isCanceled = feedback.kind == .canceled
        lastFeedback = feedback
        switch feedback.kind {
        case .success:
            lastSuccessFeedbackID = feedback.id
            lastErrorFeedbackID = nil
        case .error:
            lastErrorFeedbackID = feedback.id
        case .warning, .canceled:
            break
        }
    }

    func makeRequest(projectID: String, createdAt: Date = Date()) -> ExportRequest? {
        guard let destinationPath else { return nil }
        return ExportRequest(
            id: "export-\(UUID().uuidString)",
            projectID: projectID,
            presetID: selectedPresetID,
            format: selectedFormat,
            destinationPath: destinationPath,
            includeNotes: selectedPresetID == "writer-backup",
            includeMetadata: selectedPresetID == "writer-backup",
            createdAt: createdAt
        )
    }

    private func reconciled(with presets: [ExportPreset]) -> ExportUIState {
        guard let preset = selectedPreset(in: presets) else { return self }
        var copy = self
        copy.availableFormats = ExportFormat.uiVisibleFormats
        copy.disabledFormats = ExportFormat.uiVisibleFormats.compactMap { format in
            guard !preset.allowedFormats.contains(format) else { return nil }
            return DisabledExportFormat(
                format: format,
                reason: "\(preset.title) does not support \(format.displayName)."
            )
        }
        if copy.disabledReason(for: copy.selectedFormat) != nil {
            copy.selectedFormat = preset.format
        }
        return copy
    }
}

extension ExportFormat: Identifiable {
    public var id: String { rawValue }

    static var uiVisibleFormats: [ExportFormat] {
        [.fountain, .pdf, .markdown, .plainText, .jsonBackup]
    }

    var displayName: String {
        switch self {
        case .fountain:
            return "Fountain"
        case .pdf:
            return "PDF"
        case .plainText:
            return "Plain Text"
        case .markdown:
            return "Markdown"
        case .jsonBackup:
            return "JSON Backup"
        }
    }

    var writerDescription: String {
        switch self {
        case .fountain:
            return "A screenplay text format that other writing tools can open."
        case .pdf:
            return "A readable copy for sharing or printing."
        case .plainText:
            return "A durable text archive of the script."
        case .markdown:
            return "A readable document with script text and optional notes."
        case .jsonBackup:
            return "A structured backup that can restore the project."
        }
    }

    var fileExtension: String {
        switch self {
        case .fountain:
            return "fountain"
        case .pdf:
            return "pdf"
        case .plainText:
            return "txt"
        case .markdown:
            return "md"
        case .jsonBackup:
            return "json"
        }
    }
}
