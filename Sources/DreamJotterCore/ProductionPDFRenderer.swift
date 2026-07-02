import Foundation

public enum PDFRenderDiagnosticCode: String, Codable, Equatable, Sendable {
    case layoutWarning
    case unsupportedCharacter
}

public struct PDFRenderDiagnostic: Codable, Equatable, Hashable, Sendable {
    public let code: PDFRenderDiagnosticCode
    public let message: String

    public init(code: PDFRenderDiagnosticCode, message: String) {
        self.code = code
        self.message = message
    }
}

public struct ProductionPDFRenderOutput: Equatable, Sendable {
    public let data: Data
    public let diagnostics: [PDFRenderDiagnostic]

    public init(data: Data, diagnostics: [PDFRenderDiagnostic]) {
        self.data = data
        self.diagnostics = diagnostics
    }
}

public enum ProductionPDFRenderer {
    public static func render(
        project: DreamJotterProject,
        preset: ExportPreset
    ) -> Data {
        renderOutput(project: project, preset: preset).data
    }

    public static func render(plan: PDFLayoutPlan) -> Data {
        renderOutput(plan: plan).data
    }

    public static func renderOutput(
        project: DreamJotterProject,
        preset: ExportPreset
    ) -> ProductionPDFRenderOutput {
        renderOutput(plan: PDFLayoutPlanner.plan(for: project, preset: preset))
    }

    public static func renderOutput(plan: PDFLayoutPlan) -> ProductionPDFRenderOutput {
        let pageCount = plan.pages.count
        let firstPageObject = 3
        let firstContentObject = firstPageObject + pageCount
        let regularFontObject = firstContentObject + pageCount
        let boldFontObject = regularFontObject + 1

        var objects: [String] = []
        var unsupportedCharacters = Set<String>()
        objects.append("<< /Type /Catalog /Pages 2 0 R >>")

        let pageReferences = (0..<pageCount)
            .map { "\(firstPageObject + $0) 0 R" }
            .joined(separator: " ")
        objects.append("<< /Type /Pages /Kids [\(pageReferences)] /Count \(pageCount) >>")

        for index in 0..<pageCount {
            let page = plan.pages[index]
            let mediaBox = "0 0 \(number(plan.settings.pageSize.width)) \(number(plan.settings.pageSize.height))"
            let contentReference = firstContentObject + index
            objects.append(
                "<< /Type /Page /Parent 2 0 R /MediaBox [\(mediaBox)] " +
                "/Resources << /Font << /F1 \(regularFontObject) 0 R /F2 \(boldFontObject) 0 R >> >> " +
                "/Contents \(contentReference) 0 R >>"
            )
        }

        for page in plan.pages {
            let stream = contentStream(
                for: page,
                settings: plan.settings,
                unsupportedCharacters: &unsupportedCharacters
            )
            objects.append("<< /Length \(stream.utf8.count) >>\nstream\n\(stream)\nendstream")
        }

        objects.append("<< /Type /Font /Subtype /Type1 /BaseFont /Courier /Encoding /WinAnsiEncoding >>")
        objects.append("<< /Type /Font /Subtype /Type1 /BaseFont /Courier-Bold /Encoding /WinAnsiEncoding >>")

        var diagnostics = plan.warnings.map { warning in
            PDFRenderDiagnostic(code: .layoutWarning, message: warning.message)
        }
        diagnostics.append(contentsOf: unsupportedCharacters.sorted().map { character in
            PDFRenderDiagnostic(
                code: .unsupportedCharacter,
                message: "The character ‘\(character)’ is not supported by the built-in PDF font and was replaced with ?."
            )
        })

        return ProductionPDFRenderOutput(
            data: assemble(objects: objects),
            diagnostics: diagnostics
        )
    }

    private static func contentStream(
        for page: PDFPagePlan,
        settings: PDFLayoutSettings,
        unsupportedCharacters: inout Set<String>
    ) -> String {
        var commands: [String] = []

        if page.isTitlePage {
            appendTitlePage(
                page,
                settings: settings,
                commands: &commands,
                unsupportedCharacters: &unsupportedCharacters
            )
        } else {
            appendScreenplayPage(
                page,
                settings: settings,
                commands: &commands,
                unsupportedCharacters: &unsupportedCharacters
            )
        }

        return commands.joined(separator: "\n")
    }

    private static func appendTitlePage(
        _ page: PDFPagePlan,
        settings: PDFLayoutSettings,
        commands: inout [String],
        unsupportedCharacters: inout Set<String>
    ) {
        let lines = page.blocks.flatMap(\.lines)
        let startY = settings.pageSize.height * 0.62

        for (index, line) in lines.enumerated() {
            let fontSize = index == 0 ? 18.0 : 12.0
            let y = startY - Double(index) * 24
            let x = centeredX(
                text: line.text,
                fontSize: fontSize,
                pageWidth: settings.pageSize.width
            )
            commands.append(textCommand(
                text: line.text,
                font: .bold,
                size: fontSize,
                x: x,
                y: y,
                unsupportedCharacters: &unsupportedCharacters
            ))
        }
    }

    private static func appendScreenplayPage(
        _ page: PDFPagePlan,
        settings: PDFLayoutSettings,
        commands: inout [String],
        unsupportedCharacters: inout Set<String>
    ) {
        var y = settings.pageSize.height - settings.margins.top

        if settings.includePageNumbers, let screenplayPageNumber = page.screenplayPageNumber {
            let text = "\(screenplayPageNumber)."
            let x = settings.pageSize.width - settings.margins.right - estimatedWidth(text, fontSize: 10)
            commands.append(textCommand(
                text: text,
                font: .regular,
                size: 10,
                x: x,
                y: settings.pageSize.height - 36,
                unsupportedCharacters: &unsupportedCharacters
            ))
        }

        for block in page.blocks {
            if block.role == .sceneHeading || block.role == .transition {
                y -= settings.lineHeight * 0.5
            }

            for line in block.lines {
                let style = style(for: block.role, text: line.text, settings: settings)
                commands.append(textCommand(
                    text: line.text,
                    font: style.font,
                    size: style.fontSize,
                    x: style.x,
                    y: y,
                    unsupportedCharacters: &unsupportedCharacters
                ))
                y -= settings.lineHeight
            }

            y -= spacingAfter(block.role, lineHeight: settings.lineHeight)
        }
    }

    private static func style(
        for role: PDFBlockRole,
        text: String,
        settings: PDFLayoutSettings
    ) -> (font: Font, fontSize: Double, x: Double) {
        let left = settings.margins.left
        let right = settings.pageSize.width - settings.margins.right
        let fontSize = 12.0

        switch role {
        case .title:
            return (.bold, 18, centeredX(text: text, fontSize: 18, pageWidth: settings.pageSize.width))
        case .sceneHeading:
            return (.bold, fontSize, left)
        case .action, .fallback:
            return (.regular, fontSize, left)
        case .characterCue:
            return (.bold, fontSize, left + 180)
        case .parenthetical:
            return (.regular, fontSize, left + 145)
        case .dialogue:
            return (.regular, fontSize, left + 105)
        case .transition:
            return (.bold, fontSize, max(left, right - estimatedWidth(text, fontSize: fontSize)))
        case .pageNumber:
            return (.regular, 10, right - estimatedWidth(text, fontSize: 10))
        }
    }

    private static func spacingAfter(_ role: PDFBlockRole, lineHeight: Double) -> Double {
        switch role {
        case .characterCue, .parenthetical:
            return 0
        case .dialogue:
            return lineHeight * 0.5
        default:
            return lineHeight * 0.75
        }
    }

    private static func textCommand(
        text: String,
        font: Font,
        size: Double,
        x: Double,
        y: Double,
        unsupportedCharacters: inout Set<String>
    ) -> String {
        let encoded = escaped(text, unsupportedCharacters: &unsupportedCharacters)
        return "BT /\(font.rawValue) \(number(size)) Tf \(number(x)) \(number(y)) Td (\(encoded)) Tj ET"
    }

    private static func centeredX(text: String, fontSize: Double, pageWidth: Double) -> Double {
        max(0, (pageWidth - estimatedWidth(text, fontSize: fontSize)) / 2)
    }

    private static func estimatedWidth(_ text: String, fontSize: Double) -> Double {
        Double(text.count) * fontSize * 0.6
    }

    private static func escaped(
        _ value: String,
        unsupportedCharacters: inout Set<String>
    ) -> String {
        var result = ""

        for character in value {
            switch character {
            case "\\":
                result += "\\\\"
            case "(":
                result += "\\("
            case ")":
                result += "\\)"
            case "\n", "\r", "\t":
                result += " "
            default:
                let text = String(character)
                guard let encoded = text.data(using: .windowsCP1252, allowLossyConversion: false),
                      encoded.count == 1,
                      let byte = encoded.first else {
                    result += "?"
                    unsupportedCharacters.insert(text)
                    continue
                }

                if byte >= 32 && byte <= 126 {
                    result.append(Character(UnicodeScalar(byte)))
                } else {
                    result += String(format: "\\%03o", byte)
                }
            }
        }

        return result
    }

    private static func assemble(objects: [String]) -> Data {
        var pdf = "%PDF-1.4\n%DreamJotter\n"
        var offsets = [0]

        for (index, object) in objects.enumerated() {
            offsets.append(pdf.utf8.count)
            pdf += "\(index + 1) 0 obj\n\(object)\nendobj\n"
        }

        let xrefOffset = pdf.utf8.count
        pdf += "xref\n0 \(objects.count + 1)\n"
        pdf += "0000000000 65535 f \n"
        for offset in offsets.dropFirst() {
            pdf += String(format: "%010d 00000 n \n", offset)
        }
        pdf += "trailer\n<< /Size \(objects.count + 1) /Root 1 0 R >>\n"
        pdf += "startxref\n\(xrefOffset)\n%%EOF\n"
        return Data(pdf.utf8)
    }

    private static func number(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.2f", value)
    }

    private enum Font: String {
        case regular = "F1"
        case bold = "F2"
    }
}
