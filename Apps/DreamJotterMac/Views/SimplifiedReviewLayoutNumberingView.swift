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
                        HStack(alignment: .top, spacing: 12) {
                            if showParagraph, let paragraphNumber = block.paragraphNumber {
                                Text("P\(paragraphNumber)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 52, alignment: .trailing)
                            }

                            if showLine {
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
                            } else {
                                Text(block.lines.map(\.text).joined(separator: " "))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
}
