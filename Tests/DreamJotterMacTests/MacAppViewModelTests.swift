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

        _ = try app.saveCurrentProject(to: packageURL, now: now)

        #expect(app.currentDocument?.packageURL == packageURL)
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.recentProjectURLs == [packageURL])
    }

    @Test("Canceling Save As preserves unsaved dirty state")
    func cancelingSaveAsPreservesDirtyState() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")

        let result = app.cancelSaveAs()

        #expect(result == .canceled)
        #expect(app.currentDocument?.packageURL == nil)
        #expect(app.currentDocument?.isDirty == true)
        #expect(app.recentProjectURLs.isEmpty)
    }

    @Test("Saving an existing package updates that package and clears dirty state")
    func saveExistingPackageClearsDirtyState() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        let packageURL = temporaryDirectory(named: "DreamJotterMacExistingSave").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        _ = try app.saveCurrentProject(to: packageURL, now: now)
        app.currentDocument?.updateScriptText("EXT. STREET - DAY")

        let result = try app.saveCurrentProject(now: now)

        #expect(result == .saved)
        #expect(app.currentDocument?.packageURL == packageURL)
        #expect(app.currentDocument?.isDirty == false)
    }

    @Test("Failed Save As preserves dirty state and package URL")
    func failedSaveAsPreservesDirtyStateAndPackageURL() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        let blockingFile = temporaryDirectory(named: "DreamJotterBlockedParent")
        try "not a directory".write(to: blockingFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: blockingFile) }
        let packageURL = blockingFile.appendingPathComponent("Blocked.dreamjotter", isDirectory: true)

        do {
            _ = try app.saveCurrentProject(to: packageURL, now: now)
            Issue.record("Expected save to fail")
        } catch let error as AppError {
            #expect(error.category == .saveAsFailed || error.category == .permissionDenied)
        } catch {
            Issue.record("Expected AppError, got \(error)")
        }

        #expect(app.currentDocument?.packageURL == nil)
        #expect(app.currentDocument?.isDirty == true)
        #expect(app.recentProjectURLs.isEmpty)
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

    @Test("Opening a package can recover editor text from nonempty Fountain projection")
    func openPackageRecoversEditorTextFromFountainProjection() throws {
        let packageURL = temporaryDirectory(named: "DreamJotterFountainProjectionOpen").appendingPathComponent("Projection.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)
        for directory in ["snapshots", "attachments", "exports", "indexes"] {
            try FileManager.default.createDirectory(at: packageURL.appendingPathComponent(directory, isDirectory: true), withIntermediateDirectories: true)
        }

        let metadata = ProjectMetadata(
            id: "project-projection",
            title: "Projection",
            createdAt: now,
            modifiedAt: now,
            schemaVersion: ProjectFactory.currentSchemaVersion,
            primaryScreenplayID: "screenplay-projection"
        )
        let manifest = PackageManifest(packageId: metadata.id, createdAt: now, updatedAt: now)
        try writeJSON(metadata, to: packageURL.appendingPathComponent("project.json"))
        try writeJSON(ScreenplayDocument(), to: packageURL.appendingPathComponent("screenplay.json"))
        try writeJSON([CharacterRecord](), to: packageURL.appendingPathComponent("characters.json"))
        try writeJSON([ProjectNote](), to: packageURL.appendingPathComponent("notes.json"))
        try writeJSON([InboxItem](), to: packageURL.appendingPathComponent("inbox.json"))
        try writeJSON([SceneCard](), to: packageURL.appendingPathComponent("scene-cards.json"))
        try writeJSON(ExportPresetCatalog.builtInPresets(), to: packageURL.appendingPathComponent("export-presets.json"))
        try writeJSON(StoryDevelopmentState(), to: packageURL.appendingPathComponent("story.json"))
        try writeJSON(ProProjectState(), to: packageURL.appendingPathComponent("pro.json"))
        try writeJSON(manifest, to: packageURL.appendingPathComponent("manifest.json"))
        try "INT. ROOM - DAY\n\nELENA\nWe can see this.".write(to: packageURL.appendingPathComponent("script.fountain"), atomically: true, encoding: .utf8)

        var app = MacAppViewModel(recentProjectStore: .memory())
        try app.openPackage(at: packageURL)

        #expect(app.currentDocument?.scriptText.contains("ELENA") == true)
        #expect(app.currentDocument?.scenes.first?.heading == "INT. ROOM - DAY")
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
        } catch let error as AppError {
            #expect(error.category == .invalidPackage)
            #expect(error.localizedDescription.isEmpty == false)
            #expect(!error.localizedDescription.contains("Swift"))
        } catch {
            #expect(error.localizedDescription.isEmpty == false)
            #expect(!error.localizedDescription.contains("Swift"))
        }
    }

    @Test("Recent project duplicates collapse to a single latest entry")
    func recentProjectDuplicatesCollapseToSingleEntry() throws {
        let packageURL = temporaryDirectory(named: "DreamJotterDuplicateRecent").appendingPathComponent("Recent.dreamjotter", isDirectory: true)
        let app = MacAppViewModel(recentProjectStore: .memory(initialURLs: [
            packageURL,
            packageURL.standardizedFileURL,
            packageURL
        ]))

        #expect(app.recentProjectURLs == [packageURL.standardizedFileURL])
    }

    @Test("Export does not mark project dirty")
    func exportDoesNotMarkDirty() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        let packageURL = temporaryDirectory(named: "DreamJotterExportDirty").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        let exportURL = packageURL.deletingLastPathComponent().appendingPathComponent("First Draft.fountain")
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }
        _ = try app.saveCurrentProject(to: packageURL, now: now)

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

    @Test("Saving before replacement requires Save As for unsaved projects")
    func savingBeforeReplacementRequiresSaveAsForUnsavedProject() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        _ = app.requestNewProject(title: "Second Draft", now: now)

        let result = try app.saveAndConfirmPendingReplacement(now: now)

        #expect(result == .requiresSaveAs)
        #expect(app.pendingReplacement == .newProject(title: "Second Draft"))
        #expect(app.currentDocument?.dashboard.title == "First Draft")
        #expect(app.currentDocument?.isDirty == true)
    }

    @Test("Saving before replacement applies pending action after Save As succeeds")
    func saveAsBeforeReplacementAppliesPendingAction() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")
        _ = app.requestNewProject(title: "Second Draft", now: now)
        let packageURL = temporaryDirectory(named: "DreamJotterSaveBeforeReplace").appendingPathComponent("First Draft.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }

        _ = try app.saveCurrentProject(to: packageURL, now: now)
        try app.confirmPendingReplacementAfterExternalSave(now: now)

        #expect(app.pendingReplacement == nil)
        #expect(app.currentDocument?.dashboard.title == "Second Draft")
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.recentProjectURLs == [packageURL])
    }

    @Test("Closing a dirty window requires confirmation")
    func closingDirtyWindowRequiresConfirmation() throws {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "First Draft", now: now)
        app.currentDocument?.updateScriptText("INT. ROOM - DAY")

        let decision = app.requestCloseWindow()

        #expect(decision != .replaced)
        #expect(app.pendingReplacement == .closeWindow)

        try app.confirmPendingReplacement(now: now)
        #expect(app.currentDocument == nil)
    }

    @Test("Explicit parse refresh keeps derived scene list current")
    func refreshParseGeneratesSceneList() {
        var document = ProjectDocumentViewModel(project: project())
        document.scriptText = "INT. APARTMENT - NIGHT"

        document.refreshParse(now: now)

        #expect(document.scenes.map(\.heading) == ["INT. APARTMENT - NIGHT"])
        #expect(document.dashboard.sceneCount == 1)
        #expect(document.editorParseState.sceneCount == 1)
        #expect(document.editorParseState.lastParsedTextRevision == document.editorParseState.currentTextRevision)
    }

    @Test("Editor usability state is exposed through the document view model")
    func editorUsabilityStateIsExposedThroughDocumentViewModel() {
        var document = ProjectDocumentViewModel(project: project())
        document.updateScriptText("""
        INT. COFFEE SHOP - DAY

        ELENA
        We start here.

        EXT. STREET - NIGHT

        They leave.
        """)

        #expect(document.smartEnterNextKind(from: .characterCue) == .dialogue)
        #expect(document.tabCycleNextKind(from: .action) == .characterCue)

        let characterSuggestions = document.characterSuggestions(
            prefix: "ele",
            replacementRange: EditorTextRange(location: 0, length: 3)
        )
        #expect(characterSuggestions.first?.replacementText == "ELENA")

        let sceneSuggestions = document.sceneHeadingSuggestions(
            prefix: "INT. cof",
            replacementRange: EditorTextRange(location: 5, length: 3)
        )
        #expect(sceneSuggestions.first(where: { $0.type == .location })?.replacementText == "COFFEE SHOP")

        document.requestNavigation(toSceneAt: 1)
        #expect(document.editorNavigationState.selectedSceneID == "scene-2")
        #expect(document.editorNavigationState.scrollTarget?.kind == .scene)

        let cursorLocation = (document.scriptText as NSString).range(of: "They leave.").location
        document.updateSelectedSceneForCursor(location: cursorLocation)
        #expect(document.editorNavigationState.selectedSceneID == "scene-2")
    }

    @Test("Smart Enter action mutates text through the document model and marks dirty")
    func smartEnterActionMutatesTextThroughDocumentModelAndMarksDirty() {
        var document = ProjectDocumentViewModel(project: project(), scriptText: "INT. ROOM - DAY", isDirty: false)

        document.performSmartEnter(at: (document.scriptText as NSString).length)

        #expect(document.scriptText == "INT. ROOM - DAY\n\n")
        #expect(document.isDirty)
        #expect(document.editorNavigationState.scrollTarget?.kind == .textRange)
        #expect(document.editorNavigationState.cursorTextRange?.location == (document.scriptText as NSString).length)
    }

    @Test("Tab cycling mutates the current line through the document model and marks dirty")
    func tabCyclingMutatesCurrentLineThroughDocumentModelAndMarksDirty() {
        var document = ProjectDocumentViewModel(project: project(), scriptText: "niña cruza la estación", isDirty: false)

        document.performTabCycle(at: 0)

        #expect(document.scriptText == "NIÑA CRUZA LA ESTACIÓN")
        #expect(document.isDirty)
        #expect(document.editorNavigationState.cursorTextRange?.location == (document.scriptText as NSString).length)
    }

    @Test("Accepting a character suggestion updates text and ignoring suggestions preserves text")
    func acceptingCharacterSuggestionUpdatesTextAndIgnoringPreservesText() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.updateScriptText("""
        ELENA
        We begin.

        ELE
        """)
        document.refreshEditorSuggestions(cursorLocation: (document.scriptText as NSString).length)
        let suggestion = try #require(document.editorSuggestions.first { $0.type == .character })

        document.acceptEditorSuggestion(suggestion)

        #expect(document.scriptText.hasSuffix("ELENA"))
        #expect(document.isDirty)

        let textAfterAccept = document.scriptText
        document.refreshEditorSuggestions(cursorLocation: (document.scriptText as NSString).length)
        document.ignoreEditorSuggestions()

        #expect(document.scriptText == textAfterAccept)
        #expect(document.editorSuggestions.isEmpty)
    }

    @Test("Accepting a location suggestion preserves scene heading prefix")
    func acceptingLocationSuggestionPreservesSceneHeadingPrefix() throws {
        var document = ProjectDocumentViewModel(project: project())
        document.updateScriptText("""
        INT. COFFEE SHOP - DAY

        Quiet.

        INT. COF
        """)
        document.refreshEditorSuggestions(cursorLocation: (document.scriptText as NSString).length)
        let suggestion = try #require(document.editorSuggestions.first { $0.type == .location })

        document.acceptEditorSuggestion(suggestion)

        #expect(document.scriptText.hasSuffix("INT. COFFEE SHOP"))
    }

    @Test("Duplicate scene headings navigate by parsed position")
    func duplicateSceneHeadingsNavigateByParsedPosition() {
        var document = ProjectDocumentViewModel(project: project())
        document.updateScriptText("""
        INT. ROOM - DAY

        First.

        INT. ROOM - DAY

        Second.
        """)

        document.requestNavigation(toSceneAt: 1)

        let expectedRange = (document.scriptText as NSString).range(
            of: "INT. ROOM - DAY",
            options: [],
            range: NSRange(location: 1, length: (document.scriptText as NSString).length - 1)
        )
        #expect(document.editorNavigationState.selectedSceneID == "scene-2")
        #expect(document.editorNavigationState.scrollTarget?.textRange?.location == expectedRange.location)
    }

    @Test("TextKit line styling is adapter-only and export remains plain Fountain")
    func textKitLineStylingIsAdapterOnlyAndExportRemainsPlainFountain() {
        var document = ProjectDocumentViewModel(project: project())
        document.updateScriptText("""
        INT. ROOM - DAY

        ELENA
        Hello.

        CUT TO:

        [[Fix this]]
        """)

        #expect(document.editorStyleRuns.map(\.kind).contains(.sceneHeading))
        #expect(document.editorStyleRuns.map(\.kind).contains(.characterCue))
        #expect(document.editorStyleRuns.map(\.kind).contains(.transition))
        #expect(document.editorStyleRuns.map(\.kind).contains(.noteReference))
        #expect(!document.fountainExportText.contains("NSAttributedString"))
        #expect(document.fountainExportText.contains("INT. ROOM - DAY"))
    }

    @Test("Empty editor guidance is visible only for blank scripts")
    func emptyEditorGuidanceIsVisibleOnlyForBlankScripts() {
        var document = ProjectDocumentViewModel(project: project())

        #expect(document.isEmptyEditorGuidanceVisible)

        document.updateScriptText("INT. ROOM - DAY")

        #expect(!document.isEmptyEditorGuidanceVisible)
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

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(value).write(to: url, options: .atomic)
    }
}
