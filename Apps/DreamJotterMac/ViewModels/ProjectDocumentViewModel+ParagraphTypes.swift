import DreamJotterCore
import Foundation

extension ProjectDocumentViewModel {
    func paragraphSelection(at cursorLocation: Int) -> ScreenplayParagraphSelection {
        ScreenplayParagraphTypeControl.selection(
            in: scriptText,
            cursorLocation: cursorLocation
        )
    }

    mutating func setParagraphType(
        _ type: ScreenplayParagraphType,
        at cursorLocation: Int
    ) {
        let replacement = ScreenplayParagraphTypeControl.replacingCurrentParagraph(
            in: scriptText,
            cursorLocation: cursorLocation,
            with: type
        )
        updateScriptTextRespectingLanguage(replacement.text)
        requestEditorCursorNavigation(to: replacement.cursorLocation)
        refreshEditorSuggestions(cursorLocation: replacement.cursorLocation)
    }
}
