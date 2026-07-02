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
                    if showPage {
                        Text("Page \(page.screenplayPageNumber ?? 0)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }

                    ForEach(page.blocks, id: \.blockNumber) { block in
                        blockView(block)
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

    private func blockView(_ block: PDFBlockPlan) -> some View {
        Group {
            if showLine {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(block.lines.enumerated()), id: \.element.lineNumber) { index, line in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(lineLabel(block: block, lineNumber: line.lineNumber, isFirstLine: index == 0))
                                .foregroundStyle(.secondary)
                                .frame(width: 48, alignment: .trailing)

                            Text(line.text.isEmpty ? " " : line.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if showParagraph, let paragraphNumber = block.paragraphNumber {
                HStack(alignment: .top, spacing: 12) {
                    Text("P\(paragraphNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .trailing)

                    paragraphText(block)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                paragraphText(block)
            }
        }
    }

    private func paragraphText(_ block: PDFBlockPlan) -> some View {
        Text(block.lines.map(\.text).joined(separator: " "))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func lineLabel(block: PDFBlockPlan, lineNumber: Int, isFirstLine: Bool) -> String {
        if showParagraph,
           isFirstLine,
           let paragraphNumber = block.paragraphNumber {
            return "P\(paragraphNumber) \(lineNumber)"
        }
        return "\(lineNumber)"
    }
}
