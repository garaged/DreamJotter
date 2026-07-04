import Foundation

public struct ScreenplayParagraphSelection: Equatable, Sendable {
    public let type: ScreenplayParagraphType
    public let textRange: EditorTextRange
    public let sourceText: String

    public init(type: ScreenplayParagraphType, textRange: EditorTextRange, sourceText: String) {
        self.type = type
        self.textRange = textRange
        self.sourceText = sourceText
    }
}

public enum ScreenplayParagraphTypeControl {
    public static let editableTypes: [ScreenplayParagraphType] = [
        .sceneHeading,
        .action,
        .characterIntroduction,
        .characterCue,
        .dialogue,
        .parenthetical,
        .transition,
        .shot,
        .section,
        .synopsis,
        .montage,
        .note,
        .pageBreak
    ]

    public static func selection(in text: String, cursorLocation: Int) -> ScreenplayParagraphSelection {
        let paragraph = ScreenplayParagraphTypeEngine.paragraph(in: text, at: cursorLocation)
        return ScreenplayParagraphSelection(
            type: paragraph.type,
            textRange: paragraph.textRange,
            sourceText: paragraph.sourceText
        )
    }

    public static func replacingCurrentParagraph(
        in text: String,
        cursorLocation: Int,
        with type: ScreenplayParagraphType
    ) -> (text: String, cursorLocation: Int) {
        let selection = selection(in: text, cursorLocation: cursorLocation)
        let replacement = sourceText(selection.sourceText, markedAs: type)
        let updated = EditorUsabilityService.replacing(
            range: selection.textRange,
            in: text,
            with: replacement
        )
        let cursor = selection.textRange.location + min(
            max(0, cursorLocation - selection.textRange.location),
            (replacement as NSString).length
        )
        return (updated, cursor)
    }

    public static func paragraphType(for sourceText: String) -> ScreenplayParagraphType {
        ScreenplayParagraphTypeEngine.type(for: sourceText)
    }

    public static func sourceText(_ sourceText: String, markedAs type: ScreenplayParagraphType) -> String {
        let plain = plainText(sourceText)
        switch type {
        case .sceneHeading: return ". \(plain)"
        case .action: return "! \(plain)"
        case .characterIntroduction: return "+ \(plain)"
        case .characterCue: return "@\(plain.uppercased())"
        case .dialogue: return ": \(plain)"
        case .parenthetical:
            return "(\(plain.trimmingCharacters(in: CharacterSet(charactersIn: "()"))))"
        case .transition: return "> \(plain.uppercased())"
        case .shot: return "!! \(plain.uppercased())"
        case .section: return "# \(plain)"
        case .synopsis: return "= \(plain)"
        case .montage: return "%% \(plain)"
        case .note: return "[[\(plain)]]"
        case .pageBreak: return "==="
        case .titlePage, .unknown: return plain
        }
    }

    public static func displayName(for type: ScreenplayParagraphType) -> String {
        switch type {
        case .sceneHeading: "Scene Heading"
        case .action: "Action"
        case .characterCue: "Character Cue"
        case .dialogue: "Dialogue"
        case .parenthetical: "Parenthetical"
        case .transition: "Transition"
        case .shot: "Shot"
        case .section: "Section"
        case .synopsis: "Synopsis"
        case .montage: "Montage"
        case .characterIntroduction: "Character Introduction"
        case .note: "Note"
        case .pageBreak: "Page Break"
        case .titlePage: "Title Page"
        case .unknown: "Unknown"
        }
    }

    public static func description(for type: ScreenplayParagraphType) -> String {
        switch type {
        case .sceneHeading: "Starts a scene and uses slugline formatting."
        case .action: "Full-width visual action or description."
        case .characterIntroduction: "Full-width action that introduces a character."
        case .characterCue: "Names the speaker for the following contiguous dialogue block."
        case .dialogue: "Spoken text in the dialogue column. A blank line ends the dialogue block."
        case .parenthetical: "A brief performance direction inside a dialogue block."
        case .transition: "A right-aligned editorial transition."
        case .shot: "A camera or shot instruction."
        case .section: "A structural script section heading."
        case .synopsis: "A non-screenplay summary paragraph."
        case .montage: "A structural montage heading or description."
        case .note: "An internal writing note."
        case .pageBreak: "Forces the next element onto a new page."
        case .titlePage: "Title-page metadata."
        case .unknown: "Text whose semantic type is not yet known."
        }
    }

    private static func plainText(_ sourceText: String) -> String {
        var value = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        if value == "===" { return "" }
        if value.hasPrefix("[["), value.hasSuffix("]]" ) {
            return String(value.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
        }
        for marker in ["%%", "!!", "+", ":", "@", ">", "#", "=", "!", "."] where value.hasPrefix(marker) {
            value = String(value.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
            break
        }
        if value.hasPrefix("("), value.hasSuffix(")") {
            value = String(value.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
        }
        return value
    }
}
