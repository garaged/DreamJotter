import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M12.2 Notes Workspace")
struct NotesWorkspaceExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_720_000_000)

    @Test("Unicode search and state filters use canonical notes")
    func unicodeSearchAndFilters() {
        let project = fixture()
        let results = NotesWorkspace.filteredNotes(
            in: project,
            query: NotesWorkspaceQuery(text: "cafe", state: .open, target: .character)
        )
        #expect(results.map(\.id) == ["note-open"])
        #expect(results.first?.body == "Revisit the CAFÉ conversation.")
    }

    @Test("Parsed TODOs remain a separate projection")
    func parsedTodosAreProjected() {
        let project = fixture()
        let todos = NotesWorkspace.unresolvedParsedTodos(in: project, now: now)
        #expect(todos.allSatisfy { $0.source == .parsedScriptTodo })
        #expect(project.notes.allSatisfy { $0.source != .parsedScriptTodo })
    }

    @Test("Resolve, reopen, and update preserve Unicode")
    func resolveReopenAndUpdate() {
        let project = fixture()
        let resolved = CommandEngine.execute(
            NoteWorkspaceCommandRequest(id: "resolve", action: .resolve, noteIDs: ["note-open"], requestedAt: now),
            project: project,
            now: now
        ).project
        #expect(resolved.notes.first { $0.id == "note-open" }?.status == .resolved)

        let reopened = CommandEngine.execute(
            NoteWorkspaceCommandRequest(id: "reopen", action: .reopen, noteIDs: ["note-open"], requestedAt: now),
            project: resolved,
            now: now
        ).project
        #expect(reopened.notes.first { $0.id == "note-open" }?.status == .open)

        let updated = CommandEngine.execute(
            NoteWorkspaceCommandRequest(id: "update", action: .update, noteIDs: ["note-open"], title: "Índice", body: "Niña en el café", requestedAt: now),
            project: reopened,
            now: now
        ).project
        #expect(updated.notes.first { $0.id == "note-open" }?.title == "Índice")
        #expect(updated.notes.first { $0.id == "note-open" }?.body == "Niña en el café")
    }

    @Test("Bulk resolve requires confirmation and snapshot")
    func bulkResolveProtection() {
        let project = fixture()
        let unconfirmed = NoteWorkspaceCommandRequest(id: "bulk", action: .bulkResolve, noteIDs: ["note-open", "note-orphan"], requestedAt: now)
        #expect(CommandEngine.execute(unconfirmed, project: project, now: now).project == project)

        let confirmed = NoteWorkspaceCommandRequest(id: "bulk", action: .bulkResolve, noteIDs: ["note-open", "note-orphan"], confirmed: true, requestedAt: now)
        let failed = CommandEngine.execute(confirmed, project: project, now: now, canCreateSnapshot: false)
        #expect(failed.result.status == .failed)
        #expect(failed.project == project)

        let result = CommandEngine.execute(confirmed, project: project, now: now)
        #expect(result.result.status == .succeeded)
        #expect(result.result.snapshotID == "snapshot-bulk")
        #expect(result.project.notes.filter { ["note-open", "note-orphan"].contains($0.id) }.allSatisfy { $0.status == .resolved })
    }

    @Test("Orphan links can be identified and safely unlinked")
    func orphanHandling() {
        let project = fixture()
        let orphan = project.notes.first { $0.id == "note-orphan" }!
        #expect(NotesWorkspace.hasOrphanedLinks(orphan, in: project))
        #expect(NotesWorkspace.navigationTarget(for: orphan, in: project) == nil)

        let request = NoteWorkspaceCommandRequest(id: "unlink", action: .unlinkOrphans, noteIDs: [orphan.id], confirmed: true, requestedAt: now)
        let result = CommandEngine.execute(request, project: project, now: now)
        #expect(result.project.notes.first { $0.id == orphan.id }?.body == orphan.body)
        #expect(result.project.notes.first { $0.id == orphan.id }?.links.isEmpty == true)
        #expect(result.project.snapshots.last?.id == "snapshot-unlink")
    }

    private func fixture() -> DreamJotterProject {
        let screenplay = ScreenplayParser.parse("INT. CAFÉ - NIGHT\n\nSOFÍA\nHola.\n\n[[TODO: polish café beat]]")
        return DreamJotterProject(
            metadata: ProjectMetadata(id: "project-notes", title: "Notes", createdAt: now, modifiedAt: now, schemaVersion: ProjectFactory.currentSchemaVersion, primaryScreenplayID: "screenplay-notes"),
            screenplay: screenplay,
            characters: [CharacterRecord(id: "character-sofia", displayName: "SOFÍA", createdAt: now, updatedAt: now)],
            locations: [LocationRecord(id: "location-cafe", displayName: "CAFÉ", createdAt: now, updatedAt: now)],
            notes: [
                ProjectNote(id: "note-open", title: "Café arc", body: "Revisit the CAFÉ conversation.", links: [NoteLink(targetKind: .character, targetID: "character-sofia")], createdAt: now, updatedAt: now),
                ProjectNote(id: "note-resolved", title: "Done", body: "Resolved note", status: .resolved, createdAt: now, updatedAt: now),
                ProjectNote(id: "note-orphan", title: "Missing link", body: "Keep this content.", links: [NoteLink(targetKind: .location, targetID: "missing-location")], createdAt: now, updatedAt: now)
            ]
        )
    }
}
