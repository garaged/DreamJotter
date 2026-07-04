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
        requestNavigation(toTextRange: EditorTextRange(
            location: replacement.cursorLocation,
            length: 0
        ))
        refreshEditorSuggestions(cursorLocation: replacement.cursorLocation)
    }
}
