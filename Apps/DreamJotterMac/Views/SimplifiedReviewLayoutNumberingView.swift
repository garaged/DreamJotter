import DreamJotterCore
import SwiftUI

struct SimplifiedReviewLayoutNumberingView: View {
    let plan: PDFLayoutPlan

    @State private var showPage = true
    @State private var showParagraph = true
    @State private var showLine = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Text("Numbering levels")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Toggle("Page", isOn: $showPage)
                Toggle("Paragraph", isOn: $showParagraph)
                Toggle("Line", isOn: $showLine)
                Spacer()
            }
            .toggleStyle(.checkbox)
            .controlSize(.small)

            ForEach(plan.contentPages, id: \.pageIndex) { page in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(page.blocks, id: \.blockNumber) { block in
                        blockView(page: page, block: block)
                    }
                }
            }
        }
        .font(.system(.body, design: .monospaced))
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func blockView(page: PDFPagePlan, block: PDFBlockPlan) -> some View {
        Group {
            if showLine {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(block.lines.enumerated()), id: \.element.lineNumber) { index, line in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(lineLabel(page: page, block: block, lineNumber: line.lineNumber, isFirstLine: index == 0))
                                .foregroundStyle(.secondary)
                                .frame(width: 58, alignment: .trailing)
                            Text(line.text.isEmpty ? " " : line.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    if let address = paragraphAddress(page: page, block: block) {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 52, alignment: .trailing)
                    }

                    Text(block.lines.map(\.text).joined(separator: " "))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func paragraphAddress(page: PDFPagePlan, block: PDFBlockPlan) -> String? {
        switch (showPage, showParagraph, page.screenplayPageNumber, block.paragraphNumber) {
        case (true, true, let pageNumber?, let paragraphNumber?):
            return "\(pageNumber).\(paragraphNumber)"
        case (true, false, let pageNumber?, _):
            return "\(pageNumber)"
        case (false, true, _, let paragraphNumber?):
            return "P\(paragraphNumber)"
        default:
            return nil
        }
    }

    private func lineLabel(
        page: PDFPagePlan,
        block: PDFBlockPlan,
        lineNumber: Int,
        isFirstLine: Bool
    ) -> String {
        guard isFirstLine,
              let address = paragraphAddress(page: page, block: block) else {
            return "\(lineNumber)"
        }
        return "\(address)/\(lineNumber)"
    }
}
