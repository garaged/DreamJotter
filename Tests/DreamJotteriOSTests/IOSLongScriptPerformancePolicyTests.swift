import DreamJotterCore
import DreamJotteriOS
import Foundation
import Testing

@Suite("iOS long-script performance policy")
struct IOSLongScriptPerformancePolicyTests {
    @Test("fixture is deterministic and large enough for regression work")
    func fixtureShape() {
        let first = IOSLongScriptFixture.screenplay(sceneCount: 500)
        let second = IOSLongScriptFixture.screenplay(sceneCount: 500)

        #expect(first == second)
        #expect((first as NSString).length > 80_000)
        #expect(first.components(separatedBy: "INT. ROOM ").count - 1 == 500)
    }

    @Test("formatting window stays bounded in a 500-scene screenplay")
    func formattingWindowRemainsBounded() {
        let text = IOSLongScriptFixture.screenplay(sceneCount: 500)
        let textLength = (text as NSString).length
        let visible = EditorTextRange(location: textLength / 2, length: 2_000)
        let window = IOSEditorFormattingPolicy.formattingWindow(
            visibleRange: visible,
            text: text,
            overscanUTF16Length: 4_096
        )

        #expect(window.range.length <= 10_192)
        #expect(window.range.length < textLength / 4)
    }

    @Test("bounded style runs never escape the formatting window")
    func boundedStyleRunsStayInsideWindow() {
        let text = IOSLongScriptFixture.screenplay(sceneCount: 300)
        let visible = EditorTextRange(location: 20_000, length: 1_500)
        let window = IOSEditorFormattingPolicy.formattingWindow(
            visibleRange: visible,
            text: text,
            overscanUTF16Length: 2_000
        )
        let runs = IOSEditorFormattingPolicy.boundedStyleRuns(
            text: text,
            visibleRange: visible,
            overscanUTF16Length: 2_000
        )
        let end = window.range.location + window.range.length

        #expect(!runs.isEmpty)
        #expect(runs.allSatisfy { run in
            run.textRange.location <= end &&
                run.textRange.location + run.textRange.length >= window.range.location
        })
    }
}
