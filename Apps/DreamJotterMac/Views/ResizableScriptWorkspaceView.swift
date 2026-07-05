import SwiftUI

struct ResizableScriptWorkspaceView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var inspectorWidth: CGFloat = 300
    @State private var dragStartWidth: CGFloat?

    private let minimumInspectorWidth: CGFloat = 240
    private let maximumInspectorWidth: CGFloat = 420
    private let minimumEditorWidth: CGFloat = 360

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                TextKitOnlyScriptEditorView(document: $document)
                    .frame(minWidth: minimumEditorWidth, maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)

                divider

                ScreenplayParagraphInspectorView(document: $document)
                    .frame(width: boundedInspectorWidth(for: proxy.size.width))
                    .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(nsColor: .separatorColor))
            .frame(width: 1)
            .overlay {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 10)
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        if hovering {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let start = dragStartWidth ?? inspectorWidth
                                if dragStartWidth == nil { dragStartWidth = start }
                                inspectorWidth = min(
                                    maximumInspectorWidth,
                                    max(minimumInspectorWidth, start - value.translation.width)
                                )
                            }
                            .onEnded { _ in
                                dragStartWidth = nil
                            }
                    )
            }
    }

    private func boundedInspectorWidth(for availableWidth: CGFloat) -> CGFloat {
        let maximumAllowed = max(minimumInspectorWidth, availableWidth - minimumEditorWidth - 1)
        return min(inspectorWidth, min(maximumInspectorWidth, maximumAllowed))
    }
}
