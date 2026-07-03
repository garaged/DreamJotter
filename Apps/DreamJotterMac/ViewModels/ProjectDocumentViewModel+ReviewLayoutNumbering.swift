import DreamJotterCore

struct ReviewLayoutLine: Equatable, Identifiable {
    let documentPageNumber: Int
    let screenplayPageNumber: Int
    let blockNumber: Int
    let paragraphNumber: Int
    let lineNumber: Int
    let sourceElementIndex: Int
    let role: PDFBlockRole
    let text: String

    var id: String {
        "review-layout-\(documentPageNumber)-\(blockNumber)-\(paragraphNumber)-\(lineNumber)-\(sourceElementIndex)"
    }

    var addressLabel: String {
        "Page \(screenplayPageNumber) · Paragraph \(paragraphNumber) · Block \(blockNumber) · Source \(sourceElementIndex)"
    }
}

extension ProjectDocumentViewModel {
    static let reviewNumberedPDFPresetID = "print-script"

    var reviewPDFLayoutPlan: PDFLayoutPlan? {
        guard let preset = ExportPresetCatalog.builtInPresets().first(where: {
            $0.id == Self.reviewNumberedPDFPresetID
        }) else {
            return nil
        }

        let defaults = PDFLayoutSettings.defaults(for: preset)
        let settings = PDFLayoutSettings(
            pageSize: defaults.pageSize,
            margins: defaults.margins,
            lineHeight: defaults.lineHeight,
            charactersPerBodyLine: 96,
            contentLinesPerPage: 54,
            includeTitlePage: defaults.includeTitlePage,
            includePageNumbers: defaults.includePageNumbers,
            suppressIdentifyingMetadata: defaults.suppressIdentifyingMetadata
        )
        return PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)
    }

    var reviewLayoutLines: [ReviewLayoutLine] {
        guard let plan = reviewPDFLayoutPlan else { return [] }

        return plan.contentPages.reduce(into: [ReviewLayoutLine]()) { pageLines, page in
            guard let screenplayPageNumber = page.screenplayPageNumber else { return }

            for block in page.blocks {
                guard let paragraphNumber = block.paragraphNumber,
                      let sourceElementIndex = block.sourceElementIndex else {
                    continue
                }

                pageLines.append(contentsOf: block.lines.map { line in
                    ReviewLayoutLine(
                        documentPageNumber: page.documentPageNumber,
                        screenplayPageNumber: screenplayPageNumber,
                        blockNumber: block.blockNumber,
                        paragraphNumber: paragraphNumber,
                        lineNumber: line.lineNumber,
                        sourceElementIndex: sourceElementIndex,
                        role: block.role,
                        text: line.text
                    )
                })
            }
        }
    }
}