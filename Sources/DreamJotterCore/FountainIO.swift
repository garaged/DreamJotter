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
        switch element.kind {
        case .noteReference:
            return "[[\(element.text)]]"
        case .pageBreak:
            return "==="
        case .section:
            return element.text.hasPrefix("#") ? element.text : "# \(element.text)"
        case .synopsis:
            return element.text.hasPrefix("=") ? element.text : "= \(element.text)"
        case .titlePage,
             .sceneHeading,
             .action,
             .parenthetical,
             .dialogue,
             .transition,
             .shot,
             .unknown:
            return element.text
        case .characterCue:
            return element.text == element.text.uppercased() ? element.text : "@\(element.text)"
        }
    }
}
