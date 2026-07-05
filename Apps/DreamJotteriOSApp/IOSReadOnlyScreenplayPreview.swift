import SwiftUI
import UIKit

struct IOSReadOnlyScreenplayPreview: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .clear
        textView.textColor = .label
        textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.accessibilityLabel = "Read-only screenplay preview"
        textView.text = displayText
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        let nextText = displayText
        guard textView.text != nextText else { return }
        let offset = textView.contentOffset
        textView.text = nextText
        textView.setContentOffset(offset, animated: false)
    }

    private var displayText: String {
        text.isEmpty ? "No script text yet." : text
    }
}
