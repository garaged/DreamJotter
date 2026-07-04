import DreamJotterCore
import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Screenplay Formatting Guide")
struct ScreenplayFormattingGuideTests {
    @Test("Guide is discoverable from the paragraph inspector")
    func inspectorContainsFormattingGuide() throws {
        let source = try inspectorSource()

        #expect(source.contains("DisclosureGroup(\"Formatting Guide\""))
        #expect(source.contains("ScreenplayFormattingGuide.entries"))
        #expect(source.contains("Markers are editor syntax only") || source.contains("markers are editor syntax only"))
    }

    @Test("Current paragraph shows its syntax example and guidance")
    func currentParagraphShowsContextualHelp() throws {
        let source = try inspectorSource()

        #expect(source.contains("currentGuideEntry"))
        #expect(source.contains("entry.example"))
        #expect(source.contains("entry.guidance"))
    }

    @Test("Formatting guide includes dialogue boundary guidance")
    func dialogueBoundaryIsDocumented() throws {
        let dialogue = try #require(ScreenplayFormattingGuide.entry(for: .dialogue))
        let cue = try #require(ScreenplayFormattingGuide.entry(for: .characterCue))

        #expect(dialogue.guidance.localizedCaseInsensitiveContains("blank line"))
        #expect(cue.guidance.localizedCaseInsensitiveContains("contiguous"))
    }

    private func inspectorSource() throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot
            .appendingPathComponent("Apps")
            .appendingPathComponent("DreamJotterMac")
            .appendingPathComponent("Views")
            .appendingPathComponent("ScreenplayParagraphInspectorView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
