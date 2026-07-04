import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M13 TextKit editor maturity")
struct TextKitEditorMaturityTests {
    @Test("Selection expands to complete grapheme clusters")
    func graphemeSafeSelection() {
        let text = "A👩🏽‍💻B"
        let source = text as NSString
        let emoji = source.range(of: "👩🏽‍💻")

        let unsafe = NSRange(location: emoji.location + 1, length: 1)
        let safe = TextKitScreenplayEditorView.graphemeSafeRange(unsafe, in: text)

        #expect(safe == emoji)
    }

    @Test("Collapsed cursor remains valid at end of text")
    func cursorAtEnd() {
        let text = "SOFÍA"
        let end = (text as NSString).length

        let safe = TextKitScreenplayEditorView.graphemeSafeRange(
            NSRange(location: end + 20, length: 0),
            in: text
        )

        #expect(safe == NSRange(location: end, length: 0))
    }

    @Test("Paste normalization produces canonical screenplay newlines")
    func pasteNormalization() {
        let pasted = "INT. ROOM - DAY\r\n\r\nMARA\rHello\u{00A0}there\u{2028}Again"

        let normalized = TextKitScreenplayEditorView.normalizedPaste(pasted)

        #expect(normalized == "INT. ROOM - DAY\n\nMARA\nHello there\nAgain")
        #expect(!normalized.contains("\r"))
        #expect(!normalized.contains("\u{00A0}"))
    }

    @Test("Multi-line selection expands across complete composed characters")
    func multiLineSelection() {
        let text = "SOFÍA\n👨‍👩‍👧‍👦 arrives.\nCUT TO:"
        let source = text as NSString
        let family = source.range(of: "👨‍👩‍👧‍👦")
        let unsafe = NSRange(location: family.location + 2, length: family.length - 3)

        let safe = TextKitScreenplayEditorView.graphemeSafeRange(unsafe, in: text)

        #expect(safe == family)
    }
}