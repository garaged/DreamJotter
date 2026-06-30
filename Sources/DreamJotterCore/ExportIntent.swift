import Foundation

public enum ExportFormat: String, Equatable, Sendable {
    case pdf
    case fountain
}

public struct ExportIntent: Equatable, Sendable {
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
