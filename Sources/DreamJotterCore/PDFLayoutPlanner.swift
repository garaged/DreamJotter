import Foundation

public enum PDFLayoutPlanner {
    public static func plan(
        for project: DreamJotterProject,
        preset: ExportPreset,
        settings explicitSettings: PDFLayoutSettings? = nil
    ) -> PDFLayoutPlan {
        let settings = explicitSettings ?? .defaults(for: preset)
        let title = normalizedTitle(project.metadata.title)
        var warnings = initialWarnings(for: project, preset: preset, title: title)
        var pages: [PDFPagePlan] = []

        if settings.includeTitlePage {
            pages.append(makeTitlePage(title: title, pageIndex: 0))
        }

        let blocks = project.screenplay.elements.flatMap { element -> [PDFBlockPlan] in
            guard element.kind != .pageBreak else { return [] }
            return [makeBlock(for: element, settings: settings, warnings: &warnings)]
        }

        var pageBlocks: [PDFBlockPlan] = []
        var lineCount = 0
        var screenplayPageNumber = 1

        for block in blocks {
            if lineCount + block.lineCount > settings.contentLinesPerPage, !pageBlocks.isEmpty {
                pages.append(PDFPagePlan(
                    pageIndex: pages.count,
                    screenplayPageNumber: settings.includePageNumbers ? screenplayPageNumber : nil,
                    isTitlePage: false,
                    blocks: pageBlocks
                ))
                screenplayPageNumber += 1
                pageBlocks = []
                lineCount = 0
            }
            pageBlocks.append(block)
            lineCount += block.lineCount
        }

        if !pageBlocks.isEmpty {
            pages.append(PDFPagePlan(
                pageIndex: pages.count,
                screenplayPageNumber: settings.includePageNumbers ? screenplayPageNumber : nil,
                isTitlePage: false,
                blocks: pageBlocks
            ))
        }

        if pages.isEmpty {
            pages.append(PDFPagePlan(pageIndex: 0, screenplayPageNumber: nil, isTitlePage: false, blocks: []))
        }

        return PDFLayoutPlan(documentTitle: title, settings: settings, pages: pages, warnings: warnings)
    }

    private static func initialWarnings(for project: DreamJotterProject, preset: ExportPreset, title: String) -> [PDFLayoutWarning] {
        var warnings: [PDFLayoutWarning] = []
        if title == "Untitled" {
            warnings.append(PDFLayoutWarning(code: .missingTitleMetadata, message: "Project title is missing; using Untitled."))
        }
        if !project.notes.isEmpty && !preset.includesNotes {
            warnings.append(PDFLayoutWarning(code: .notesOmitted, message: "Project notes are omitted from this PDF preset."))
        }
        return warnings
    }

    private static func makeTitlePage(title: String, pageIndex: Int) -> PDFPagePlan {
        let line = PDFLinePlan(text: title, role: .title, alignment: .centered)
        let block = PDFBlockPlan(role: .title, sourceElementKind: .titlePage, lines: [line])
        return PDFPagePlan(pageIndex: pageIndex, screenplayPageNumber: nil, isTitlePage: true, blocks: [block])
    }

    private static func makeBlock(for element: ScriptElement, settings: PDFLayoutSettings, warnings: inout [PDFLayoutWarning]) -> PDFBlockPlan {
        let role = role(for: element.kind)
        if element.kind == .unknown {
            warnings.append(PDFLayoutWarning(code: .malformedElementFallback, message: "Unknown screenplay text was included as readable fallback text."))
        }
        let lines = wrap(element.text, width: width(for: role, settings: settings)).map {
            PDFLinePlan(text: $0, role: role, alignment: alignment(for: role))
        }
        return PDFBlockPlan(role: role, sourceElementKind: element.kind, lines: lines, keepWithNext: element.kind == .characterCue)
    }

    private static func role(for kind: ScriptElementKind) -> PDFBlockRole {
        switch kind {
        case .sceneHeading:
            return .sceneHeading
        case .characterCue:
            return .characterCue
        case .parenthetical:
            return .parenthetical
        case .dialogue:
            return .dialogue
        case .transition:
            return .transition
        case .titlePage:
            return .title
        case .action, .shot, .section, .synopsis:
            return .action
        case .noteReference, .pageBreak, .unknown:
            return .fallback
        }
    }

    private static func alignment(for role: PDFBlockRole) -> PDFTextAlignment {
        switch role {
        case .title, .characterCue, .parenthetical, .dialogue:
            return .centered
        case .transition, .pageNumber:
            return .right
        case .sceneHeading, .action, .fallback:
            return .left
        }
    }

    private static func width(for role: PDFBlockRole, settings: PDFLayoutSettings) -> Int {
        switch role {
        case .dialogue:
            return max(24, settings.charactersPerBodyLine - 24)
        case .parenthetical:
            return max(20, settings.charactersPerBodyLine - 30)
        case .characterCue:
            return max(20, settings.charactersPerBodyLine - 28)
        case .transition:
            return max(24, settings.charactersPerBodyLine - 20)
        case .title, .sceneHeading, .action, .fallback, .pageNumber:
            return settings.charactersPerBodyLine
        }
    }

    private static func wrap(_ text: String, width: Int) -> [String] {
        let words = text.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").map(String.init)
        guard !words.isEmpty else { return [""] }
        var lines: [String] = []
        var current = ""
        for word in words {
            if current.isEmpty {
                current = word
            } else if current.count + 1 + word.count <= width {
                current += " \(word)"
            } else {
                lines.append(current)
                current = word
            }
        }
        if !current.isEmpty { lines.append(current) }
        return lines
    }

    private static func normalizedTitle(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }
}
