import Foundation
import Testing

@Suite("Project workspace layout regressions")
struct ProjectWorkspaceLayoutRegressionTests {
    @Test("Workspace uses two navigation columns and the optimized Script workspace")
    func workspaceAvoidsEmptySidePanes() throws {
        let source = try projectWorkspaceSource()

        #expect(source.contains("NavigationSplitView {"))
        #expect(source.contains("} detail: {"))
        #expect(!source.contains("} content: {"))
        #expect(source.contains("case .script:"))
        #expect(source.contains("ResizableScriptWorkspaceView(document: $document)"))
        #expect(source.contains("contentView"))
        #expect(source.contains(".frame(maxWidth: .infinity, maxHeight: .infinity)"))
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
