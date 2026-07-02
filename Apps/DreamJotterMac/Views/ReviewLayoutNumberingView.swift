import DreamJotterCore
import SwiftUI

struct ReviewLayoutNumberingOptions: Equatable {
    var showPage = true
    var showParagraph = true
    var showBlock = true
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
                    VStack(alignment: .leading, spacing: 10) {
                        if options.showPage {
                            Text("Screenplay Page \(page.screenplayPageNumber ?? 0) · Document Page \(page.documentPageNumber)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }

                        ForEach(page.blocks, id: \.blockNumber) { block in
                            blockView(page: page, block: block)
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

    private func blockView(page: PDFPagePlan, block: PDFBlockPlan) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if let address = blockAddress(page: page, block: block) {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(block.lines, id: \.lineNumber) { line in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    if options.showLine {
                        Text("\(line.lineNumber)")
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 22, alignment: .trailing)
                    }
                    Text(line.text.isEmpty ? " " : line.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func blockAddress(page: PDFPagePlan, block: PDFBlockPlan) -> String? {
        var components: [String] = []

        if options.showPage {
            components.append("Page \(page.screenplayPageNumber ?? 0)")
        }
        if options.showParagraph, let paragraphNumber = block.paragraphNumber {
            components.append("Paragraph \(paragraphNumber)")
        }
        if options.showBlock {
            components.append("Block \(block.blockNumber)")
        }
        if options.showSourceElement, let sourceElementIndex = block.sourceElementIndex {
            components.append("Source \(sourceElementIndex)")
        }

        guard !components.isEmpty else { return nil }
        components.append(roleLabel(block.role))
        return components.joined(separator: " · ")
    }

    private func roleLabel(_ role: PDFBlockRole) -> String {
        switch role {
        case .title: return "Title"
        case .sceneHeading: return "Scene Heading"
        case .action: return "Action"
        case .characterCue: return "Character"
        case .parenthetical: return "Parenthetical"
        case .dialogue: return "Dialogue"
        case .transition: return "Transition"
        case .fallback: return "Fallback"
        case .pageNumber: return "Page Number"
        }
    }
}
