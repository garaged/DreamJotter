import DreamJotterCore
import DreamJotteriOS
import SwiftUI
import UIKit

struct IOSNativeTextKitEditor: UIViewRepresentable {
    @Binding var session: IOSEditorSession
    let formattingRange: EditorTextRange
    let styleRuns: [EditorLineStyleRun]
    let onVisibleRangeChanged: (NSRange) -> Void
    let onMoveSuggestion: (Int) -> Bool
    let onAcceptSuggestion: () -> Bool
    let onDismissSuggestions: () -> Bool
    let onSmartEnter: () -> Void
    let onFormatCycle: () -> Void

    func makeCoordinator() -> IOSNativeTextKitCoordinator {
        IOSNativeTextKitCoordinator(
            session: $session,
            formattingRange: formattingRange,
            styleRuns: styleRuns,
            onVisibleRangeChanged: onVisibleRangeChanged,
            onMoveSuggestion: onMoveSuggestion,
            onAcceptSuggestion: onAcceptSuggestion,
            onDismissSuggestions: onDismissSuggestions,
            onSmartEnter: onSmartEnter,
            onFormatCycle: onFormatCycle
        )
    }

    func makeUIView(context: Context) -> IOSScreenplayTextView {
        let textView = IOSScreenplayTextView()
        textView.delegate = context.coordinator
        textView.commandDelegate = context.coordinator
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.keyboardDismissMode = .interactive
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.textContainer.widthTracksTextView = true
        textView.accessibilityLabel = "Screenplay editor"
        textView.text = session.text
        textView.selectedRange = NSRange(location: session.selection.location, length: session.selection.length)
        context.coordinator.captureState(from: textView)
        return textView
    }

    func updateUIView(_ textView: IOSScreenplayTextView, context: Context) {
        context.coordinator.session = $session
        context.coordinator.formattingRange = formattingRange
        context.coordinator.styleRuns = styleRuns
        context.coordinator.onVisibleRangeChanged = onVisibleRangeChanged
        context.coordinator.onMoveSuggestion = onMoveSuggestion
        context.coordinator.onAcceptSuggestion = onAcceptSuggestion
        context.coordinator.onDismissSuggestions = onDismissSuggestions
        context.coordinator.onSmartEnter = onSmartEnter
        context.coordinator.onFormatCycle = onFormatCycle
        guard !context.coordinator.isApplyingViewChange else { return }

        if textView.text != session.text {
            textView.text = session.text
        }
        let selection = NSRange(location: session.selection.location, length: session.selection.length)
        if textView.selectedRange != selection {
            textView.selectedRange = selection
        }
        context.coordinator.applyStyles(to: textView)
    }
}
