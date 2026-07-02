import AppKit
import DreamJotterCore
import SwiftUI

struct TextKitScreenplayEditorView: NSViewRepresentable {
    @Binding var text: String
    let navigationState: EditorNavigationState
    let styleRuns: [EditorLineStyleRun]
    let onSmartEnter: (Int) -> Void
    let onTabCycle: (Int) -> Void
    let onTextChanged: (Int) -> Void
    let onSelectionChanged: (Int) -> Void
    let onNavigationApplied: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            onSmartEnter: onSmartEnter,
            onTabCycle: onTabCycle,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onNavigationApplied: onNavigationApplied
        )
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(containerSize: NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        ))
        textContainer.widthTracksTextView = true
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        let textView = ScreenplayTextView(frame: .zero, textContainer: textContainer)
        scrollView.documentView = textView

        textView.delegate = context.coordinator
        textView.keyHandler = context.coordinator
        textView.string = text
        textView.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.textColor = .textColor
        textView.backgroundColor = .textBackgroundColor
        textView.isRichText = false
        textView.importsGraphics = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainerInset = NSSize(width: 12, height: 12)
        applyStyles(to: textView)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? ScreenplayTextView else { return }
        textView.keyHandler = context.coordinator
        context.coordinator.updateClosures(
            onSmartEnter: onSmartEnter,
            onTabCycle: onTabCycle,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onNavigationApplied: onNavigationApplied
        )

        // AppKit uses marked text while composing accented and other multi-stage
        // characters. Replacing the string or attributes during composition
        // cancels the input method and drops the accent.
        guard !textView.hasMarkedText() else { return }

        if textView.string != text {
            let selectedRange = context.coordinator.selectedRange
            textView.string = text
            textView.setSelectedRange(Self.validRange(selectedRange, in: textView.string))
        }
        applyStyles(to: textView)
        applyNavigationIfNeeded(to: textView, context: context)
    }

    private static func validRange(_ range: NSRange, in text: String) -> NSRange {
        let maxLocation = (text as NSString).length
        let location = min(range.location, maxLocation)
        let length = min(range.length, maxLocation - location)
        return NSRange(location: location, length: length)
    }

    private func applyNavigationIfNeeded(to textView: NSTextView, context: Context) {
        guard let targetRange = navigationState.scrollTarget?.textRange else { return }
        let nsRange = Self.validRange(
            NSRange(location: targetRange.location, length: targetRange.length),
            in: textView.string
        )
        guard context.coordinator.lastAppliedNavigationRange != nsRange else { return }

        context.coordinator.lastAppliedNavigationRange = nsRange
        context.coordinator.selectedRange = nsRange
        textView.setSelectedRange(nsRange)
        textView.scrollRangeToVisible(nsRange)
        onNavigationApplied()
    }

    private func applyStyles(to textView: NSTextView) {
        guard !textView.hasMarkedText(), let textStorage = textView.textStorage else { return }
        let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)

        let baseFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textStorage.setAttributes([
            .font: baseFont,
            .foregroundColor: NSColor.textColor
        ], range: fullRange)

        for run in styleRuns {
            let range = Self.validRange(NSRange(location: run.textRange.location, length: run.textRange.length), in: textView.string)
            guard range.length > 0 else { continue }

            switch run.kind {
            case .sceneHeading:
                textStorage.addAttributes([
                    .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .bold),
                    .foregroundColor: NSColor.controlAccentColor
                ], range: range)
            case .characterCue:
                textStorage.addAttributes([
                    .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold)
                ], range: range)
            case .transition:
                textStorage.addAttributes([
                    .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold),
                    .foregroundColor: NSColor.secondaryLabelColor
                ], range: range)
            case .noteReference:
                textStorage.addAttributes([
                    .foregroundColor: NSColor.systemOrange
                ], range: range)
            default:
                break
            }
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate, ScreenplayTextViewKeyHandler {
        private var text: Binding<String>
        private var onSmartEnter: (Int) -> Void
        private var onTabCycle: (Int) -> Void
        private var onTextChanged: (Int) -> Void
        private var onSelectionChanged: (Int) -> Void
        private var onNavigationApplied: () -> Void
        var selectedRange = NSRange(location: 0, length: 0)
        var lastAppliedNavigationRange: NSRange?

        init(
            text: Binding<String>,
            onSmartEnter: @escaping (Int) -> Void,
            onTabCycle: @escaping (Int) -> Void,
            onTextChanged: @escaping (Int) -> Void,
            onSelectionChanged: @escaping (Int) -> Void,
            onNavigationApplied: @escaping () -> Void
        ) {
            self.text = text
            self.onSmartEnter = onSmartEnter
            self.onTabCycle = onTabCycle
            self.onTextChanged = onTextChanged
            self.onSelectionChanged = onSelectionChanged
            self.onNavigationApplied = onNavigationApplied
        }

        func updateClosures(
            onSmartEnter: @escaping (Int) -> Void,
            onTabCycle: @escaping (Int) -> Void,
            onTextChanged: @escaping (Int) -> Void,
            onSelectionChanged: @escaping (Int) -> Void,
            onNavigationApplied: @escaping () -> Void
        ) {
            self.onSmartEnter = onSmartEnter
            self.onTabCycle = onTabCycle
            self.onTextChanged = onTextChanged
            self.onSelectionChanged = onSelectionChanged
            self.onNavigationApplied = onNavigationApplied
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            selectedRange = textView.selectedRange()
            text.wrappedValue = textView.string
            onTextChanged(selectedRange.location)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            selectedRange = textView.selectedRange()
            onSelectionChanged(selectedRange.location)
        }

        func handleSmartEnter(in textView: NSTextView) -> Bool {
            selectedRange = textView.selectedRange()
            onSmartEnter(selectedRange.location)
            return true
        }

        func handleTabCycle(in textView: NSTextView) -> Bool {
            selectedRange = textView.selectedRange()
            onTabCycle(selectedRange.location)
            return true
        }

        func didApplyNavigation() {
            onNavigationApplied()
        }
    }
}

@MainActor
protocol ScreenplayTextViewKeyHandler: AnyObject {
    func handleSmartEnter(in textView: NSTextView) -> Bool
    func handleTabCycle(in textView: NSTextView) -> Bool
}

final class ScreenplayTextView: NSTextView {
    weak var keyHandler: ScreenplayTextViewKeyHandler?

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 || event.keyCode == 76 {
            if keyHandler?.handleSmartEnter(in: self) == true {
                return
            }
        }

        if event.keyCode == 48 {
            if keyHandler?.handleTabCycle(in: self) == true {
                return
            }
        }

        super.keyDown(with: event)
    }
}
