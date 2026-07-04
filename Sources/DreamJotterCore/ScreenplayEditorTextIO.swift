import Foundation

public enum ScreenplayEditorTextIO {
    public static func exportScreenplay(_ document: ScreenplayDocument) -> String {
        var output = ""

        for (index, element) in document.elements.enumerated() {
            let text = explicitText(for: element)
            guard !text.isEmpty else { continue }

            if !output.isEmpty {
                let previous = document.elements[index - 1]
                output += separator(after: previous, before: element)
            }
            output += text
        }

        return output
    }

    private static func separator(after previous: ScriptElement, before current: ScriptElement) -> String {
        if previous.paragraphType == .characterCue,
           current.paragraphType == .dialogue || current.paragraphType == .parenthetical {
            return "\n"
        }
        if previous.paragraphType == .parenthetical,
           current.paragraphType == .dialogue {
            return "\n"
        }
        return "\n\n"
    }

    private static func explicitText(for element: ScriptElement) -> String {
        switch element.paragraphType {
        case .sceneHeading:
            return ". \(element.text)"
        case .action:
            return "! \(element.text)"
        case .characterCue:
            return "@\(element.text)"
        case .dialogue:
            return ": \(element.text)"
        case .parenthetical:
            return element.text.hasPrefix("(") ? element.text : "(\(element.text))"
        case .transition:
            return "> \(element.text)"
        case .shot:
            return "!! \(element.text)"
        case .section:
            return "# \(element.text)"
        case .synopsis:
            return "= \(element.text)"
        case .montage:
            return "%% \(element.text)"
        case .characterIntroduction:
            return "+ \(element.text)"
        case .note:
            return "[[\(element.text)]]"
        case .pageBreak:
            return "==="
        case .titlePage, .unknown:
            return element.text
        }
    }
}
