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
        #expect(source.contains("navigateToScene"))
    }

    @Test("scene planning supports drag order confirmed screenplay application and editor refresh")
    func scenePlanningContract() throws {
        let scenes = try appSource("IOSEditableScenesPane.swift")
        let editor = try appSource("IOSNativeTextKitEditor.swift")
        #expect(scenes.contains(".onMove"))
        #expect(scenes.contains("reorderPlanning"))
        #expect(scenes.contains("reorderScreenplay"))
        #expect(scenes.contains("confirmationDialog"))
        #expect(scenes.contains("IOSExternalScreenplayReplacementStore.stage"))
        #expect(editor.contains("IOSExternalScreenplayReplacementStore.consume"))
        #expect(editor.contains("externalReplacement"))
    }

    @Test("notes support every target kind and linked navigation")
    func noteTargetNavigationContract() throws {
        let options = try appSource("IOSNoteTargetOption.swift")
        let notes = try appSource("IOSNotesReviewPanes.swift")
        let workspace = try appSource("IOSWorkspacePaneContent.swift")
        for target in [".project", ".scene", ".character", ".location", ".screenplayElement"] {
            #expect(options.contains("targetKind: \(target)"))
        }
        #expect(notes.contains("IOSNoteTargetEditorSheet"))
        #expect(notes.contains("navigateToLink"))
        #expect(workspace.contains("navigateToNoteLink"))
        #expect(workspace.contains("openScreenplayText"))
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
