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

    @Test("Editor adapter text updates use the shared semantic view model path")
    func editorAdapterTextUpdatesUseSharedViewModelPath() {
        var document = ProjectDocumentViewModel(project: project())

        document.updateScriptText("""
        EXT. STREET - NIGHT

        LUIS
        Keep walking.
        """)

        #expect(document.scriptText.contains("Keep walking."))
        #expect(document.scenes.first?.heading == "EXT. STREET - NIGHT")
        #expect(document.characters.map(\.displayName) == ["LUIS"])
        #expect(document.fountainExportText.contains("LUIS"))
    }

    @Test("Explicit parse refresh keeps derived scene list current")
    func refreshParseGeneratesSceneList() {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. APARTMENT - NIGHT"

        document.refreshParse(now: now)

        #expect(document.scenes.map(\.heading) == ["INT. APARTMENT - NIGHT"])
        #expect(document.dashboard.sceneCount == 1)
    }

    @Test("Project title logline synopsis and notes update dashboard state")
    func planningFieldsAndNotesUpdateProject() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. ROOM - DAY"

        document.updateTitle("New Title", now: now)
        document.updateLogline("A writer finds the right ending.", now: now)
        document.updateSynopsis("The writer drafts, doubts, and finishes.", now: now)
        document.addNote(
            title: "Opening",
            body: "Make the first image specific.",
            target: .scene(try #require(document.scenes.first)),
            now: now
        )

        #expect(document.dashboard.title == "New Title")
        #expect(document.dashboard.logline == "A writer finds the right ending.")
        #expect(document.dashboard.synopsis == "The writer drafts, doubts, and finishes.")
        #expect(document.dashboard.noteCount == 1)
        #expect(document.notes.first?.links.first == NoteLink(targetKind: .scene, targetID: "INT. ROOM - DAY"))
    }

    @Test("Project saves and opens through dreamjotter package storage")
    func saveAndOpenPackage() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. ROOM - DAY"
        document.updateLogline("A saved logline.", now: now)
        document.addNote(title: "", body: "A saved note.", target: .project, now: now)
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterMacTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let packageURL = root.appendingPathComponent("First Draft.dreamjotter", isDirectory: true)

        try document.save(to: packageURL, now: now)
        var app = MacAppViewModel()
        try app.openPackage(at: packageURL)

        let reopened = try #require(app.currentDocument)
        #expect(reopened.dashboard.sceneCount == 1)
        #expect(reopened.dashboard.logline == "A saved logline.")
        #expect(reopened.dashboard.noteCount == 1)
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

    @Test("Health report action returns advisory findings without mutating text")
    func healthReportIsReadOnly() {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "MARAA\nHello."

        let textBefore = document.scriptText
        let findings = document.healthFindings

        #expect(!findings.isEmpty)
        #expect(document.scriptText == textBefore)
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
