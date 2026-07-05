import Foundation
import Testing

@Suite("iOS native editor source regressions")
struct IOSNativeEditorSourceTests {
    @Test("editor bridge keeps visible-range and native selection integration")
    func editorBridgeContract() throws {
        let source = try appSource(named: "IOSNativeTextKitEditor.swift")
        #expect(source.contains("UITextView"))
        #expect(source.contains("selectedRange"))
        #expect(source.contains("onVisibleRangeChanged"))
        #expect(source.contains("adjustsFontForContentSizeCategory"))
    }

    @Test("autocomplete panel exposes selected state and keyboard guidance")
    func autocompleteAccessibilityContract() throws {
        let source = try appSource(named: "IOSAutocompletePanel.swift")
        #expect(source.contains("state.selectedIndex"))
        #expect(source.contains("accessibilityValue"))
        #expect(source.contains("Return or Tab"))
        #expect(source.contains("Escape"))
    }

    private func appSource(named filename: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: root.appendingPathComponent("Apps/DreamJotteriOSApp/\(filename)"),
            encoding: .utf8
        )
    }
}
