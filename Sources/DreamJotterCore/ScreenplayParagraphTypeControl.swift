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
        let range = paragraphRange(in: text, cursorLocation: cursorLocation)
        let source = substring(in: text, range: range)
        return ScreenplayParagraphSelection(
            type: paragraphType(for: source),
            textRange: range,
            sourceText: source
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
        let trimmed = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown }

        if trimmed == "===" { return .pageBreak }
        if trimmed.hasPrefix("[["), trimmed.hasSuffix("]]" ) { return .note }
        if trimmed.hasPrefix("%%") { return .montage }
        if trimmed.hasPrefix("!!") { return .shot }
        if trimmed.hasPrefix("+") { return .characterIntroduction }
        if trimmed.hasPrefix(":") { return .dialogue }
        if trimmed.hasPrefix("@") { return .characterCue }
        if trimmed.hasPrefix(">") { return .transition }
        if trimmed.hasPrefix("#") { return .section }
        if trimmed.hasPrefix("=") { return .synopsis }
        if trimmed.hasPrefix("!") { return .action }
        if trimmed.hasPrefix(".") { return .sceneHeading }
        if trimmed.hasPrefix("("), trimmed.hasSuffix(")") { return .parenthetical }

        let parsed = ScreenplayParser.parse(trimmed)
        return parsed.elements.first?.paragraphType ?? .unknown
    }

    public static func sourceText(_ sourceText: String, markedAs type: ScreenplayParagraphType) -> String {
        let plain = plainText(sourceText)
        switch type {
        case .sceneHeading:
            return ". \(plain)"
        case .action:
            return "! \(plain)"
        case .characterIntroduction:
            return "+ \(plain)"
        case .characterCue:
            return "@\(plain.uppercased())"
        case .dialogue:
            return ": \(plain)"
        case .parenthetical:
            return "(\(plain.trimmingCharacters(in: CharacterSet(charactersIn: "()"))))"
        case .transition:
            return "> \(plain.uppercased())"
        case .shot:
            return "!! \(plain.uppercased())"
        case .section:
            return "# \(plain)"
        case .synopsis:
            return "= \(plain)"
        case .montage:
            return "%% \(plain)"
        case .note:
            return "[[\(plain)]]"
        case .pageBreak:
            return "==="
        case .titlePage, .unknown:
            return plain
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
        case .characterCue: "Names the speaker for the following dialogue block."
        case .dialogue: "Spoken text in the dialogue column."
        case .parenthetical: "A brief performance direction inside dialogue."
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

    private static func paragraphRange(in text: String, cursorLocation: Int) -> EditorTextRange {
        let source = text as NSString
        let safeLocation = min(max(0, cursorLocation), source.length)
        var start = safeLocation
        var end = safeLocation

        while start > 0 {
            let searchRange = NSRange(location: 0, length: start)
            let separator = source.range(of: "\n\n", options: .backwards, range: searchRange)
            if separator.location == NSNotFound {
                start = 0
            } else {
                start = separator.location + separator.length
            }
            break
        }

        if end < source.length {
            let separator = source.range(
                of: "\n\n",
                options: [],
                range: NSRange(location: end, length: source.length - end)
            )
            end = separator.location == NSNotFound ? source.length : separator.location
        }

        return EditorTextRange(location: start, length: max(0, end - start))
    }

    private static func substring(in text: String, range: EditorTextRange) -> String {
        let source = text as NSString
        let safeLocation = min(range.location, source.length)
        let safeLength = min(range.length, source.length - safeLocation)
        return source.substring(with: NSRange(location: safeLocation, length: safeLength))
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
