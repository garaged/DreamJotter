import DreamJotterCore
import DreamJotteriOS
import SwiftUI
import UIKit

@MainActor
final class IOSNativeTextKitCoordinator: NSObject, UITextViewDelegate, IOSScreenplayTextViewCommandDelegate {
    var session: Binding<IOSEditorSession>
    var styleRuns: [EditorLineStyleRun]
    var onVisibleRangeChanged: (NSRange) -> Void
    var onMoveSuggestion: (Int) -> Bool
    var onAcceptSuggestion: () -> Bool
    var onDismissSuggestions: () -> Bool
    var onSmartEnter: () -> Void
    var onFormatCycle: () -> Void
    var isApplyingViewChange = false

    init(
        session: Binding<IOSEditorSession>,
        styleRuns: [EditorLineStyleRun],
        onVisibleRangeChanged: @escaping (NSRange) -> Void,
        onMoveSuggestion: @escaping (Int) -> Bool,
        onAcceptSuggestion: @escaping () -> Bool,
        onDismissSuggestions: @escaping () -> Bool,
        onSmartEnter: @escaping () -> Void,
        onFormatCycle: @escaping () -> Void
    ) {
        self.session = session
        self.styleRuns = styleRuns
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onMoveSuggestion = onMoveSuggestion
        self.onAcceptSuggestion = onAcceptSuggestion
        self.onDismissSuggestions = onDismissSuggestions
        self.onSmartEnter = onSmartEnter
        self.onFormatCycle = onFormatCycle
    }

    func captureState(from textView: UITextView) {
        applyStyles(to: textView)
    }

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

    func applyStyles(to textView: UITextView) {
        let storage = textView.textStorage
        let fullRange = NSRange(location: 0, length: storage.length)
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        storage.beginEditing()
        storage.addAttributes([
            .font: baseFont,
            .foregroundColor: UIColor.label
        ], range: fullRange)
        for run in styleRuns {
            let range = NSRange(location: run.textRange.location, length: run.textRange.length)
            guard NSMaxRange(range) <= storage.length else { continue }
            storage.addAttributes(attributes(for: run.kind, baseFont: baseFont), range: range)
        }
        storage.endEditing()
    }

    func screenplayTextViewMoveSuggestion(_ offset: Int) -> Bool {
        onMoveSuggestion(offset)
    }

    func screenplayTextViewAcceptSuggestion() -> Bool {
        performSemanticCommand(kind: .suggestionAcceptance, action: onAcceptSuggestion)
    }

    func screenplayTextViewDismissSuggestions() -> Bool {
        onDismissSuggestions()
    }

    func screenplayTextViewPerformSmartEnter() {
        _ = performSemanticCommand(kind: .smartEnter) {
            onSmartEnter()
            return true
        }
    }

    func screenplayTextViewPerformFormatCycle() {
        _ = performSemanticCommand(kind: .elementFormatting) {
            onFormatCycle()
            return true
        }
    }

    func screenplayTextViewPaste(_ text: String) {
        let normalized = IOSPasteNormalizer.normalize(text)
        let range = session.wrappedValue.selection.textRange
        let nextText = EditorUsabilityService.replacing(
            range: range,
            in: session.wrappedValue.text,
            with: normalized
        )
        let cursor = range.location + (normalized as NSString).length
        let transaction = IOSEditorTransactionPolicy.transaction(for: .paste)
        let manager = currentUndoManager
        manager?.beginUndoGrouping()
        session.wrappedValue.applyTextChange(
            replacementText: nextText,
            selection: IOSEditorSelection(location: cursor, length: 0),
            kind: .paste
        )
        manager?.setActionName(transaction.actionName)
        manager?.endUndoGrouping()
    }

    private weak var currentTextView: UITextView?
    private var currentUndoManager: UndoManager? { currentTextView?.undoManager }

    private func performSemanticCommand(
        kind: IOSEditorMutationKind,
        action: () -> Bool
    ) -> Bool {
        let transaction = IOSEditorTransactionPolicy.transaction(for: kind)
        let manager = currentUndoManager
        manager?.beginUndoGrouping()
        let handled = action()
        if handled {
            manager?.setActionName(transaction.actionName)
        }
        manager?.endUndoGrouping()
        return handled
    }

    private func notifyVisibleRange(_ textView: UITextView) {
        currentTextView = textView
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

    private func attributes(
        for kind: ScriptElementKind,
        baseFont: UIFont
    ) -> [NSAttributedString.Key: Any] {
        switch kind {
        case .sceneHeading:
            return [.font: UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .bold)]
        case .characterCue:
            return [.font: UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .semibold)]
        case .transition:
            return [.font: UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .medium)]
        case .noteReference:
            return [.foregroundColor: UIColor.secondaryLabel]
        default:
            return [:]
        }
    }
}
