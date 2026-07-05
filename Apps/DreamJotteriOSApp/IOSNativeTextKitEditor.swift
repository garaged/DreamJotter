import DreamJotteriOS
import SwiftUI
import UIKit

struct IOSNativeTextKitEditor: UIViewRepresentable {
    @Binding var session: IOSEditorSession
    let onVisibleRangeChanged: (NSRange) -> Void

    func makeCoordinator() -> IOSNativeTextKitCoordinator {
        IOSNativeTextKitCoordinator(session: $session, onVisibleRangeChanged: onVisibleRangeChanged)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.keyboardDismissMode = .interactive
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.accessibilityLabel = "Screenplay editor"
        textView.text = session.text
        textView.selectedRange = NSRange(location: session.selection.location, length: session.selection.length)
        context.coordinator.captureState(from: textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.session = $session
        context.coordinator.onVisibleRangeChanged = onVisibleRangeChanged
        guard !context.coordinator.isApplyingViewChange else { return }

        if textView.text != session.text {
            textView.text = session.text
        }
        let selection = NSRange(location: session.selection.location, length: session.selection.length)
        if textView.selectedRange != selection {
            textView.selectedRange = selection
        }
    }
}
