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

    @Test("workspace has four explicit device-class compositions")
    func fourClassWorkspaceContract() throws {
        let source = try appSource(named: "IOSProjectEditorView.swift")
        #expect(source.contains("compactPhoneWorkspace"))
        #expect(source.contains("regularPhoneWorkspace"))
        #expect(source.contains("compactPadWorkspace"))
        #expect(source.contains("regularPadWorkspace"))
        #expect(source.contains("NavigationSplitView"))
        #expect(source.contains("projectInspector"))
        #expect(source.contains("maximumReadableEditorWidth"))
    }

    @Test("workspace exposes Mac-equivalent project destinations")
    func workspaceParityContract() throws {
        let paneModel = try appSource(named: "IOSWorkspacePane.swift")
        let content = try appSource(named: "IOSWorkspacePaneContent.swift")
        for destination in [
            "dashboard", "screenplay", "scenes", "characters",
            "locations", "notes", "review", "healthReport"
        ] {
            #expect(paneModel.contains("case \(destination)"))
        }
        #expect(content.contains("Create Character"))
        #expect(content.contains("Create Location"))
        #expect(content.contains("Create Note"))
        #expect(content.contains("Read-only Screenplay"))
        #expect(content.contains("IOSHealthReportPane"))
        #expect(content.contains("Save Project Details"))
    }

    @Test("autocomplete remains a floating editor overlay")
    func compactAutocompleteContract() throws {
        let source = try appSource(named: "IOSProjectEditorView.swift")
        #expect(source.contains("ZStack(alignment: .bottom)"))
        #expect(source.contains("IOSAutocompletePanel"))
        #expect(source.contains("transition(.opacity.combined"))
    }

    @Test("application shell swaps full-screen child controllers instead of presenting editor sheets")
    func fullScreenRootContract() throws {
        let source = try appSource(named: "DreamJotteriOSApplication.swift")
        #expect(source.contains("IOSRootContainerController"))
        #expect(source.contains("replaceActiveController"))
        #expect(source.contains("bottomAnchor.constraint(equalTo: view.bottomAnchor)"))
        #expect(!source.contains("modalPresentationStyle"))
    }

    @Test("AppKit-only relaunch code is guarded from non-macOS compilation")
    func appKitIsolationContract() throws {
        let source = try repositorySource(named: "Apps/DreamJotterMac/ApplicationLanguageRelaunch.swift")
        #expect(source.hasPrefix("#if canImport(AppKit)"))
        #expect(source.contains("import AppKit"))
        #expect(source.hasSuffix("#endif\n"))
    }

    @Test("app metadata opts into a modern full-screen viewport and document packages")
    func applicationMetadataContract() throws {
        let source = try appSource(named: "Info.plist")
        #expect(source.contains("<key>UILaunchScreen</key>"))
        #expect(source.contains("<key>UISupportedInterfaceOrientations</key>"))
        #expect(source.contains("org.garaged.dreamjotter.project"))
        #expect(source.contains("<key>UISupportsDocumentBrowser</key>"))
    }

    private func appSource(named filename: String) throws -> String {
        try repositorySource(named: "Apps/DreamJotteriOSApp/\(filename)")
    }

    private func repositorySource(named path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: root.appendingPathComponent(path),
            encoding: .utf8
        )
    }
}
