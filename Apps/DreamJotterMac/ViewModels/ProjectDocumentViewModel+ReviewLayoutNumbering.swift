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
    var reviewPDFLayoutPlan: PDFLayoutPlan? {
        guard let preset = ExportPresetCatalog.builtInPresets().first(where: { $0.id == "reader-copy" }) else {
            return nil
        }
        return PDFLayoutPlanner.plan(for: project, preset: preset)
    }

    var reviewLayoutLines: [ReviewLayoutLine] {
        guard let plan = reviewPDFLayoutPlan else { return [] }

        return plan.contentPages.flatMap { page in
            page.blocks.flatMap { block in
                guard let screenplayPageNumber = page.screenplayPageNumber,
                      let paragraphNumber = block.paragraphNumber,
                      let sourceElementIndex = block.sourceElementIndex else {
                    return []
                }

                return block.lines.map { line in
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
                }
            }
        }
    }
}
