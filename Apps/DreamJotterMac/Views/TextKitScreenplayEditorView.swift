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
    let onSuggestionMove: (Int) -> Bool
    let onSuggestionAccept: () -> Bool
    let onSuggestionDismiss: () -> Bool
    let onNavigationApplied: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, parent: self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor

        let storage = NSTextStorage()
        let manager = NSLayoutManager()
        let container = NSTextContainer(containerSize: NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        ))
        container.widthTracksTextView = true
        storage.addLayoutManager(manager)
        manager.addTextContainer(container)

        let textView = ScreenplayTextView(frame: .zero, textContainer: container)
        scrollView.documentView = textView
        textView.delegate = context.coordinator
        textView.commandHandler = context.coordinator
        context.coordinator.attach(textView)
        textView.string = text
        configure(textView)
        applyStyles(to: textView)
        updateAccessibility(for: textView, coordinator: context.coordinator)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? ScreenplayTextView else { return }
        context.coordinator.parent = self
        textView.commandHandler = context.coordinator
        guard !textView.hasMarkedText() else { return }
        if textView.string != text {
            let range = Self.graphemeSafeRange(context.coordinator.selectedRange, in: text)
            textView.string = text
            textView.setSelectedRange(range)
            context.coordinator.selectedRange = range
        }
        applyStyles(to: textView)
        applyNavigationIfNeeded(to: textView, context: context)
        updateAccessibility(for: textView, coordinator: context.coordinator)
    }

    private func configure(_ textView: NSTextView) {
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
        textView.minSize = .zero
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.setAccessibilityRole(.textArea)
        textView.setAccessibilityLabel(String(localized: "Screenplay editor"))
    }

    nonisolated static func graphemeSafeRange(_ range: NSRange, in text: String) -> NSRange {
        let source = text as NSString
        let location = min(range.location, source.length)
        let length = min(range.length, source.length - location)
        let bounded = NSRange(location: location, length: length)
        guard bounded.length > 0 else {
            if location == source.length { return bounded }
            return NSRange(location: source.rangeOfComposedCharacterSequence(at: location).location, length: 0)
        }
        return source.rangeOfComposedCharacterSequences(for: bounded)
    }

    nonisolated static func normalizedPaste(_ value: String) -> String {
        value.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{2028}", with: "\n")
            .replacingOccurrences(of: "\u{2029}", with: "\n")
    }

    private func applyNavigationIfNeeded(to textView: NSTextView, context: Context) {
        guard let target = navigationState.scrollTarget?.textRange else { return }
        let range = Self.graphemeSafeRange(NSRange(location: target.location, length: target.length), in: textView.string)
        guard context.coordinator.lastAppliedNavigationRange != range else { return }
        context.coordinator.lastAppliedNavigationRange = range
        context.coordinator.selectedRange = range
        textView.setSelectedRange(range)
        textView.scrollRangeToVisible(range)
        onNavigationApplied()
    }

    private func applyStyles(to textView: NSTextView) {
        guard !textView.hasMarkedText(), let storage = textView.textStorage else { return }
        let full = NSRange(location: 0, length: (textView.string as NSString).length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        storage.setAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular), .foregroundColor: NSColor.textColor, .paragraphStyle: paragraph], range: full)
        for run in styleRuns {
            let range = Self.graphemeSafeRange(NSRange(location: run.textRange.location, length: run.textRange.length), in: textView.string)
            guard range.length > 0 else { continue }
            switch run.kind {
            case .sceneHeading: storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .bold), .foregroundColor: NSColor.controlAccentColor], range: range)
            case .characterCue: storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold)], range: range)
            case .parenthetical: storage.addAttributes([.foregroundColor: NSColor.secondaryLabelColor], range: range)
            case .transition: storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold), .foregroundColor: NSColor.secondaryLabelColor], range: range)
            case .noteReference: storage.addAttributes([.foregroundColor: NSColor.systemOrange], range: range)
            default: break
            }
        }
    }

    private func updateAccessibility(for textView: NSTextView, coordinator: Coordinator) {
        let location = min(coordinator.selectedRange.location, (textView.string as NSString).length)
        let kind = styleRuns.first { NSLocationInRange(location, NSRange(location: $0.textRange.location, length: max($0.textRange.length, 1))) }?.kind
        let description: String
        switch kind {
        case .sceneHeading: description = String(localized: "Scene heading")
        case .characterCue: description = String(localized: "Character cue")
        case .dialogue: description = String(localized: "Dialogue")
        case .parenthetical: description = String(localized: "Parenthetical")
        case .transition: description = String(localized: "Transition")
        case .noteReference: description = String(localized: "Note")
        default: description = String(localized: "Action")
        }
        textView.setAccessibilityHelp(String(format: String(localized: "Current screenplay element: %@"), description))
    }

    final class Coordinator: NSObject, NSTextViewDelegate, ScreenplayTextViewCommandHandler {
        private var text: Binding<String>
        var parent: TextKitScreenplayEditorView
        private weak var textView: NSTextView?
        var selectedRange = NSRange(location: 0, length: 0)
        var lastAppliedNavigationRange: NSRange?

        init(text: Binding<String>, parent: TextKitScreenplayEditorView) {
            self.text = text
            self.parent = parent
        }

        func attach(_ textView: NSTextView) { self.textView = textView }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            selectedRange = textView.selectedRange()
            text.wrappedValue = textView.string
            parent.onTextChanged(selectedRange.location)
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            selectedRange = TextKitScreenplayEditorView.graphemeSafeRange(textView.selectedRange(), in: textView.string)
            parent.onSelectionChanged(selectedRange.location)
        }

        func moveSuggestion(by offset: Int) -> Bool { parent.onSuggestionMove(offset) }
        func acceptSuggestion() -> Bool { parent.onSuggestionAccept() }
        func dismissSuggestions() -> Bool { parent.onSuggestionDismiss() }

        func performSmartEnter(in textView: NSTextView) -> Bool {
            performCommand(named: String(localized: "Smart Enter"), in: textView) { [weak self] location in self?.parent.onSmartEnter(location) }
        }

        func performTabCycle(in textView: NSTextView) -> Bool {
            performCommand(named: String(localized: "Change Element Type"), in: textView) { [weak self] location in self?.parent.onTabCycle(location) }
        }

        private func performCommand(named name: String, in textView: NSTextView, action: @escaping (Int) -> Void) -> Bool {
            let beforeText = textView.string
            let beforeSelection = textView.selectedRange()
            action(beforeSelection.location)
            DispatchQueue.main.async { [weak self, weak textView] in
                guard let self, let textView else { return }
                let afterText = self.text.wrappedValue
                guard beforeText != afterText else { return }
                textView.undoManager?.registerUndo(withTarget: self) { target in
                    MainActor.assumeIsolated {
                        target.restore(text: beforeText, selection: beforeSelection, actionName: name)
                    }
                }
                textView.undoManager?.setActionName(name)
            }
            return true
        }

        private func restore(text restoredText: String, selection: NSRange, actionName: String) {
            let currentText = text.wrappedValue
            let currentSelection = selectedRange
            textView?.undoManager?.registerUndo(withTarget: self) { target in
                MainActor.assumeIsolated {
                    target.restore(text: currentText, selection: currentSelection, actionName: actionName)
                }
            }
            textView?.undoManager?.setActionName(actionName)
            text.wrappedValue = restoredText
            selectedRange = TextKitScreenplayEditorView.graphemeSafeRange(selection, in: restoredText)
            textView?.string = restoredText
            textView?.setSelectedRange(selectedRange)
            parent.onTextChanged(selectedRange.location)
        }
    }
}

@MainActor
protocol ScreenplayTextViewCommandHandler: AnyObject {
    func moveSuggestion(by offset: Int) -> Bool
    func acceptSuggestion() -> Bool
    func dismissSuggestions() -> Bool
    func performSmartEnter(in textView: NSTextView) -> Bool
    func performTabCycle(in textView: NSTextView) -> Bool
}

final class ScreenplayTextView: NSTextView {
    weak var commandHandler: ScreenplayTextViewCommandHandler?

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 125: if commandHandler?.moveSuggestion(by: 1) == true { return }
        case 126: if commandHandler?.moveSuggestion(by: -1) == true { return }
        case 53: if commandHandler?.dismissSuggestions() == true { return }
        case 36, 76:
            if commandHandler?.acceptSuggestion() == true { return }
            if commandHandler?.performSmartEnter(in: self) == true { return }
        case 48:
            if commandHandler?.acceptSuggestion() == true { return }
            if commandHandler?.performTabCycle(in: self) == true { return }
        default: break
        }
        super.keyDown(with: event)
    }

    override func paste(_ sender: Any?) {
        guard let value = NSPasteboard.general.string(forType: .string) else { return super.paste(sender) }
        insertText(TextKitScreenplayEditorView.normalizedPaste(value), replacementRange: selectedRange())
    }

    override func copy(_ sender: Any?) {
        let range = semanticBlockRange(for: selectedRange())
        guard range.length > 0 else { return super.copy(sender) }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString((string as NSString).substring(with: range), forType: .string)
    }

    override func cut(_ sender: Any?) {
        let range = semanticBlockRange(for: selectedRange())
        guard range.length > 0 else { return super.cut(sender) }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString((string as NSString).substring(with: range), forType: .string)
        insertText("", replacementRange: range)
    }

    private func semanticBlockRange(for selection: NSRange) -> NSRange {
        selection.length > 0 ? (string as NSString).paragraphRange(for: selection) : selection
    }
}
