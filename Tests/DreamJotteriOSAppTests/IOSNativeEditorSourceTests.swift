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

    @Test("workspace uses adaptive split navigation and a floating suggestion overlay")
    func adaptiveWorkspaceContract() throws {
        let source = try appSource(named: "IOSProjectEditorView.swift")
        #expect(source.contains("IOSAdaptiveLayoutMetrics.resolve"))
        #expect(source.contains("NavigationSplitView"))
        #expect(source.contains("ZStack(alignment: .bottom)"))
        #expect(source.contains("maximumReadableEditorWidth"))
        #expect(source.contains("navigationBarTitleDisplayMode(.inline)"))
        #expect(!source.contains("VStack(spacing: 0)"))
    }

    @Test("compact autocomplete remains an overlay instead of consuming editor height")
    func compactAutocompleteContract() throws {
        let source = try appSource(named: "IOSAutocompletePanel.swift")
        #expect(source.contains("compact"))
        #expect(source.contains("ScrollView(.horizontal"))
        #expect(source.contains("RoundedRectangle"))
        #expect(source.contains("Dismiss suggestions"))
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
