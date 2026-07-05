import Foundation
import Testing

@Suite("Project workspace layout regressions")
struct ProjectWorkspaceLayoutRegressionTests {
    @Test("Workspace uses two navigation columns and a stable Script layout")
    func workspaceAvoidsEmptySidePanes() throws {
        let source = try projectWorkspaceSource()

        #expect(source.contains("NavigationSplitView {"))
        #expect(source.contains("} detail: {"))
        #expect(!source.contains("} content: {"))
        #expect(source.contains("case .script:\n            HStack(spacing: 0) {"))
        #expect(source.contains("ScriptEditorView(document: $document)"))
        #expect(source.contains("ScreenplayParagraphInspectorView(document: $document)"))
        #expect(source.contains(".frame(width: 300)"))
        #expect(source.contains(".frame(maxHeight: .infinity)"))
        #expect(!source.contains("HSplitView"))
    }

    @Test("Project sidebar rows use concrete selection tags")
    func projectSidebarRemainsClickable() throws {
        let source = try projectWorkspaceSource()

        #expect(source.contains("List(selection: $selectedSection)"))
        #expect(source.contains(".tag(section)"))
        #expect(!source.contains(".tag(Optional(section))"))
    }

    private func projectWorkspaceSource() throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: repositoryRoot
                .appendingPathComponent("Apps/DreamJotterMac/Views/ProjectWorkspaceView.swift"),
            encoding: .utf8
        )
    }
}
