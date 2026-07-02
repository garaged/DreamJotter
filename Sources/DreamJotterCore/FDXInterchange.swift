import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct FDXDiagnostic: Codable, Equatable, Sendable {
    public enum Severity: String, Codable, Equatable, Sendable {
        case warning
        case error
    }

    public let code: String
    public let severity: Severity
    public let message: String
    public let paragraphIndex: Int?

    public init(code: String, severity: Severity, message: String, paragraphIndex: Int? = nil) {
        self.code = code
        self.severity = severity
        self.message = message
        self.paragraphIndex = paragraphIndex
    }
}

public struct FDXImportResult: Equatable, Sendable {
    public let document: ScreenplayDocument?
    public let diagnostics: [FDXDiagnostic]

    public init(document: ScreenplayDocument?, diagnostics: [FDXDiagnostic]) {
        self.document = document
        self.diagnostics = diagnostics
    }
}

public struct FDXExportResult: Equatable, Sendable {
    public let data: Data
    public let diagnostics: [FDXDiagnostic]

    public init(data: Data, diagnostics: [FDXDiagnostic]) {
        self.data = data
        self.diagnostics = diagnostics
    }
}

public enum FDXInterchange {
    public static func export(_ document: ScreenplayDocument) -> FDXExportResult {
        var diagnostics: [FDXDiagnostic] = []
        var paragraphs: [String] = []

        for (index, element) in document.elements.enumerated() {
            guard let type = paragraphType(for: element.kind) else {
                diagnostics.append(FDXDiagnostic(
                    code: "fdx.export.omittedElement",
                    severity: .warning,
                    message: "The \(element.kind.rawValue) element is not represented in the portable FDX subset and was omitted.",
                    paragraphIndex: index
                ))
                continue
            }
            paragraphs.append("    <Paragraph Type=\"\(type)\"><Text>\(escapeXML(element.text))</Text></Paragraph>")
        }

        let xml = ([
            "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>",
            "<FinalDraft DocumentType=\"Script\" Template=\"No\" Version=\"3\">",
            "  <Content>"
        ] + paragraphs + [
            "  </Content>",
            "</FinalDraft>",
            ""
        ]).joined(separator: "\n")

        return FDXExportResult(data: Data(xml.utf8), diagnostics: diagnostics)
    }

    public static func importDocument(from data: Data) -> FDXImportResult {
        let delegate = ParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false

        guard parser.parse(), delegate.rootIsFinalDraft else {
            let message = parser.parserError?.localizedDescription ?? "The document is not a supported Final Draft XML file."
            return FDXImportResult(
                document: nil,
                diagnostics: delegate.diagnostics + [FDXDiagnostic(
                    code: "fdx.import.invalidXML",
                    severity: .error,
                    message: message
                )]
            )
        }

        let elements = delegate.paragraphs.enumerated().map { index, paragraph in
            ScriptElement(
                kind: elementKind(for: paragraph.type, diagnostics: &delegate.diagnostics, paragraphIndex: index),
                text: paragraph.text,
                characterName: normalizedCharacterName(for: paragraph)
            )
        }

        return FDXImportResult(
            document: ScreenplayDocument(
                elements: elements,
                scenes: deriveScenes(from: elements),
                characters: deriveCharacters(from: elements),
                diagnostics: []
            ),
            diagnostics: delegate.diagnostics
        )
    }

    private static func paragraphType(for kind: ScriptElementKind) -> String? {
        switch kind {
        case .sceneHeading: return "Scene Heading"
        case .action: return "Action"
        case .characterCue: return "Character"
        case .parenthetical: return "Parenthetical"
        case .dialogue: return "Dialogue"
        case .transition: return "Transition"
        case .shot: return "Shot"
        case .section, .synopsis: return "Action"
        case .titlePage, .noteReference, .pageBreak, .unknown: return nil
        }
    }

    private static func elementKind(
        for paragraphType: String,
        diagnostics: inout [FDXDiagnostic],
        paragraphIndex: Int
    ) -> ScriptElementKind {
        switch paragraphType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "scene heading": return .sceneHeading
        case "action", "general": return .action
        case "character": return .characterCue
        case "parenthetical": return .parenthetical
        case "dialogue": return .dialogue
        case "transition": return .transition
        case "shot": return .shot
        default:
            diagnostics.append(FDXDiagnostic(
                code: "fdx.import.unknownParagraphType",
                severity: .warning,
                message: "Unknown FDX paragraph type '\(paragraphType)' was preserved as an unknown screenplay element.",
                paragraphIndex: paragraphIndex
            ))
            return .unknown
        }
    }

    private static func normalizedCharacterName(for paragraph: ParsedParagraph) -> String? {
        guard paragraph.type.caseInsensitiveCompare("Character") == .orderedSame else { return nil }
        let trimmed = paragraph.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func deriveCharacters(from elements: [ScriptElement]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for element in elements where element.kind == .characterCue {
            let name = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            guard !name.isEmpty, seen.insert(key).inserted else { continue }
            result.append(name)
        }
        return result
    }

    private static func deriveScenes(from elements: [ScriptElement]) -> [Scene] {
        elements.compactMap { element in
            guard element.kind == .sceneHeading else { return nil }
            let heading = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !heading.isEmpty else { return nil }
            let parts = heading.components(separatedBy: " - ")
            let locationPart = parts.first ?? heading
            let location = locationPart
                .replacingOccurrences(of: #"^(INT\./EXT\.|INT/EXT\.|I/E\.|INT\.|EXT\.)\s*"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let timeOfDay = parts.count > 1 ? parts.last?.trimmingCharacters(in: .whitespacesAndNewlines) : nil
            return Scene(heading: heading, location: location, timeOfDay: timeOfDay)
        }
    }

    private static func escapeXML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

private struct ParsedParagraph {
    let type: String
    let text: String
}

private final class ParserDelegate: NSObject, XMLParserDelegate {
    var rootIsFinalDraft = false
    var paragraphs: [ParsedParagraph] = []
    var diagnostics: [FDXDiagnostic] = []

    private var currentType: String?
    private var textBuffer = ""
    private var isReadingText = false

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "FinalDraft" {
            rootIsFinalDraft = true
        } else if elementName == "Paragraph" {
            currentType = attributeDict["Type"] ?? "Action"
            textBuffer = ""
        } else if elementName == "Text", currentType != nil {
            isReadingText = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isReadingText {
            textBuffer += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "Text" {
            isReadingText = false
        } else if elementName == "Paragraph", let type = currentType {
            paragraphs.append(ParsedParagraph(type: type, text: textBuffer))
            currentType = nil
            textBuffer = ""
            isReadingText = false
        }
    }
}
