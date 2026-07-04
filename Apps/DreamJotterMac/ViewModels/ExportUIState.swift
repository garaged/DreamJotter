import DreamJotterCore
import Foundation

enum ExportSourceContext: String, Codable, Equatable { case workspace, reviewMode, backup }
enum ExportFeedbackKind: String, Codable, Equatable { case success, warning, error, canceled }

struct ExportFeedback: Codable, Equatable, Identifiable {
    let id: String
    let kind: ExportFeedbackKind
    let userMessage: String
    let technicalDetail: String?
    let outputPath: String?
    let canRevealInFinder: Bool
    let sourceOperation: String
    let timestamp: Date

    init(id: String = UUID().uuidString, kind: ExportFeedbackKind, userMessage: String, technicalDetail: String? = nil, outputPath: String? = nil, canRevealInFinder: Bool = false, sourceOperation: String, timestamp: Date = Date()) {
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
        case .success: kind = result.technicalDetail == nil ? .success : .warning
        case .failed: kind = .error
        case .canceled: kind = .canceled
        }
        return ExportFeedback(id: result.id, kind: kind, userMessage: result.userMessage, technicalDetail: result.technicalDetail, outputPath: result.artifactPath, canRevealInFinder: result.artifactPath != nil && result.status == .success, sourceOperation: "export", timestamp: timestamp)
    }

    static func canceled(sourceOperation: String, timestamp: Date = Date()) -> ExportFeedback {
        ExportFeedback(kind: .canceled, userMessage: String(localized: "Export canceled."), sourceOperation: sourceOperation, timestamp: timestamp)
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

    init(selectedPresetID: String, selectedFormat: ExportFormat, availableFormats: [ExportFormat] = ExportFormat.uiVisibleFormats, disabledFormats: [DisabledExportFormat] = [], destinationPath: String? = nil, isExporting: Bool = false, lastSuccessFeedbackID: String? = nil, lastErrorFeedbackID: String? = nil, lastFeedback: ExportFeedback? = nil, sourceContext: ExportSourceContext, isCanceled: Bool = false) {
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

    static func presentedPresets(_ storedPresets: [ExportPreset]) -> [ExportPreset] {
        let builtIns = ExportPresetCatalog.builtInPresets()
        let builtInIDs = Set(builtIns.map(\.id))
        return builtIns + storedPresets.filter { !$0.isBuiltIn && !builtInIDs.contains($0.id) }
    }

    static func initial(presets: [ExportPreset] = ExportPresetCatalog.builtInPresets(), sourceContext: ExportSourceContext = .workspace) -> ExportUIState {
        let presented = presentedPresets(presets)
        let preferredID: String
        switch sourceContext {
        case .workspace: preferredID = "reader-copy"
        case .reviewMode: preferredID = "print-script"
        case .backup: preferredID = "writer-backup"
        }
        let preset = presented.first { $0.id == preferredID } ?? presented[0]
        let preferredFormat: ExportFormat = sourceContext != .backup && preset.allowedFormats.contains(.pdf) ? .pdf : preset.format
        return ExportUIState(selectedPresetID: preset.id, selectedFormat: preferredFormat, sourceContext: sourceContext).reconciled(with: presented)
    }

    var selectedDestinationURL: URL? { destinationPath.map(URL.init(fileURLWithPath:)) }
    func selectedPreset(in presets: [ExportPreset]) -> ExportPreset? { Self.presentedPresets(presets).first { $0.id == selectedPresetID } }
    func disabledReason(for format: ExportFormat) -> String? { disabledFormats.first { $0.format == format }?.reason }

    mutating func selectPreset(_ presetID: String, presets: [ExportPreset]) {
        let presented = Self.presentedPresets(presets)
        selectedPresetID = presetID
        if let preset = selectedPreset(in: presented), !preset.allowedFormats.contains(selectedFormat) { selectedFormat = preset.allowedFormats.contains(.pdf) ? .pdf : preset.format }
        self = reconciled(with: presented)
    }

    mutating func selectFormat(_ format: ExportFormat, presets: [ExportPreset]) { selectedFormat = format; self = reconciled(with: Self.presentedPresets(presets)) }
    mutating func setDestination(_ url: URL?) { destinationPath = url?.path; if url == nil { applyFeedback(.canceled(sourceOperation: "exportDestination")) } }
    mutating func beginExport() { isExporting = true; isCanceled = false }

    mutating func applyFeedback(_ feedback: ExportFeedback) {
        isExporting = false
        isCanceled = feedback.kind == .canceled
        lastFeedback = feedback
        switch feedback.kind {
        case .success: lastSuccessFeedbackID = feedback.id; lastErrorFeedbackID = nil
        case .error: lastErrorFeedbackID = feedback.id
        case .warning, .canceled: break
        }
    }

    func makeRequest(projectID: String, createdAt: Date = Date()) -> ExportRequest? {
        guard let destinationPath else { return nil }
        return ExportRequest(id: "export-\(UUID().uuidString)", projectID: projectID, presetID: selectedPresetID, format: selectedFormat, destinationPath: destinationPath, includeNotes: selectedPresetID == "writer-backup", includeMetadata: selectedPresetID == "writer-backup", createdAt: createdAt)
    }

    private func reconciled(with presets: [ExportPreset]) -> ExportUIState {
        let presented = Self.presentedPresets(presets)
        guard let preset = selectedPreset(in: presented) else { return self }
        var copy = self
        copy.availableFormats = ExportFormat.uiVisibleFormats
        copy.disabledFormats = ExportFormat.uiVisibleFormats.compactMap { format in
            guard !preset.allowedFormats.contains(format) else { return nil }
            return DisabledExportFormat(format: format, reason: String(format: String(localized: "%@ does not support %@."), localized(preset.title), localized(format.displayName)))
        }
        if copy.disabledReason(for: copy.selectedFormat) != nil { copy.selectedFormat = preset.allowedFormats.contains(.pdf) ? .pdf : preset.format }
        return copy
    }

    private func localized(_ value: String) -> String { String(localized: String.LocalizationValue(value)) }
}

extension ExportFormat: Identifiable {
    public var id: String { rawValue }
    static var uiVisibleFormats: [ExportFormat] { [.fountain, .pdf, .markdown, .plainText, .jsonBackup] }
    var displayName: String { switch self { case .fountain: "Fountain"; case .pdf: "PDF"; case .plainText: "Plain Text"; case .markdown: "Markdown"; case .jsonBackup: "JSON Backup" } }
    var writerDescription: String { switch self { case .fountain: "A screenplay text format that other writing tools can open."; case .pdf: "A readable copy for sharing or printing."; case .plainText: "A durable text archive of the script."; case .markdown: "A readable document with script text and optional notes."; case .jsonBackup: "A structured backup that can restore the project." } }
    var fileExtension: String { switch self { case .fountain: "fountain"; case .pdf: "pdf"; case .plainText: "txt"; case .markdown: "md"; case .jsonBackup: "json" } }
}
