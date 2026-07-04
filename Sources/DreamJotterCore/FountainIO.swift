import Foundation

public enum FountainIO {
    public static func importScreenplay(_ source: String) -> ScreenplayDocument {
        ScreenplayParser.parse(source)
    }

    public static func exportScreenplay(_ document: ScreenplayDocument) -> String {
        document.elements
            .map(exportText(for:))
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private static func exportText(for element: ScriptElement) -> String {
        switch element.paragraphType {
        case .sceneHeading:
            return ". \(element.text)"
        case .action:
            return "! \(element.text)"
        case .characterCue:
            return "@\(element.text.uppercased())"
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
