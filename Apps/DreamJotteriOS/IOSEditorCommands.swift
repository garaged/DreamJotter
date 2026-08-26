import DreamJotterCore
import Foundation

public enum IOSEditorCommandService {
    @discardableResult
    public static func performSmartEnter(
        session: inout IOSEditorSession,
        mode: EditorMode = .simple
    ) -> IOSEditorRevision {
        let cursor = session.selection.location
        let line = EditorUsabilityService.currentLine(in: session.text, cursorLocation: cursor)
        let kind = EditorUsabilityService.lineKind(for: line.text)
        let insertion = EditorUsabilityService.smartEnterInsertion(after: kind, mode: mode)
        let nextText = EditorUsabilityService.replacing(
            range: EditorTextRange(location: cursor, length: session.selection.length),
            in: session.text,
            with: insertion
        )
        return session.applyTextChange(
            replacementText: nextText,
            selection: IOSEditorSelection(
                location: cursor + (insertion as NSString).length,
                length: 0
            ),
            kind: .smartEnter
        )
    }

    @discardableResult
    public static func cycleCurrentElementKind(
        session: inout IOSEditorSession
    ) -> IOSEditorRevision {
        let cursor = session.selection.location
        let line = EditorUsabilityService.currentLine(in: session.text, cursorLocation: cursor)
        let currentKind = EditorUsabilityService.lineKind(for: line.text)
        let cycled = EditorUsabilityService.tabCycledLineText(
            line.text,
            currentKind: currentKind
        )
        let nextText = EditorUsabilityService.replacing(
            range: line.range,
            in: session.text,
            with: cycled.text
        )
        return session.applyTextChange(
            replacementText: nextText,
            selection: IOSEditorSelection(
                location: line.range.location + (cycled.text as NSString).length,
                length: 0
            ),
            kind: .elementFormatting
        )
    }

    @discardableResult
    public static func acceptSuggestion(
        _ suggestion: EditorSuggestion,
        session: inout IOSEditorSession
    ) -> IOSEditorRevision {
        let nextText = EditorUsabilityService.replacing(
            range: suggestion.textRange,
            in: session.text,
            with: suggestion.replacementText
        )
        return session.applyTextChange(
            replacementText: nextText,
            selection: IOSEditorSelection(
                location: suggestion.textRange.location + (suggestion.replacementText as NSString).length,
                length: 0
            ),
            kind: .suggestionAcceptance
        )
    }
}
