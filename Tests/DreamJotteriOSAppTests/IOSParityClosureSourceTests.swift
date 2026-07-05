import Foundation
import Testing

@Suite("iOS parity closure source regressions")
struct IOSParityClosureSourceTests {
    @Test("scene and note editing preserve project data")
    func sceneAndNoteEditingContract() throws {
        let source = try appSource("IOSSceneAndNoteEditing.swift")
        #expect(source.contains("IOSSceneCardEditing"))
        #expect(source.contains("plotlineTags"))
        #expect(source.contains("IOSNoteLinkEditing"))
        #expect(source.contains("snapshots: project.snapshots"))
    }

    @Test("workspace routes scenes through persistent binding")
    func editableScenesRoutingContract() throws {
        let source = try appSource("IOSWorkspacePaneContent.swift")
        #expect(source.contains("IOSEditableScenesPane"))
        #expect(source.contains("project: $project"))
        #expect(source.contains("commitProjectChange"))
    }

    private func appSource(_ filename: String) throws -> String {
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
