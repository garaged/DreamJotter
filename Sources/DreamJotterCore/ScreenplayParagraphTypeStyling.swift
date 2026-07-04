import Foundation

public extension ScreenplayParagraphTypeControl {
    static func styleRuns(in text: String) -> [EditorLineStyleRun] {
        ScreenplayParagraphTypeEngine.paragraphs(in: text).compactMap { paragraph in
            guard paragraph.textRange.length > 0, paragraph.type != .unknown else {
                return nil
            }
            return EditorLineStyleRun(
                kind: paragraph.type.elementKind,
                textRange: paragraph.textRange
            )
        }
    }
}
