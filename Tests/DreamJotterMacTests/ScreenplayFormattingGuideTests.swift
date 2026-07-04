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
        #expect(source.localizedCaseInsensitiveContains("markers are editor syntax only"))
    }

    @Test("Current paragraph shows syntax and bottom usage guidance")
    func currentParagraphShowsContextualHelp() throws {
        let source = try inspectorSource()

        #expect(source.contains("currentGuideEntry"))
        #expect(source.contains("entry.example"))
        #expect(source.contains("entry.guidance"))
        #expect(source.contains("How to use this type"))
        #expect(source.contains("entry.howToUse"))
    }

    @Test("Confusing paragraph types include novice distinctions")
    func noviceDistinctionsAreDocumented() throws {
        let action = try #require(ScreenplayFormattingGuide.entry(for: .action))
        let dialogue = try #require(ScreenplayFormattingGuide.entry(for: .dialogue))
        let introduction = try #require(ScreenplayFormattingGuide.entry(for: .characterIntroduction))
        let synopsis = try #require(ScreenplayFormattingGuide.entry(for: .synopsis))
        let shot = try #require(ScreenplayFormattingGuide.entry(for: .shot))
        let pageBreak = try #require(ScreenplayFormattingGuide.entry(for: .pageBreak))

        #expect(action.howToUse.localizedCaseInsensitiveContains("dialogue"))
        #expect(dialogue.howToUse.localizedCaseInsensitiveContains("action"))
        #expect(introduction.howToUse.localizedCaseInsensitiveContains("first"))
        #expect(synopsis.howToUse.localizedCaseInsensitiveContains("action"))
        #expect(shot.howToUse.localizedCaseInsensitiveContains("camera"))
        #expect(pageBreak.howToUse.localizedCaseInsensitiveContains("rarely"))
    }

    @Test("Dialogue and combined cue boundaries are explained")
    func dialogueBoundaryIsDocumented() throws {
        let dialogue = try #require(ScreenplayFormattingGuide.entry(for: .dialogue))
        let cue = try #require(ScreenplayFormattingGuide.entry(for: .characterCue))

        #expect(cue.howToUse.localizedCaseInsensitiveContains("blank line"))
        #expect(cue.howToUse.contains("SOFÍA / TOM"))
        #expect(dialogue.howToUse.localizedCaseInsensitiveContains("character cue"))
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
