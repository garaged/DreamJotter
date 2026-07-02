import DreamJotterCore
import SwiftUI

struct ReviewLayoutNumberingView: View {
    let plan: PDFLayoutPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if plan.contentPages.flatMap(\.blocks).isEmpty {
                Text("No script text yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(plan.contentPages, id: \.pageIndex) { page in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Screenplay Page \(page.screenplayPageNumber ?? 0) · Document Page \(page.documentPageNumber)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

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

    private func blockView(page: PDFPagePlan, block: PDFBlockPlan) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text("Page \(page.screenplayPageNumber ?? 0)")
                if let paragraphNumber = block.paragraphNumber {
                    Text("· Paragraph \(paragraphNumber)")
                }
                Text("· Block \(block.blockNumber)")
                if let sourceElementIndex = block.sourceElementIndex {
                    Text("· Source \(sourceElementIndex)")
                }
                Text("· \(roleLabel(block.role))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ForEach(block.lines, id: \.lineNumber) { line in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(line.lineNumber)")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 22, alignment: .trailing)
                    Text(line.text.isEmpty ? " " : line.text)
                        .frame(maxWidth: .infinity, alignment: alignment(for: line.alignment))
                }
            }
        }
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

    private func alignment(for alignment: PDFTextAlignment) -> Alignment {
        switch alignment {
        case .left: return .leading
        case .centered: return .center
        case .right: return .trailing
        }
    }
}
