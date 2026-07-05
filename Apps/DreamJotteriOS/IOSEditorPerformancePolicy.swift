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
        let windowEnd = window.range.location + window.range.length
        return EditorUsabilityService.styleRuns(in: text).filter { run in
            let runEnd = run.textRange.location + run.textRange.length
            return runEnd >= window.range.location && run.textRange.location <= windowEnd
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
