import DreamJotterCore
import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M9.6 Restore UX Tests")
struct M9RestoreUXTests {
    private let now = Date(timeIntervalSince1970: 1_700_300_000)

    @Test("Valid restore into clean project applies immediately")
    func validRestoreIntoCleanProjectAppliesImmediately() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Clean Draft", now: now)

        let result = app.restoreBackup(from: backup, now: now)

        #expect(result.status == .restored)
        #expect(app.currentDocument?.dashboard.title == "Restored Draft")
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.pendingRestore == nil)
    }

    @Test("Valid restore into dirty project creates pending confirmation")
    func validRestoreIntoDirtyProjectCreatesPendingConfirmation() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")

        let result = app.restoreBackup(from: backup, now: now)

        #expect(result.status == .confirmationRequired)
        #expect(app.currentDocument?.dashboard.title == "Dirty Draft")
        #expect(app.currentDocument?.isDirty == true)
        #expect(app.pendingRestore != nil)
    }

    @Test("Cancel pending restore preserves current dirty project")
    func cancelPendingRestorePreservesCurrentDirtyProject() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")
        _ = app.restoreBackup(from: backup, now: now)

        app.cancelPendingRestore()

        #expect(app.pendingRestore == nil)
        #expect(app.currentDocument?.dashboard.title == "Dirty Draft")
        #expect(app.currentDocument?.isDirty == true)
    }

    @Test("Discard and Restore applies validated backup")
    func discardAndRestoreAppliesValidatedBackup() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")
        _ = app.restoreBackup(from: backup, now: now)

        let result = app.discardPendingRestore(now: now.addingTimeInterval(1))

        #expect(result.status == .restored)
        #expect(app.pendingRestore == nil)
        #expect(app.currentDocument?.dashboard.title == "Restored Draft")
        #expect(app.currentDocument?.isDirty == false)
    }

    @Test("Save and Restore requires Save As for unsaved dirty project")
    func saveAndRestoreRequiresSaveAsForUnsavedDirtyProject() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")
        _ = app.restoreBackup(from: backup, now: now)

        let result = try app.saveAndConfirmPendingRestore(now: now.addingTimeInterval(1))

        #expect(result == .requiresSaveAs)
        #expect(app.pendingRestore != nil)
        #expect(app.currentDocument?.dashboard.title == "Dirty Draft")
        #expect(app.currentDocument?.isDirty == true)
    }

    @Test("External Save As then Restore applies pending restore")
    func externalSaveAsThenRestoreAppliesPendingRestore() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")
        _ = app.restoreBackup(from: backup, now: now)
        let packageURL = temporaryDirectory(named: "DreamJotterM96SaveAs")
            .appendingPathComponent("Dirty Draft.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: packageURL.deletingLastPathComponent()) }

        _ = try app.saveCurrentProject(to: packageURL, now: now.addingTimeInterval(1))
        let result = try app.confirmPendingRestoreAfterExternalSave(now: now.addingTimeInterval(2))

        #expect(result.status == .restored)
        #expect(app.pendingRestore == nil)
        #expect(app.currentDocument?.dashboard.title == "Restored Draft")
        #expect(app.currentDocument?.isDirty == false)
        #expect(app.recentProjectURLs == [packageURL])
    }

    @Test("Save failure blocks pending restore and preserves dirty project")
    func saveFailureBlocksPendingRestoreAndPreservesDirtyProject() throws {
        let backup = try backupData(for: project(title: "Restored Draft", id: "project-restored"))
        let blockingFile = temporaryDirectory(named: "DreamJotterM96BlockedSave")
        try "not a directory".write(to: blockingFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: blockingFile) }
        let badPackageURL = blockingFile.appendingPathComponent("Blocked.dreamjotter", isDirectory: true)
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.currentDocument = ProjectDocumentViewModel(
            project: project(title: "Dirty Draft", id: "project-dirty"),
            packageURL: badPackageURL,
            isDirty: true
        )
        _ = app.restoreBackup(from: backup, now: now)

        do {
            _ = try app.saveAndConfirmPendingRestore(now: now.addingTimeInterval(1))
            Issue.record("Expected save before restore to fail")
        } catch let error as AppError {
            #expect(error.category == .saveFailed || error.category == .permissionDenied)
        } catch {
            Issue.record("Expected AppError, got \(error)")
        }

        #expect(app.pendingRestore != nil)
        #expect(app.currentDocument?.dashboard.title == "Dirty Draft")
        #expect(app.currentDocument?.isDirty == true)
    }

    @Test("Invalid backup does not create pending restore state")
    func invalidBackupDoesNotCreatePendingRestoreState() {
        var app = MacAppViewModel(recentProjectStore: .memory())
        app.createBlankProject(title: "Dirty Draft", now: now)
        app.currentDocument?.updateScriptText("INT. DIRTY ROOM - DAY")

        let result = app.restoreBackup(from: Data("not json".utf8), now: now)

        #expect(result.status == .failed)
        #expect(app.pendingRestore == nil)
        #expect(app.currentDocument?.dashboard.title == "Dirty Draft")
        #expect(app.currentDocument?.isDirty == true)
    }

    private func backupData(for project: DreamJotterProject) throws -> Data {
        try BackupRestoreWorkflow.encode(
            BackupRestoreWorkflow.makeArchive(for: project, createdAt: now)
        )
    }

    private func project(title: String, id: String) -> DreamJotterProject {
        ProjectFactory.createBlankProject(
            title: title,
            projectID: id,
            screenplayID: "screenplay-\(id)",
            createdAt: now
        )
    }

    private func temporaryDirectory(named name: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
    }
}
