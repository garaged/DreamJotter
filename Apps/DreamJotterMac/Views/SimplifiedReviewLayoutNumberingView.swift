import DreamJotterCore
import SwiftUI

struct SimplifiedReviewLayoutNumberingView: View {
    let plan: PDFLayoutPlan

    @State private var showPage = true
    @State private var showParagraph = true
    @State private var showLine = false

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            numberingControls

            ForEach(plan.contentPages, id: \.pageIndex) { page in
                LazyVStack(alignment: .leading, spacing: 12) {
                    if showPage {
                        HStack(spacing: 4) {
                            Text(String(localized: "Page", table: "Review"))
                            Text((page.screenplayPageNumber ?? 0).formatted())
                        }
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    }

                    ForEach(page.blocks, id: \.blockNumber) { block in
                        blockView(block)
                    }
                }
                .id(page.pageIndex)
            }
        }
        .font(.system(.body, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .accessibilityElement(children: .contain)
    }

    private var numberingControls: some View {
        HStack(spacing: 14) {
            Text(String(localized: "Numbering levels", table: "Review"))
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Toggle(String(localized: "Page", table: "Review"), isOn: $showPage)
            Toggle(String(localized: "Paragraph", table: "Review"), isOn: $showParagraph)
            Toggle(String(localized: "Line", table: "Review"), isOn: $showLine)
            Spacer()
        }
        .toggleStyle(.checkbox)
        .controlSize(.small)
    }

    @ViewBuilder
    private func blockView(_ block: PDFBlockPlan) -> some View {
        if showLine {
            numberedLines(block)
        } else if showParagraph, let paragraphNumber = block.paragraphNumber {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                paragraphLabel(paragraphNumber)
                paragraphText(block)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            paragraphText(block)
        }
    }

    private func numberedLines(_ block: PDFBlockPlan) -> some View {
        LazyVStack(alignment: .leading, spacing: 2) {
            ForEach(Array(block.lines.enumerated()), id: \.element.lineNumber) { index, line in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    lineLabel(
                        paragraphNumber: block.paragraphNumber,
                        lineNumber: line.lineNumber,
                        isFirstLine: index == 0
                    )
                    .frame(width: 92, alignment: .trailing)

                    Text(line.text.isEmpty ? " " : line.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func paragraphLabel(_ paragraphNumber: Int) -> some View {
        Text("P\(paragraphNumber)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize()
    }

    private func lineLabel(
        paragraphNumber: Int?,
        lineNumber: Int,
        isFirstLine: Bool
    ) -> some View {
        let label: String
        if showParagraph,
           isFirstLine,
           let paragraphNumber {
            label = "P\(paragraphNumber) · \(lineNumber)"
        } else {
            label = "\(lineNumber)"
        }

        return Text(label)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize()
    }

    private func paragraphText(_ block: PDFBlockPlan) -> some View {
        Text(block.lines.lazy.map(\.text).joined(separator: " "))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}
