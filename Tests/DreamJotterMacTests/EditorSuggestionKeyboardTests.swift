import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Editor Suggestion Keyboard UX")
struct EditorSuggestionKeyboardTests {
    @Test("Script editor supports keyboard suggestion navigation and acceptance")
    func keyboardCommandsAreWired() throws {
        let source = try scriptEditorSource()

        #expect(source.contains(".onKeyPress(.downArrow)"))
        #expect(source.contains(".onKeyPress(.upArrow)"))
        #expect(source.contains(".onKeyPress(.return)"))
        #expect(source.contains(".onKeyPress(.tab)"))
        #expect(source.contains(".onKeyPress(.escape)"))
        #expect(source.contains("acceptSelectedSuggestion()"))
    }

    @Test("Smart Enter and Tab accept a visible suggestion before editor commands")
    func nativeEditorCommandsPreferSuggestionAcceptance() throws {
        let source = try scriptEditorSource()

        #expect(source.contains("if !acceptSelectedSuggestion()"))
        #expect(source.contains("document.performSmartEnterRespectingLanguage"))
        #expect(source.contains("document.performTabCycleRespectingLanguage"))
    }

    @Test("Suggestion panel documents keyboard controls and selected state")
    func suggestionPanelCommunicatesKeyboardUX() throws {
        let source = try scriptEditorSource()

        #expect(source.contains("Return or Tab accept"))
        #expect(source.contains("selectedSuggestionIndex"))
        #expect(source.contains("accessibilityValue"))
    }

    private func scriptEditorSource() throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot
            .appendingPathComponent("Apps")
            .appendingPathComponent("DreamJotterMac")
            .appendingPathComponent("Views")
            .appendingPathComponent("ScriptEditorView.swift")
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
