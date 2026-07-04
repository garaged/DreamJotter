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
/// block and can never cross a blank line.
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

    /// Produces parser input whose paragraph starts carry enough explicit semantics
    /// to prevent legacy cue state from leaking across blank paragraph boundaries.
    /// The returned markers are parser-only and are not written back to editor text.
    public static func parserSafeSource(_ source: String) -> String {
        let normalized = normalizedNewlines(source)
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard !lines.isEmpty else { return normalized }

        var output: [String] = []
        var paragraphStart = true
        var index = 0
        var titlePageCandidate = true

        while index < lines.count {
            let raw = lines[index]
            let trimmed = raw.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                output.append(raw)
                paragraphStart = true
                titlePageCandidate = false
                index += 1
                continue
            }

            if titlePageCandidate, looksLikeTitlePageField(trimmed) {
                output.append(raw)
                paragraphStart = false
                index += 1
                continue
            }
            titlePageCandidate = false

            guard paragraphStart else {
                output.append(raw)
                index += 1
                continue
            }

            let nextLine = nextLineInSameParagraph(after: index, lines: lines)
            if hasExplicitMarker(trimmed)
                || looksLikeSceneHeading(trimmed)
                || looksLikeTransition(trimmed)
                || looksLikeShot(trimmed)
                || looksLikeCharacterCue(trimmed, nextLine: nextLine) {
                output.append(raw)
            } else {
                let indentation = String(raw.prefix { $0 == " " || $0 == "\t" })
                output.append("\(indentation)! \(trimmed)")
            }

            paragraphStart = false
            index += 1
        }

        return output.joined(separator: "\n")
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

    private static func hasExplicitMarker(_ line: String) -> Bool {
        explicitType(for: line) != nil
    }

    private static func looksLikeTitlePageField(_ line: String) -> Bool {
        line.range(of: #"^[\p{L}][\p{L} ]*:"#, options: .regularExpression) != nil
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

    private static func looksLikeCharacterCue(_ line: String, nextLine: String?) -> Bool {
        guard isUppercaseLike(line),
              line.split(whereSeparator: \.isWhitespace).count <= 3,
              let nextLine else { return false }
        let next = nextLine.trimmingCharacters(in: .whitespaces)
        guard !next.isEmpty,
              !looksLikeSceneHeading(next),
              !looksLikeTransition(next),
              !looksLikeShot(next) else { return false }
        if next.hasPrefix("(") || next.hasPrefix(":") { return true }
        return !isUppercaseLike(next) && next.count <= 240
    }

    private static func isUppercaseLike(_ line: String) -> Bool {
        let letters = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        return !letters.isEmpty && line == line.uppercased()
    }

    private static func nextLineInSameParagraph(after index: Int, lines: [String]) -> String? {
        let next = index + 1
        guard next < lines.count else { return nil }
        let value = lines[next]
        return value.trimmingCharacters(in: .whitespaces).isEmpty ? nil : value
    }
}
