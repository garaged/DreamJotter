import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M12.1 Profile Management")
struct ProfileManagementExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_710_000_000)

    @Test("Archive and restore are reversible")
    func archiveAndRestore() {
        let original = project()
        let archive = ProfileCommandRequest(id: "archive", action: .archive, profileKind: .character, profileID: "character-sofia", requestedAt: now)
        let archived = CommandEngine.execute(archive, project: original, now: now)

        #expect(archived.result.status == .succeeded)
        #expect(ProfileManagement.archivedCharacters(in: archived.project).map(\.id) == ["character-sofia"])
        #expect(archived.project.screenplay == original.screenplay)

        let restore = ProfileCommandRequest(id: "restore", action: .restore, profileKind: .character, profileID: "character-sofia", requestedAt: now)
        let restored = CommandEngine.execute(restore, project: archived.project, now: now)

        #expect(restored.result.status == .succeeded)
        #expect(ProfileManagement.archivedCharacters(in: restored.project).isEmpty)
    }

    @Test("Profile removal requires confirmation and snapshot protection")
    func removalRequiresConfirmationAndSnapshot() {
        let original = project()
        let unconfirmed = ProfileCommandRequest(id: "remove-unconfirmed", action: .delete, profileKind: .location, profileID: "location-cafe", requestedAt: now)
        #expect(CommandEngine.execute(unconfirmed, project: original, now: now).project == original)

        let confirmed = ProfileCommandRequest(id: "remove-confirmed", action: .delete, profileKind: .location, profileID: "location-cafe", confirmed: true, requestedAt: now)
        let failed = CommandEngine.execute(confirmed, project: original, now: now, canCreateSnapshot: false)
        #expect(failed.result.status == .failed)
        #expect(failed.project == original)

        let removed = CommandEngine.execute(confirmed, project: original, now: now)
        #expect(removed.result.status == .succeeded)
        #expect(removed.project.locations.map(\.id) == ["location-plaza"])
        #expect(removed.project.snapshots.count == 1)
        #expect(removed.project.screenplay == original.screenplay)
        #expect(removed.project.notes.first?.links == [NoteLink(targetKind: .character, targetID: "character-sofia")])
    }

    @Test("Rename preview is deterministic and stale previews are rejected")
    func renamePreviewAndApply() {
        let original = project()
        let preview = ProfileManagement.previewRename(profileID: "character-sofia", kind: .character, proposedName: "SOFÍA CRUZ", in: original)
        let repeated = ProfileManagement.previewRename(profileID: "character-sofia", kind: .character, proposedName: "SOFÍA CRUZ", in: original)

        #expect(preview == repeated)
        #expect(preview.affectedElements.map(\.index) == [2, 6])

        let stale = ProfileCommandRequest(id: "stale", action: .bulkRename, profileKind: .character, profileID: "character-sofia", proposedName: "SOFÍA CRUZ", previewID: preview.id + "-stale", confirmed: true, requestedAt: now)
        #expect(CommandEngine.execute(stale, project: original, now: now).project == original)

        let apply = ProfileCommandRequest(id: "rename", action: .bulkRename, profileKind: .character, profileID: "character-sofia", proposedName: "SOFÍA CRUZ", previewID: preview.id, confirmed: true, requestedAt: now)
        let renamed = CommandEngine.execute(apply, project: original, now: now)

        #expect(renamed.result.status == .succeeded)
        #expect(renamed.project.characters.first?.displayName == "SOFÍA CRUZ")
        #expect(renamed.project.screenplay.elements.filter { $0.kind == .characterCue }.map(\.text) == ["SOFÍA CRUZ", "SOFÍA CRUZ", "MARA"])
        #expect(renamed.project.sceneCards.first?.characters == ["SOFÍA CRUZ"])
        #expect(renamed.project.snapshots.last?.project.screenplay == original.screenplay)
    }

    @Test("Location rename preserves heading structure")
    func locationRename() {
        let original = project()
        let preview = ProfileManagement.previewRename(profileID: "location-cafe", kind: .location, proposedName: "CAFÉ CENTRAL", in: original)
        #expect(preview.affectedElements.map(\.replacementText) == ["INT. CAFÉ CENTRAL - NIGHT"])

        let request = ProfileCommandRequest(id: "rename-location", action: .bulkRename, profileKind: .location, profileID: "location-cafe", proposedName: "CAFÉ CENTRAL", previewID: preview.id, confirmed: true, requestedAt: now)
        let renamed = CommandEngine.execute(request, project: original, now: now)

        #expect(renamed.project.screenplay.elements.first?.text == "INT. CAFÉ CENTRAL - NIGHT")
        #expect(renamed.project.screenplay.scenes.first == Scene(heading: "INT. CAFÉ CENTRAL - NIGHT", location: "CAFÉ CENTRAL", timeOfDay: "NIGHT"))
    }

    @Test("Merge rewrites references and remaps linked notes")
    func mergeProfiles() {
        let request = ProfileCommandRequest(id: "merge", action: .merge, profileKind: .character, profileID: "character-mara", sourceProfileIDs: ["character-sofia"], confirmed: true, requestedAt: now)
        let merged = CommandEngine.execute(request, project: project(), now: now)

        #expect(merged.result.status == .succeeded)
        #expect(merged.project.characters.map(\.id) == ["character-mara"])
        #expect(merged.project.characters.first?.source == .merged)
        #expect(merged.project.notes.first?.links == [NoteLink(targetKind: .character, targetID: "character-mara")])
        #expect(merged.project.screenplay.elements.filter { $0.kind == .characterCue }.map(\.text) == ["MARA", "MARA", "MARA"])
    }

    @Test("Profile mutations persist through package save and reopen")
    func persistence() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterM12-\(UUID().uuidString)", isDirectory: true)
        let packageURL = root.appendingPathComponent("Writer Workflow.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let archived = CommandEngine.execute(
            ProfileCommandRequest(id: "archive-plaza", action: .archive, profileKind: .location, profileID: "location-plaza", requestedAt: now),
            project: project(),
            now: now
        ).project
        let preview = ProfileManagement.previewRename(profileID: "character-sofia", kind: .character, proposedName: "SOFÍA NIÑO", in: archived)
        let updated = CommandEngine.execute(
            ProfileCommandRequest(id: "rename-unicode", action: .bulkRename, profileKind: .character, profileID: "character-sofia", proposedName: "SOFÍA NIÑO", previewID: preview.id, confirmed: true, requestedAt: now),
            project: archived,
            now: now
        ).project

        try DreamJotterPackageStore.save(updated, to: packageURL, updatedAt: now)
        let reopened = try #require(DreamJotterPackageStore.load(from: packageURL).project)

        #expect(ProfileManagement.isArchived(profileID: "location-plaza", kind: .location, in: reopened))
        #expect(reopened.characters.first?.displayName == "SOFÍA NIÑO")
        #expect(reopened.snapshots.count == updated.snapshots.count)
    }

    private func project() -> DreamJotterProject {
        let screenplay = ScreenplayDocument(
            elements: [
                ScriptElement(kind: .sceneHeading, text: "INT. CAFÉ - NIGHT"),
                ScriptElement(kind: .action, text: "Rain taps the window."),
                ScriptElement(kind: .characterCue, text: "SOFÍA", characterName: "SOFÍA"),
                ScriptElement(kind: .dialogue, text: "Estamos listas."),
                ScriptElement(kind: .sceneHeading, text: "EXT. PLAZA - DAY"),
                ScriptElement(kind: .action, text: "The square fills."),
                ScriptElement(kind: .characterCue, text: "SOFÍA", characterName: "SOFÍA"),
                ScriptElement(kind: .dialogue, text: "Ahora."),
                ScriptElement(kind: .characterCue, text: "MARA", characterName: "MARA"),
                ScriptElement(kind: .dialogue, text: "Go.")
            ],
            scenes: [
                Scene(heading: "INT. CAFÉ - NIGHT", location: "CAFÉ", timeOfDay: "NIGHT"),
                Scene(heading: "EXT. PLAZA - DAY", location: "PLAZA", timeOfDay: "DAY")
            ],
            characters: ["SOFÍA", "MARA"]
        )
        return DreamJotterProject(
            metadata: ProjectMetadata(id: "project-m12", title: "Writer Workflow", createdAt: now, modifiedAt: now, schemaVersion: ProjectFactory.currentSchemaVersion, primaryScreenplayID: "screenplay-m12"),
            screenplay: screenplay,
            characters: [
                CharacterRecord(id: "character-sofia", displayName: "SOFÍA", note: "Lead detective", createdAt: now, updatedAt: now),
                CharacterRecord(id: "character-mara", displayName: "MARA", note: "Second lead", createdAt: now, updatedAt: now)
            ],
            ignoredDetectedCharacterKeys: ["SOFÍA"],
            locations: [
                LocationRecord(id: "location-cafe", displayName: "CAFÉ", note: "Opening location", createdAt: now, updatedAt: now),
                LocationRecord(id: "location-plaza", displayName: "PLAZA", note: "Final act", createdAt: now, updatedAt: now)
            ],
            ignoredDetectedLocationKeys: ["CAFÉ"],
            notes: [
                ProjectNote(id: "note-character", body: "Track this arc.", links: [NoteLink(targetKind: .character, targetID: "character-sofia")], createdAt: now, updatedAt: now)
            ],
            sceneCards: [
                SceneCard(id: "scene-card-cafe", sourceSceneHeading: "INT. CAFÉ - NIGHT", title: "Opening", location: "CAFÉ", timeOfDay: "NIGHT", characters: ["SOFÍA"], order: 0),
                SceneCard(id: "scene-card-plaza", sourceSceneHeading: "EXT. PLAZA - DAY", title: "Square", location: "PLAZA", timeOfDay: "DAY", characters: ["SOFÍA", "MARA"], order: 1)
            ]
        )
    }
}
