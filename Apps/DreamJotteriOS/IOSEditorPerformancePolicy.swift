import DreamJotterCore
import Foundation

public struct IOSEditorFormattingWindow: Equatable, Sendable {
    public let range: EditorTextRange
    public let overscanUTF16Length: Int

    public init(range: EditorTextRange, overscanUTF16Length: Int) {
        self.range = range
        self.overscanUTF16Length = overscanUTF16Length
    }
}

public enum IOSEditorFormattingPolicy {
    public static func formattingWindow(
        visibleRange: EditorTextRange,
        text: String,
        overscanUTF16Length: Int = 4_096
    ) -> IOSEditorFormattingWindow {
        let textLength = (text as NSString).length
        let overscan = max(0, overscanUTF16Length)
        let start = max(0, visibleRange.location - overscan)
        let visibleEnd = min(textLength, visibleRange.location + visibleRange.length)
        let end = min(textLength, visibleEnd + overscan)
        return IOSEditorFormattingWindow(
            range: EditorTextRange(location: start, length: max(0, end - start)),
            overscanUTF16Length: overscan
        )
    }

    public static func boundedStyleRuns(
        text: String,
        visibleRange: EditorTextRange,
        overscanUTF16Length: Int = 4_096
    ) -> [EditorLineStyleRun] {
        let window = formattingWindow(
            visibleRange: visibleRange,
            text: text,
            overscanUTF16Length: overscanUTF16Length
        )
        guard window.range.length > 0 else { return [] }

        let nsText = text as NSString
        let requestedRange = NSRange(
            location: window.range.location,
            length: min(window.range.length, nsText.length - window.range.location)
        )
        let lineAlignedRange = nsText.lineRange(for: requestedRange)
        let contextStart: Int
        if lineAlignedRange.location > 0 {
            let previousCharacter = NSRange(location: lineAlignedRange.location - 1, length: 0)
            contextStart = nsText.lineRange(for: previousCharacter).location
        } else {
            contextStart = 0
        }
        let contextEnd = min(nsText.length, NSMaxRange(lineAlignedRange))
        let contextRange = NSRange(
            location: contextStart,
            length: max(0, contextEnd - contextStart)
        )
        let slice = nsText.substring(with: contextRange)
        let windowEnd = window.range.location + window.range.length

        return EditorUsabilityService.styleRuns(in: slice).compactMap { run in
            let globalRange = EditorTextRange(
                location: contextRange.location + run.textRange.location,
                length: run.textRange.length
            )
            let globalEnd = globalRange.location + globalRange.length
            guard globalEnd >= window.range.location,
                  globalRange.location <= windowEnd else {
                return nil
            }
            return EditorLineStyleRun(kind: run.kind, textRange: globalRange)
        }
    }
}

public struct IOSEditorDebouncePolicy: Equatable, Sendable {
    public let parseDelayMilliseconds: Int
    public let autosaveDelayMilliseconds: Int

    public init(workspacePolicy: IOSWorkspacePolicy) {
        parseDelayMilliseconds = workspacePolicy.parseDebounceMilliseconds
        autosaveDelayMilliseconds = workspacePolicy.autosaveDebounceMilliseconds
    }
}
