import DreamJotteriOS
import SwiftUI
import UIKit

@MainActor
final class IOSNativeTextKitCoordinator: NSObject, UITextViewDelegate {
    var session: Binding<IOSEditorSession>
    var onVisibleRangeChanged: (NSRange) -> Void
    var isApplyingViewChange = false

    init(
        session: Binding<IOSEditorSession>,
        onVisibleRangeChanged: @escaping (NSRange) -> Void
    ) {
        self.session = session
        self.onVisibleRangeChanged = onVisibleRangeChanged
    }

    func captureState(from textView: UITextView) {}

    func textViewDidChange(_ textView: UITextView) {
        let kind: IOSEditorMutationKind = textView.undoManager?.isUndoing == true
            ? .undo
            : (textView.undoManager?.isRedoing == true ? .redo : .typing)
        isApplyingViewChange = true
        session.wrappedValue.applyTextChange(
            replacementText: textView.text ?? "",
            selection: IOSEditorSelection(
                location: textView.selectedRange.location,
                length: textView.selectedRange.length
            ),
            kind: kind
        )
        isApplyingViewChange = false
        notifyVisibleRange(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard !isApplyingViewChange else { return }
        session.wrappedValue.updateSelection(IOSEditorSelection(
            location: textView.selectedRange.location,
            length: textView.selectedRange.length
        ))
        notifyVisibleRange(textView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let textView = scrollView as? UITextView else { return }
        notifyVisibleRange(textView)
    }

    private func notifyVisibleRange(_ textView: UITextView) {
        let glyphRange = textView.layoutManager.glyphRange(
            forBoundingRect: textView.bounds,
            in: textView.textContainer
        )
        onVisibleRangeChanged(
            textView.layoutManager.characterRange(
                forGlyphRange: glyphRange,
                actualGlyphRange: nil
            )
        )
    }
}
