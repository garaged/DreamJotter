import Foundation

public enum PDFLayoutPlanner {
    public static func plan(
        for project: DreamJotterProject,
        preset: ExportPreset,
        settings explicitSettings: PDFLayoutSettings? = nil
    ) -> PDFLayoutPlan {
        let settings = normalizedSettings(explicitSettings ?? .defaults(for: preset), preset: preset)
        let title = normalizedTitle(project.metadata.title)
        var warnings = initialWarnings(for: project, preset: preset, title: title)
        var pages: [PDFPagePlan] = []

        if settings.includeTitlePage {
            pages.append(makeTitlePage(title: title, pageIndex: 0))
        }

        var pageBlocks: [PDFBlockPlan] = []
        var lineCount = 0
        var screenplayPageNumber = 1
        var paragraphNumber = 1

        func appendCurrentPageIfNeeded() {
            guard !pageBlocks.isEmpty else { return }
            pages.append(PDFPagePlan(
                pageIndex: pages.count,
                documentPageNumber: pages.count + 1,
                screenplayPageNumber: screenplayPageNumber,
                isTitlePage: false,
                blocks: pageBlocks
            ))
            screenplayPageNumber += 1
            pageBlocks = []
            lineCount = 0
        }

        func appendBlock(_ block: PDFBlockPlan) {
            guard block.lineCount > 0 else { return }
            if lineCount + block.lineCount > settings.contentLinesPerPage, !pageBlocks.isEmpty {
                appendCurrentPageIfNeeded()
            }
            pageBlocks.append(numbered(block, blockNumber: pageBlocks.count + 1))
            lineCount += block.lineCount
        }

        let elements = project.screenplay.elements
        var sourceElementIndex = 0
        while sourceElementIndex < elements.count {
            let element = elements[sourceElementIndex]

            if element.kind == .pageBreak {
                appendCurrentPageIfNeeded()
                sourceElementIndex += 1
                continue
            }

            if element.kind == .noteReference, !preset.includesNotes {
                sourceElementIndex += 1
                continue
            }

            var block = makeBlock(
                for: element,
                role: normalizedRole(at: sourceElementIndex, in: elements),
                paragraphNumber: paragraphNumber,
                sourceElementIndex: sourceElementIndex,
                settings: settings,
                warnings: &warnings
            )

            if element.kind == .characterCue,
               sourceElementIndex + 1 < elements.count {
                let nextElement = elements[sourceElementIndex + 1]
                if nextElement.kind == .dialogue || nextElement.kind == .parenthetical {
                    block = PDFBlockPlan(
                        blockNumber: 0,
                        paragraphNumber: block.paragraphNumber,
                        sourceElementIndex: block.sourceElementIndex,
                        role: block.role,
                        sourceElementKind: block.sourceElementKind,
                        lines: block.lines,
                        keepWithNext: true
                    )
                    let nextBlock = makeBlock(
                        for: nextElement,
                        role: normalizedRole(at: sourceElementIndex + 1, in: elements),
                        paragraphNumber: paragraphNumber + 1,
                        sourceElementIndex: sourceElementIndex + 1,
                        settings: settings,
                        warnings: &warnings
                    )
                    if lineCount + block.lineCount + nextBlock.lineCount > settings.contentLinesPerPage,
                       !pageBlocks.isEmpty {
                        appendCurrentPageIfNeeded()
                    }
                    appendBlock(block)
                    appendBlock(nextBlock)
                    paragraphNumber += 2
                    sourceElementIndex += 2
                    continue
                }
            }

            appendBlock(block)
            paragraphNumber += 1
            sourceElementIndex += 1
        }

        appendCurrentPageIfNeeded()

        if pages.isEmpty {
            pages.append(PDFPagePlan(
                pageIndex: 0,
                documentPageNumber: 1,
                screenplayPageNumber: nil,
                isTitlePage: false,
                blocks: []
            ))
        }

        return PDFLayoutPlan(documentTitle: title, settings: settings, pages: pages, warnings: warnings)
    }

    private static func normalizedSettings(
        _ settings: PDFLayoutSettings,
        preset: ExportPreset
    ) -> PDFLayoutSettings {
        guard preset.id == "print-script", settings.includeLineNumbers else {
            return settings
        }

        return PDFLayoutSettings(
            pageSize: settings.pageSize,
            margins: settings.margins,
            lineHeight: settings.lineHeight,
            charactersPerBodyLine: settings.charactersPerBodyLine,
            contentLinesPerPage: settings.contentLinesPerPage,
            includeTitlePage: settings.includeTitlePage,
            includePageNumbers: settings.includePageNumbers,
            includeParagraphNumbers: settings.includeParagraphNumbers,
            includeLineNumbers: false,
            suppressIdentifyingMetadata: settings.suppressIdentifyingMetadata
        )
    }

    private static func initialWarnings(
        for project: DreamJotterProject,
        preset: ExportPreset,
        title: String
    ) -> [PDFLayoutWarning] {
        var warnings: [PDFLayoutWarning] = []
        if title == "Untitled" {
            warnings.append(PDFLayoutWarning(code: .missingTitleMetadata, message: "Project title is missing; using Untitled."))
        }
        let hasOmittedNotes = !project.notes.isEmpty || project.screenplay.elements.contains { $0.kind == .noteReference }
        if hasOmittedNotes && !preset.includesNotes {
            warnings.append(PDFLayoutWarning(code: .notesOmitted, message: "Project notes and screenplay TODOs are omitted from this PDF preset."))
        }
        return warnings
    }

    private static func makeTitlePage(title: String, pageIndex: Int) -> PDFPagePlan {
        let line = PDFLinePlan(lineNumber: 1, text: title, role: .title, alignment: .centered)
        let block = PDFBlockPlan(
            blockNumber: 1,
            paragraphNumber: nil,
            sourceElementIndex: nil,
            role: .title,
            sourceElementKind: .titlePage,
            lines: [line]
        )
        return PDFPagePlan(
            pageIndex: pageIndex,
            documentPageNumber: pageIndex + 1,
            screenplayPageNumber: nil,
            isTitlePage: true,
            blocks: [block]
        )
    }

    private static func makeBlock(
        for element: ScriptElement,
        role: PDFBlockRole,
        paragraphNumber: Int,
        sourceElementIndex: Int,
        settings: PDFLayoutSettings,
        warnings: inout [PDFLayoutWarning]
    ) -> PDFBlockPlan {
        if element.kind == .unknown {
            warnings.append(PDFLayoutWarning(code: .malformedElementFallback, message: "Unknown screenplay text was included as readable fallback text."))
        }
        let lines = wrap(element.text, width: width(for: role, settings: settings)).enumerated().map {
            PDFLinePlan(lineNumber: $0.offset + 1, text: $0.element, role: role, alignment: alignment(for: role))
        }
        return PDFBlockPlan(
            blockNumber: 0,
            paragraphNumber: paragraphNumber,
            sourceElementIndex: sourceElementIndex,
            role: role,
            sourceElementKind: element.kind,
            lines: lines,
            keepWithNext: false
        )
    }

    private static func numbered(_ block: PDFBlockPlan, blockNumber: Int) -> PDFBlockPlan {
        PDFBlockPlan(
            blockNumber: blockNumber,
            paragraphNumber: block.paragraphNumber,
            sourceElementIndex: block.sourceElementIndex,
            role: block.role,
            sourceElementKind: block.sourceElementKind,
            lines: block.lines,
            keepWithNext: block.keepWithNext
        )
    }

    private static func normalizedRole(at index: Int, in elements: [ScriptElement]) -> PDFBlockRole {
        let element = elements[index]
        guard element.kind == .dialogue else {
            return role(for: element.kind)
        }

        guard index > 0 else {
            return .action
        }

        switch elements[index - 1].kind {
        case .characterCue, .parenthetical:
            return .dialogue
        default:
            return .action
        }
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
        if !current.isEmpty {
            lines.append(current)
        }
        return lines
    }

    private static func normalizedTitle(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }
}
