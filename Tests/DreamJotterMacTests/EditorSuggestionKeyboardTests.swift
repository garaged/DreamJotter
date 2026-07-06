import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Editor Suggestion Keyboard UX")
struct EditorSuggestionKeyboardTests {
    @Test("Focused TextKit editor routes keyboard suggestion commands")
    func keyboardCommandsAreWired() throws {
        let source = try source(named: "TextKitScreenplayEditorView.swift")

        #expect(source.contains("case 125"))
        #expect(source.contains("case 126"))
        #expect(source.contains("case 53"))
        #expect(source.contains("case 36, 76"))
        #expect(source.contains("case 48"))
        #expect(source.contains("moveSuggestion(by:"))
        #expect(source.contains("acceptSuggestion()"))
        #expect(source.contains("dismissSuggestions()"))
    }

    @Test("Return and Tab prefer suggestions before editor commands")
    func nativeEditorCommandsPreferSuggestionAcceptance() throws {
        let source = try source(named: "TextKitScreenplayEditorView.swift")

        let accept = try #require(source.range(of: "commandHandler?.acceptSuggestion()"))
        let smartEnter = try #require(source.range(of: "commandHandler?.performSmartEnter"))
        let tabCycle = try #require(source.range(of: "commandHandler?.performTabCycle"))
        #expect(accept.lowerBound < smartEnter.lowerBound)
        #expect(accept.lowerBound < tabCycle.lowerBound)
    }

    @Test("Suggestion panel documents keyboard controls and selected state")
    func suggestionPanelCommunicatesKeyboardUX() throws {
        let editorSource = try source(named: "TextKitOnlyScriptEditorView.swift")
        let supportSource = try source(named: "TextKitOnlyScriptEditorSupport.swift")

        #expect(editorSource.contains("selectedSuggestionIndex"))
        #expect(supportSource.contains("Return or Tab accept"))
        #expect(supportSource.contains("accessibilityValue"))
    }

    private func source(named filename: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent("Apps/DreamJotterMac/Views/\(filename)")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
