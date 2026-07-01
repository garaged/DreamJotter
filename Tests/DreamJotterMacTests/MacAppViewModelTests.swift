import DreamJotterCore
import Foundation
import Testing
@testable import DreamJotterMac

@Suite("DreamJotter Mac App ViewModel Tests")
struct MacAppViewModelTests {
    private let now = Date(timeIntervalSince1970: 1_700_200_000)

    @Test("Creating a blank project opens an editable document")
    func createBlankProjectOpensDocument() throws {
        var app = MacAppViewModel()

        app.createBlankProject(title: "First Draft", now: now)

        let document = try #require(app.currentDocument)
        #expect(document.dashboard.title == "First Draft")
        #expect(document.dashboard.sceneCount == 0)
    }

    @Test("Editing screenplay text reparses scenes and characters")
    func editingScriptTextReparsesDerivedData() {
        var document = ProjectDocumentViewModel(project: project())

        document.scriptText = """
        INT. ROOM - DAY

        MARA
        We stay.
        """

        #expect(document.dashboard.sceneCount == 1)
        #expect(document.dashboard.characterCount == 1)
        #expect(document.scenes.first?.heading == "INT. ROOM - DAY")
        #expect(document.characters.first?.displayName == "MARA")
    }

    @Test("Project saves and opens through dreamjotter package storage")
    func saveAndOpenPackage() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. ROOM - DAY"
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterMacTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let packageURL = root.appendingPathComponent("First Draft.dreamjotter", isDirectory: true)

        try document.save(to: packageURL, now: now)
        var app = MacAppViewModel()
        try app.openPackage(at: packageURL)

        let reopened = try #require(app.currentDocument)
        #expect(reopened.dashboard.sceneCount == 1)
        #expect(reopened.packageURL == packageURL)
    }

    @Test("Fountain export writes parser-backed text")
    func exportFountainWritesText() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. ROOM - DAY"
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterMacExport-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let exportURL = root.appendingPathComponent("script.fountain")

        try document.exportFountain(to: exportURL)

        let exported = try String(contentsOf: exportURL, encoding: .utf8)
        #expect(exported == "INT. ROOM - DAY")
    }

    private func project() -> DreamJotterProject {
        ProjectFactory.createBlankProject(
            title: "First Draft",
            projectID: "project-1",
            screenplayID: "screenplay-1",
            createdAt: now
        )
    }
}
