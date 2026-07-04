import Foundation

public struct ScreenplaySourceParagraph: Equatable, Sendable {
    public let sourceText: String
    public let textRange: EditorTextRange
    public let type: ScreenplayParagraphType
    public let isExplicit: Bool

    public init(
        sourceText: String,
        textRange: EditorTextRange,
        type: ScreenplayParagraphType,
        isExplicit: Bool
    ) {
        self.sourceText = sourceText
        self.textRange = textRange
        self.type = type
        self.isExplicit = isExplicit
    }
}

/// Canonical paragraph-boundary and type resolution shared by the editor and parser.
///
/// Explicit markers always win. Inference is intentionally conservative: ambiguous
/// text is action, while dialogue context is limited to one contiguous paragraph
/// block and can never cross a completed dialogue block into later action prose.
public enum ScreenplayParagraphTypeEngine {
    public static func paragraphs(in source: String) -> [ScreenplaySourceParagraph] {
        let normalized = normalizedNewlines(source)
        let text = normalized as NSString
        guard text.length > 0 else { return [] }

        let separator = try? NSRegularExpression(pattern: #"\n[\t ]*\n(?:[\t ]*\n)*"#)
        let matches = separator?.matches(
            in: normalized,
            range: NSRange(location: 0, length: text.length)
        ) ?? []

        var result: [ScreenplaySourceParagraph] = []
        var location = 0
        for match in matches {
            appendParagraph(from: text, range: NSRange(
                location: location,
                length: max(0, match.range.location - location)
            ), to: &result)
            location = match.range.location + match.range.length
        }
        appendParagraph(
            from: text,
            range: NSRange(location: location, length: max(0, text.length - location)),
            to: &result
        )
        return result
    }

    public static func paragraph(in source: String, at cursorLocation: Int) -> ScreenplaySourceParagraph {
        let normalized = normalizedNewlines(source)
        let length = (normalized as NSString).length
        let safeLocation = min(max(0, cursorLocation), length)
        let paragraphs = paragraphs(in: normalized)

        if let containing = paragraphs.first(where: { paragraph in
            let range = NSRange(
                location: paragraph.textRange.location,
                length: max(1, paragraph.textRange.length)
            )
            return NSLocationInRange(safeLocation, range)
                || safeLocation == paragraph.textRange.location + paragraph.textRange.length
        }) {
            return containing
        }

        return ScreenplaySourceParagraph(
            sourceText: "",
            textRange: EditorTextRange(location: safeLocation, length: 0),
            type: .unknown,
            isExplicit: false
        )
    }

    public static func type(for sourceText: String) -> ScreenplayParagraphType {
        let trimmed = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown }
        if let explicit = explicitType(for: trimmed) { return explicit }
        if looksLikeSceneHeading(trimmed) { return .sceneHeading }
        if looksLikeTransition(trimmed) { return .transition }
        if looksLikeShot(trimmed) { return .shot }
        if trimmed.hasPrefix("("), trimmed.hasSuffix(")") { return .parenthetical }
        return .action
    }

    /// Produces parser input with an explicit action marker only where a completed
    /// dialogue block could otherwise leak into the following unmarked paragraph.
    /// The inserted marker is parser-only and is never written back to editor text.
    public static func parserSafeSource(_ source: String) -> String {
        let normalized = normalizedNewlines(source)
        let sourceParagraphs = paragraphs(in: normalized)
        guard !sourceParagraphs.isEmpty else { return normalized }

        var insertions: [Int] = []
        var expectsDetachedDialogue = false
        var previousCompletedDialogue = false

        for index in sourceParagraphs.indices {
            let paragraph = sourceParagraphs[index]
            let text = paragraph.sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
            let nextText = index + 1 < sourceParagraphs.count
                ? sourceParagraphs[index + 1].sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil

            if expectsDetachedDialogue {
                if paragraph.type == .parenthetical {
                    expectsDetachedDialogue = nextText.map(isPlausibleDialogue) ?? false
                    previousCompletedDialogue = !expectsDetachedDialogue
                } else {
                    expectsDetachedDialogue = false
                    previousCompletedDialogue = true
                }
                continue
            }

            if isDialogueBlock(text, nextParagraph: nextText) {
                let lines = nonEmptyLines(in: text)
                if lines.count == 1, let nextText, isPlausibleDialogue(nextText) {
                    expectsDetachedDialogue = true
                    previousCompletedDialogue = false
                } else {
                    previousCompletedDialogue = true
                }
                continue
            }

            if previousCompletedDialogue,
               explicitType(for: text) == nil,
               !looksLikeSceneHeading(text),
               !looksLikeTransition(text),
               !looksLikeShot(text),
               !isUppercaseLike(text) {
                insertions.append(paragraph.textRange.location)
            }

            previousCompletedDialogue = false
        }

        guard !insertions.isEmpty else { return normalized }
        let mutable = NSMutableString(string: normalized)
        for location in insertions.sorted(by: >) {
            mutable.insert("! ", at: location)
        }
        return mutable as String
    }

    public static func explicitType(for sourceText: String) -> ScreenplayParagraphType? {
        let trimmed = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "===" { return .pageBreak }
        if trimmed.hasPrefix("[["), trimmed.hasSuffix("]]" ) { return .note }
        if trimmed.hasPrefix("%%") { return .montage }
        if trimmed.hasPrefix("!!") { return .shot }
        if trimmed.hasPrefix("+") { return .characterIntroduction }
        if trimmed.hasPrefix(":") { return .dialogue }
        if trimmed.hasPrefix("@") { return .characterCue }
        if trimmed.hasPrefix(">") { return .transition }
        if trimmed.hasPrefix("#") { return .section }
        if trimmed.hasPrefix("="), trimmed != "===" { return .synopsis }
        if trimmed.hasPrefix("!") { return .action }
        if trimmed.hasPrefix(".") { return .sceneHeading }
        return nil
    }

    private static func appendParagraph(
        from source: NSString,
        range: NSRange,
        to result: inout [ScreenplaySourceParagraph]
    ) {
        guard range.length > 0 else { return }
        let value = source.substring(with: range)
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let explicit = explicitType(for: value)
        result.append(ScreenplaySourceParagraph(
            sourceText: value,
            textRange: EditorTextRange(location: range.location, length: range.length),
            type: explicit ?? type(for: value),
            isExplicit: explicit != nil
        ))
    }

    private static func normalizedNewlines(_ source: String) -> String {
        source
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{2028}", with: "\n")
            .replacingOccurrences(of: "\u{2029}", with: "\n")
    }

    private static func looksLikeSceneHeading(_ text: String) -> Bool {
        text.range(
            of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.|INT/EXT\.|EXT/INT\.|I/E\.)\s+.+"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    private static func looksLikeTransition(_ text: String) -> Bool {
        let value = text.uppercased()
        return value.hasSuffix(" TO:")
            || value == "CUT TO:"
            || value == "CORTE A:"
            || value == "FADE OUT."
            || value == "FUNDIDO A NEGRO."
    }

    private static func looksLikeShot(_ text: String) -> Bool {
        let value = text.uppercased()
        return ["CLOSE ON:", "ANGLE ON:", "WIDE SHOT:", "INSERT:"].contains(value)
    }

    private static func isDialogueBlock(_ text: String, nextParagraph: String?) -> Bool {
        if explicitType(for: text) == .dialogue { return true }
        let lines = nonEmptyLines(in: text)
        guard let first = lines.first else { return false }
        let following = lines.dropFirst().first ?? nextParagraph
        return looksLikeCharacterCue(first, nextLine: following)
    }

    private static func looksLikeCharacterCue(_ line: String, nextLine: String?) -> Bool {
        guard isUppercaseLike(line),
              line.split(whereSeparator: \.isWhitespace).count <= 3,
              let nextLine else { return false }
        return isPlausibleDialogue(nextLine)
    }

    private static func isPlausibleDialogue(_ text: String) -> Bool {
        let first = nonEmptyLines(in: text).first ?? text
        guard !first.isEmpty,
              !looksLikeSceneHeading(first),
              !looksLikeTransition(first),
              !looksLikeShot(first) else { return false }
        if first.hasPrefix("(") || first.hasPrefix(":") { return true }
        return !isUppercaseLike(first) && first.count <= 240
    }

    private static func nonEmptyLines(in text: String) -> [String] {
        text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private static func isUppercaseLike(_ line: String) -> Bool {
        let letters = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        return !letters.isEmpty && line == line.uppercased()
    }
}
