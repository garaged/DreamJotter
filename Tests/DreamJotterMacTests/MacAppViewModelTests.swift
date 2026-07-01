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
        #expect(document.packageURL == nil)
        #expect(document.isDirty == false)
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
        #expect(document.isDirty)
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

    @Test("Save without a package URL requests Save As")
    func saveWithoutPackageURLRequestsSaveAs() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")

        let result = try app.saveCurrentProject(now: now)

        #expect(result == .requiresSaveAs)
        #expect(app.currentDocument?.isDirty == true)
    }

    @Test("Saving to a package clears dirty state and records a recent project")
    func saveAsClearsDirtyAndRecordsRecentProject() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        let packageURL = temporaryDirectory(named: "DreamJotterMacSaveAs").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }

        try app.saveCurrentProject(to: packageURL, now: now)

        #expect(app.currentDocument?.packageURL == packageURL)
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.recentProjectURLs == [packageURL])
    }

    @Test("Saving an existing package updates that package and clears dirty state")
    func saveExistingPackageClearsDirtyState() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        let packageURL = temporaryDirectory(named: "DreamJotterMacExistingSave").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        try app.saveCurrentProject(to: packageURL, now: now)
        app.currentDocument?.updateScriptText("EXT. STREET - DAY")

        let result = try app.saveCurrentProject(now: now)

        #expect(result == .saved)
        #expect(app.currentDocument?.packageURL == packageURL)
        #expect(app.currentDocument?.isDirty == false)
    }

    @Test("Opening a package loads clean state and records recent project")
    func openPackageLoadsCleanStateAndRecordsRecentProject() throws {
        var source = ProjectDocumentViewModel(project: project())
        source.updateScriptText("EXT. PARK - DAY")
        let packageURL = temporaryDirectory(named: "DreamJotterMacOpen").appendingPathComponent("Open Me.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        try source.save(to: packageURL, now: now)

        var app = MacAppViewModel(recentProjectStore: .memory())
        let decision = try app.requestOpenPackage(at: packageURL)

        #expect(decision == .replaced)
        #expect(app.currentDocument?.packageURL == packageURL)
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.currentDocument?.dashboard.sceneCount == 1)
        #expect(app.recentProjectURLs == [packageURL])
    }

    @Test("Failed open returns human readable error")
    func failedOpenReturnsHumanReadableError() throws {
        let invalidURL = temporaryDirectory(named: "DreamJotterInvalidOpen").appendingPathComponent("Broken.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: invalidURL.deletingLastPathComponent()) }
        var app = MacAppViewModel(recentProjectStore: .memory(initialURLs: [invalidURL]))

        do {
            _ = try app.requestOpenPackage(at: invalidURL)
            Issue.record("Expected open to fail")
        } catch {
            #expect(error.localizedDescription.isEmpty == false)
            #expect(!error.localizedDescription.contains("Swift"))
        }
    }

    @Test("Export does not mark project dirty")
    func exportDoesNotMarkDirty() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        let packageURL = temporaryDirectory(named: "DreamJotterExportDirty").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        let exportURL = packageURL.deletingLastPathComponent().appendingPathComponent("First Draft.fountain")
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        try app.saveCurrentProject(to: packageURL, now: now)

        try app.exportCurrentProject(to: exportURL)

        #expect(app.currentDocument?.isDirty == false)
    }

    @Test("Replacing a dirty project requires confirmation")
    func replacingDirtyProjectRequiresConfirmation() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")

        let decision = app.requestNewProject(title: "Second Draft", now: now)

        #expect(decision != .replaced)
        #expect(app.pendingReplacement == .newProject(title: "Second Draft"))

        try app.confirmPendingReplacement(now: now)
        #expect(app.currentDocument?.dashboard.title == "Second Draft")
        #expect(app.currentDocument?.isDirty == false)
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

    private func temporaryDirectory(named name: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
    }
}
