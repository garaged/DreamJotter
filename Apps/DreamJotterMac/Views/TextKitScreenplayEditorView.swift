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
        textView.commandHandler = context.coordinator
        context.coordinator.updateClosures(
            onSmartEnter: onSmartEnter,
            onTabCycle: onTabCycle,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onNavigationApplied: onNavigationApplied
        )

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
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
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
            let composed = source.rangeOfComposedCharacterSequence(at: location)
            return NSRange(location: composed.location, length: 0)
        }
        return source.rangeOfComposedCharacterSequences(for: bounded)
    }

    nonisolated static func normalizedPaste(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{2028}", with: "\n")
            .replacingOccurrences(of: "\u{2029}", with: "\n")
    }

    private func applyNavigationIfNeeded(to textView: NSTextView, context: Context) {
        guard let targetRange = navigationState.scrollTarget?.textRange else { return }
        let range = Self.graphemeSafeRange(
            NSRange(location: targetRange.location, length: targetRange.length),
            in: textView.string
        )
        guard context.coordinator.lastAppliedNavigationRange != range else { return }
        context.coordinator.lastAppliedNavigationRange = range
        context.coordinator.selectedRange = range
        textView.setSelectedRange(range)
        textView.scrollRangeToVisible(range)
        onNavigationApplied()
    }

    private func applyStyles(to textView: NSTextView) {
        guard !textView.hasMarkedText(), let storage = textView.textStorage else { return }
        let fullRange = NSRange(location: 0, length: (textView.string as NSString).length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        storage.setAttributes([
            .font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular),
            .foregroundColor: NSColor.textColor,
            .paragraphStyle: paragraph
        ], range: fullRange)

        for run in styleRuns {
            let range = Self.graphemeSafeRange(
                NSRange(location: run.textRange.location, length: run.textRange.length),
                in: textView.string
            )
            guard range.length > 0 else { continue }
            switch run.kind {
            case .sceneHeading:
                storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .bold), .foregroundColor: NSColor.controlAccentColor], range: range)
            case .characterCue:
                storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold)], range: range)
            case .dialogue:
                storage.addAttributes([.foregroundColor: NSColor.labelColor], range: range)
            case .parenthetical:
                storage.addAttributes([.foregroundColor: NSColor.secondaryLabelColor], range: range)
            case .transition:
                storage.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .semibold), .foregroundColor: NSColor.secondaryLabelColor], range: range)
            case .noteReference:
                storage.addAttributes([.foregroundColor: NSColor.systemOrange], range: range)
            default:
                break
            }
        }
    }

    private func updateAccessibility(for textView: NSTextView, coordinator: Coordinator) {
        let location = min(coordinator.selectedRange.location, (textView.string as NSString).length)
        let kind = styleRuns.first { run in
            NSLocationInRange(location, NSRange(location: run.textRange.location, length: max(run.textRange.length, 1)))
        }?.kind
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
        textView.setAccessibilityHelp(
            String(
                format: String(localized: "Current screenplay element: %@"),
                description
            )
        )
    }

    final class Coordinator: NSObject, NSTextViewDelegate, ScreenplayTextViewCommandHandler {
        private var text: Binding<String>
        private var onSmartEnter: (Int) -> Void
        private var onTabCycle: (Int) -> Void
        private var onTextChanged: (Int) -> Void
        private var onSelectionChanged: (Int) -> Void
        private var onNavigationApplied: () -> Void
        private weak var textView: NSTextView?
        var selectedRange = NSRange(location: 0, length: 0)
        var lastAppliedNavigationRange: NSRange?

        init(text: Binding<String>, onSmartEnter: @escaping (Int) -> Void, onTabCycle: @escaping (Int) -> Void, onTextChanged: @escaping (Int) -> Void, onSelectionChanged: @escaping (Int) -> Void, onNavigationApplied: @escaping () -> Void) {
            self.text = text
            self.onSmartEnter = onSmartEnter
            self.onTabCycle = onTabCycle
            self.onTextChanged = onTextChanged
            self.onSelectionChanged = onSelectionChanged
            self.onNavigationApplied = onNavigationApplied
        }

        func attach(_ textView: NSTextView) { self.textView = textView }

        func updateClosures(onSmartEnter: @escaping (Int) -> Void, onTabCycle: @escaping (Int) -> Void, onTextChanged: @escaping (Int) -> Void, onSelectionChanged: @escaping (Int) -> Void, onNavigationApplied: @escaping () -> Void) {
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
            selectedRange = TextKitScreenplayEditorView.graphemeSafeRange(textView.selectedRange(), in: textView.string)
            onSelectionChanged(selectedRange.location)
        }

        func performSmartEnter(in textView: NSTextView) -> Bool {
            performCommand(named: String(localized: "Smart Enter"), in: textView) { [weak self] location in
                self?.onSmartEnter(location)
            }
        }

        func performTabCycle(in textView: NSTextView) -> Bool {
            performCommand(
                    named: String(localized: "Change Element Type"),
                    in: textView
                    ) { [weak self] location in
                self?.onTabCycle(location)
            }
        }

        private func performCommand(named name: String, in textView: NSTextView, action: @escaping (Int) -> Void) -> Bool {
            let beforeText = textView.string
            let beforeSelection = textView.selectedRange()
            action(beforeSelection.location)
            DispatchQueue.main.async { [weak self, weak textView] in
                guard let self, let textView else { return }
                let afterText = self.text.wrappedValue
                let afterSelection = TextKitScreenplayEditorView.graphemeSafeRange(self.selectedRange, in: afterText)
                guard beforeText != afterText else { return }
                textView.undoManager?.registerUndo(withTarget: self) { target in
                    target.restore(text: beforeText, selection: beforeSelection, actionName: name)
                }
                textView.undoManager?.setActionName(name)
                self.selectedRange = afterSelection
            }
            return true
        }

        private func restore(text restoredText: String, selection: NSRange, actionName: String) {
            let currentText = text.wrappedValue
            let currentSelection = selectedRange
            textView?.undoManager?.registerUndo(withTarget: self) { target in
                target.restore(text: currentText, selection: currentSelection, actionName: actionName)
            }
            textView?.undoManager?.setActionName(actionName)
            text.wrappedValue = restoredText
            selectedRange = TextKitScreenplayEditorView.graphemeSafeRange(selection, in: restoredText)
            textView?.string = restoredText
            textView?.setSelectedRange(selectedRange)
            onTextChanged(selectedRange.location)
        }
    }
}

@MainActor
protocol ScreenplayTextViewCommandHandler: AnyObject {
    func performSmartEnter(in textView: NSTextView) -> Bool
    func performTabCycle(in textView: NSTextView) -> Bool
}

final class ScreenplayTextView: NSTextView {
    weak var commandHandler: ScreenplayTextViewCommandHandler?

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 || event.keyCode == 76, commandHandler?.performSmartEnter(in: self) == true { return }
        if event.keyCode == 48, commandHandler?.performTabCycle(in: self) == true { return }
        super.keyDown(with: event)
    }

    override func paste(_ sender: Any?) {
        guard let value = NSPasteboard.general.string(forType: .string) else {
            super.paste(sender)
            return
        }
        let normalized = TextKitScreenplayEditorView.normalizedPaste(value)
        insertText(normalized, replacementRange: selectedRange())
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
        guard selection.length > 0 else { return selection }
        return (string as NSString).paragraphRange(for: selection)
    }
}
