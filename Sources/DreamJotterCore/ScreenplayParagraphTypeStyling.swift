import Foundation

public extension ScreenplayParagraphTypeControl {
    static func styleRuns(in text: String) -> [EditorLineStyleRun] {
        let source = text as NSString
        guard source.length > 0 else { return [] }

        var results: [EditorLineStyleRun] = []
        var location = 0
        while location < source.length {
            let separator = source.range(
                of: "\n\n",
                options: [],
                range: NSRange(location: location, length: source.length - location)
            )
            let end = separator.location == NSNotFound ? source.length : separator.location
            let range = NSRange(location: location, length: max(0, end - location))
            let paragraph = source.substring(with: range)
            let type = paragraphType(for: paragraph)

            if range.length > 0, type != .unknown {
                results.append(EditorLineStyleRun(
                    kind: type.elementKind,
                    textRange: EditorTextRange(location: range.location, length: range.length)
                ))
            }

            if separator.location == NSNotFound { break }
            location = separator.location + separator.length
        }
        return results
    }
}
