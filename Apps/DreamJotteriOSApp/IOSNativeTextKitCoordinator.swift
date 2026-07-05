import DreamJotterCore
import DreamJotteriOS
import SwiftUI
import UIKit

@MainActor
final class IOSNativeTextKitCoordinator: NSObject, UITextViewDelegate, IOSScreenplayTextViewCommandDelegate {
    var session: Binding<IOSEditorSession>
    var formattingRange: EditorTextRange
    var styleRuns: [EditorLineStyleRun]
    var onVisibleRangeChanged: (NSRange) -> Void
    var onMoveSuggestion: (Int) -> Bool
    var onAcceptSuggestion: () -> Bool
    var onDismissSuggestions: () -> Bool
    var onSmartEnter: () -> Void
    var onFormatCycle: () -> Void
    var isApplyingViewChange = false

    private weak var currentTextView: UITextView?
    private var lastStyledRevisionValue: Int?
    private var lastStyledRange: EditorTextRange?
    private var lastStyledRuns: [EditorLineStyleRun] = []

    init(
        session: Binding<IOSEditorSession>,
        formattingRange: EditorTextRange,
        styleRuns: [EditorLineStyleRun],
        onVisibleRangeChanged: @escaping (NSRange) -> Void,
        onMoveSuggestion: @escaping (Int) -> Bool,
        onAcceptSuggestion: @escaping () -> Bool,
        onDismissSuggestions: @escaping () -> Bool,
        onSmartEnter: @escaping () -> Void,
        onFormatCycle: @escaping () -> Void
    ) {
        self.session = session
        self.formattingRange = formattingRange
        self.styleRuns = styleRuns
        self.onVisibleRangeChanged = onVisibleRangeChanged
        self.onMoveSuggestion = onMoveSuggestion
        self.onAcceptSuggestion = onAcceptSuggestion
        self.onDismissSuggestions = onDismissSuggestions
        self.onSmartEnter = onSmartEnter
        self.onFormatCycle = onFormatCycle
    }

    func captureState(from textView: UITextView) {
        currentTextView = textView
        applyStyles(to: textView)
        notifyVisibleRange(textView, force: true)
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
        notifyVisibleRange(textView, force: true)
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
        let revisionValue = session.wrappedValue.revision.value
        guard revisionValue != lastStyledRevisionValue
                || formattingRange != lastStyledRange
                || styleRuns != lastStyledRuns else {
            return
        }

        let storage = textView.textStorage
        let safeLocation = min(formattingRange.location, storage.length)
        let safeLength = min(formattingRange.length, storage.length - safeLocation)
        guard safeLength > 0 else { return }

        let boundedRange = NSRange(location: safeLocation, length: safeLength)
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        storage.beginEditing()
        storage.addAttributes([
            .font: baseFont,
            .foregroundColor: UIColor.label
        ], range: boundedRange)
        for run in styleRuns {
            let range = NSRange(location: run.textRange.location, length: run.textRange.length)
            guard NSMaxRange(range) <= storage.length,
                  NSIntersectionRange(range, boundedRange).length > 0 else { continue }
            storage.addAttributes(attributes(for: run.kind, baseFont: baseFont), range: range)
        }
        storage.endEditing()

        lastStyledRevisionValue = revisionValue
        lastStyledRange = formattingRange
        lastStyledRuns = styleRuns
    }

    func screenplayTextViewHasSuggestions() -> Bool {
        onMoveSuggestion(0)
    }

    func screenplayTextViewMoveSuggestion(_ offset: Int) -> Bool {
        onMoveSuggestion(offset)
    }

    func screenplayTextViewAcceptSuggestion() -> Bool {
        let handled = performSemanticCommand(kind: .suggestionAcceptance, action: onAcceptSuggestion)
        if handled { announce("Suggestion accepted") }
        return handled
    }

    func screenplayTextViewDismissSuggestions() -> Bool {
        onDismissSuggestions()
    }

    func screenplayTextViewPerformSmartEnter() {
        let handled = performSemanticCommand(kind: .smartEnter) {
            onSmartEnter()
            return true
        }
        if handled { announce("Smart Enter applied") }
    }

    func screenplayTextViewPerformFormatCycle() {
        let handled = performSemanticCommand(kind: .elementFormatting) {
            onFormatCycle()
            return true
        }
        if handled { announce("Element format changed") }
    }

    func screenplayTextViewCopy() -> String? {
        IOSEditorClipboardService.copyPayload(from: session.wrappedValue)?.plainText
    }

    func screenplayTextViewCut() -> String? {
        var payload: IOSEditorClipboardPayload?
        let handled = performSemanticCommand(kind: .cut) {
            payload = IOSEditorClipboardService.cut(session: &session.wrappedValue)
            return payload != nil
        }
        if handled { announce("Screenplay block cut") }
        return payload?.plainText
    }

    func screenplayTextViewPaste(_ text: String) {
        let normalized = IOSPasteNormalizer.normalize(text)
        let handled = performSemanticCommand(kind: .paste) {
            let range = session.wrappedValue.selection.textRange
            let nextText = EditorUsabilityService.replacing(
                range: range,
                in: session.wrappedValue.text,
                with: normalized
            )
            let cursor = range.location + (normalized as NSString).length
            session.wrappedValue.applyTextChange(
                replacementText: nextText,
                selection: IOSEditorSelection(location: cursor, length: 0),
                kind: .paste
            )
            return true
        }
        if handled { announce("Text pasted") }
    }

    private func performSemanticCommand(
        kind: IOSEditorMutationKind,
        action: () -> Bool
    ) -> Bool {
        let before = session.wrappedValue
        let handled = action()
        guard handled, before != session.wrappedValue else { return handled }

        let transaction = IOSEditorTransactionPolicy.transaction(for: kind)
        let manager = currentTextView?.undoManager
        manager?.beginUndoGrouping()
        registerUndo(restoring: before, actionName: transaction.actionName, manager: manager)
        manager?.setActionName(transaction.actionName)
        manager?.endUndoGrouping()
        return true
    }

    private func registerUndo(
        restoring snapshot: IOSEditorSession,
        actionName: String,
        manager: UndoManager?
    ) {
        manager?.registerUndo(withTarget: self) { coordinator in
            MainActor.assumeIsolated {
                let redoSnapshot = coordinator.session.wrappedValue
                coordinator.session.wrappedValue = snapshot
                let activeManager = coordinator.currentTextView?.undoManager
                coordinator.registerUndo(
                    restoring: redoSnapshot,
                    actionName: actionName,
                    manager: activeManager
                )
                activeManager?.setActionName(actionName)
            }
        }
    }

    private func notifyVisibleRange(
        _ textView: UITextView,
        force: Bool = false
    ) {
        currentTextView = textView
        let glyphRange = textView.layoutManager.glyphRange(
            forBoundingRect: textView.bounds,
            in: textView.textContainer
        )
        let characterRange = textView.layoutManager.characterRange(
            forGlyphRange: glyphRange,
            actualGlyphRange: nil
        )

        if !force, formattingRange.length > 0 {
            let guardBand = min(1_024, max(128, formattingRange.length / 4))
            let safeStart = formattingRange.location + guardBand
            let safeEnd = formattingRange.location + formattingRange.length - guardBand
            if characterRange.location >= safeStart,
               NSMaxRange(characterRange) <= safeEnd {
                return
            }
        }

        onVisibleRangeChanged(characterRange)
    }

    private func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
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
