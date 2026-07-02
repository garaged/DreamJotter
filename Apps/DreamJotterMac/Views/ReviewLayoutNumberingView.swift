import DreamJotterCore
import SwiftUI

struct ReviewLayoutNumberingOptions: Equatable {
    var showPage = true
    var showParagraph = true
    var showBlock = false
    var showSourceElement = false
    var showLine = false
}

struct ReviewLayoutNumberingView: View {
    let plan: PDFLayoutPlan

    @State private var options = ReviewLayoutNumberingOptions()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            numberingControls

            if plan.contentPages.flatMap(\.blocks).isEmpty {
                Text("No script text yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(plan.contentPages, id: \.pageIndex) { page in
                    VStack(alignment: .leading, spacing: 12) {
                        if options.showPage {
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
        }
        .font(.system(.body, design: .monospaced))
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var numberingControls: some View {
        HStack(spacing: 14) {
            Text("Numbering levels")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Toggle("Page", isOn: $options.showPage)
            Toggle("Paragraph", isOn: $options.showParagraph)
            Toggle("Block", isOn: $options.showBlock)
            Toggle("Source", isOn: $options.showSourceElement)
            Toggle("Line", isOn: $options.showLine)

            Spacer()
        }
        .toggleStyle(.checkbox)
        .controlSize(.small)
    }

    private func blockView(_ block: PDFBlockPlan) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let address = blockAddress(block) {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 72, alignment: .trailing)
            }

            if options.showLine {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(block.lines, id: \.lineNumber) { line in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(line.lineNumber)")
                                .foregroundStyle(.secondary)
                                .frame(width: 22, alignment: .trailing)
                            Text(line.text.isEmpty ? " " : line.text)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(paragraphText(for: block))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func blockAddress(_ block: PDFBlockPlan) -> String? {
        var components: [String] = []

        if options.showParagraph, let paragraphNumber = block.paragraphNumber {
            components.append("P\(paragraphNumber)")
        }
        if options.showBlock {
            components.append("B\(block.blockNumber)")
        }
        if options.showSourceElement, let sourceElementIndex = block.sourceElementIndex {
            components.append("S\(sourceElementIndex)")
        }

        guard !components.isEmpty else { return nil }
        return components.joined(separator: " ")
    }

    private func paragraphText(for block: PDFBlockPlan) -> String {
        let text = block.lines
            .map(\.text)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? " " : text
    }
}
