import DreamJotterCore
import Foundation

public struct IOSEditorClipboardPayload: Equatable, Sendable {
    public let plainText: String
    public let selection: IOSEditorSelection

    public init(plainText: String, selection: IOSEditorSelection) {
        self.plainText = plainText
        self.selection = selection
    }
}

public enum IOSEditorClipboardService {
    public static func graphemeSafeSelection(
        _ selection: IOSEditorSelection,
        in text: String
    ) -> IOSEditorSelection {
        let nsText = text as NSString
        let clamped = selection.clamped(to: text)
        guard clamped.length > 0 else { return clamped }
        let range = nsText.rangeOfComposedCharacterSequences(
            for: NSRange(location: clamped.location, length: clamped.length)
        )
        return IOSEditorSelection(location: range.location, length: range.length)
    }

    public static func semanticSelection(
        _ selection: IOSEditorSelection,
        in text: String
    ) -> IOSEditorSelection {
        let safe = graphemeSafeSelection(selection, in: text)
        guard safe.length > 0 else { return safe }
        let nsText = text as NSString
        let lineRange = nsText.lineRange(
            for: NSRange(location: safe.location, length: safe.length)
        )
        return IOSEditorSelection(location: lineRange.location, length: lineRange.length)
            .clamped(to: text)
    }

    public static func copyPayload(
        from session: IOSEditorSession,
        expandToSemanticBlocks: Bool = true
    ) -> IOSEditorClipboardPayload? {
        let selection = expandToSemanticBlocks
            ? semanticSelection(session.selection, in: session.text)
            : graphemeSafeSelection(session.selection, in: session.text)
        guard selection.length > 0 else { return nil }
        let text = (session.text as NSString).substring(with: selection.textRange.nsRange)
        return IOSEditorClipboardPayload(plainText: text, selection: selection)
    }

    @discardableResult
    public static func cut(
        session: inout IOSEditorSession,
        expandToSemanticBlocks: Bool = true
    ) -> IOSEditorClipboardPayload? {
        guard let payload = copyPayload(
            from: session,
            expandToSemanticBlocks: expandToSemanticBlocks
        ) else { return nil }
        let replacement = EditorUsabilityService.replacing(
            range: payload.selection.textRange,
            in: session.text,
            with: ""
        )
        session.applyTextChange(
            replacementText: replacement,
            selection: IOSEditorSelection(location: payload.selection.location, length: 0),
            kind: .cut
        )
        return payload
    }
}

private extension EditorTextRange {
    var nsRange: NSRange {
        NSRange(location: location, length: length)
    }
}
