import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M12.1 Profile Management")
struct ProfileManagementExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_710_000_000)

    @Test("Archive and restore are reversible command-backed operations")
    func archiveAndRestoreProfiles() throws {
        let original = project()
        let archive = ProfileCommandRequest(
            id: "archive-character",
            action: .archive,
            profileKind: .character,
            profileID: "character-sofia",
            requestedAt: now
        )

        let archived = CommandEngine.execute(archive, project: original, now: now)

        #expect(archived.result.status == .succeeded)
        #expect(archived.result.snapshotID == nil)
        #expect(ProfileManagement.activeCharacters(in: archived.project).map(\.id) == ["character-mara"])
        #expect(ProfileManagement.archivedCharacters(in: archived.project).map(\.id) == ["character-sofia"])

        let restore = ProfileCommandRequest(
            id: "restore-character",
            action: .restore,
            profileKind: .character,
            profileID: "character-sofia",
            requestedAt: now
        )
        let restored = CommandEngine.execute(restore, project: archived.project, now: now)

        #expect(restored.result.status == .succeeded)
        #expect(ProfileManagement.activeCharacters(in: restored.project).map(\.id) == ["character-sofia", "character-mara"])
        #expect(ProfileManagement.archivedCharacters(in: restored.project).isEmpty)
        #expect(restored.project.screenplay == original.screenplay)
    }

    @Test("Delete requires confirmation and a successful snapshot")
    func deleteRequiresConfirmationAndSnapshot() {
        let original = project()
        let unconfirmed = ProfileCommandRequest(
            id: "delete-location-unconfirmed",
            action: .delete,
            profileKind: .location,
            profileID: "location-cafe",
            requestedAt: now
        )

        let rejected = CommandEngine.execute(unconfirmed, project: original, now: now)
        #expect(rejected.result.status == .rejected)
        #expect(rejected.project == original)

        let confirmed = ProfileCommandRequest(
            id: "delete-location-confirmed",
            action: .delete,
            profileKind: .location,
            profileID: "location-cafe",
            confirmed: true,
            requestedAt: now
        )
        let snapshotFailed = CommandEngine.execute(confirmed, project: original, now: now, canCreateSnapshot: false)
        #expect(snapshotFailed.result.status == .failed)
        #expect(snapshotFailed.project == original)

        let deleted = CommandEngine.execute(confirmed, project: original, now: now)
        #expect(deleted.result.status == .succeeded)
        #expect(deleted.result.snapshotID == "snapshot-delete-location-confirmed")
        #expect(deleted.project.locations.map(\.id) == ["location-plaza"])
        #expect(deleted.project.snapshots.count == original.snapshots.count + 1)
        #expect(deleted.project.screenplay == original.screenplay)
        #expect(deleted.project.notes.first?.links.isEmpty == true)
    }

    @Test("Character rename preview is deterministic and apply is snapshot protected")
    func characterRenamePreviewAndApply() throws {
        let original = project()
        let preview = ProfileManagement.previewRename(
            profileID: "character-sofia",
            kind: .character,
            proposedName: "SOFÍA CRUZ",
            in: original
        )
        let repeated = ProfileManagement.previewRename(
            profileID: "character-sofia",
            kind: .character,
            proposedName: "SOFÍA CRUZ",
            in: original
        )

        #expect(preview == repeated)
        #expect(preview.affectedElements.map(\.index) == [2, 6])
        #expect(preview.affectedElements.allSatisfy { $0.kind == .characterCue })
        #expect(preview.diagnostics.isEmpty)

        let request = ProfileCommandRequest(
            id: "rename-sofia",
            action: .bulkRename,
            profileKind: .character,
            profileID: "character-sofia",
            proposedName: "SOFÍA CRUZ",
            previewID: preview.id,
            confirmed: true,
            requestedAt: now
        )
        let failed = CommandEngine.execute(request, project: original, now: now, canCreateSnapshot: false)
        #expect(failed.result.status == .failed)
        #expect(failed.project == original)

        let renamed = CommandEngine.execute(request, project: original, now: now)
        #expect(renamed.result.status == .succeeded)
        #expect(renamed.result.affectedElementIndexes == [2, 6])
        #expect(renamed.project.characters.first?.displayName == "SOFÍA CRUZ")
        #expect(renamed.project.screenplay.elements.filter { $0.kind == .characterCue }.map(\.text) == ["SOFÍA CRUZ", "SOFÍA CRUZ", "MARA"])
        #expect(renamed.project.screenplay.characters == ["SOFÍA CRUZ", "MARA"])
        #expect(renamed.project.sceneCards.first?.characters == ["SOFÍA CRUZ"])
        #expect(!renamed.project.ignoredDetectedCharacterKeys.contains("SOFÍA"))
        #expect(renamed.project.snapshots.last?.project.screenplay == original.screenplay)
    }

    @Test("Stale bulk rename preview is rejected without mutation")
    func staleRenamePreviewIsRejected() {
        let original = project()
        let preview = ProfileManagement.previewRename(
            profileID: "character-sofia",
            kind: .character,
            proposedName: "SOFÍA CRUZ",
            in: original
        )
        let stale = ProfileCommandRequest(
            id: "rename-stale",
            action: .bulkRename,
            profileKind: .character,
            profileID: "character-sofia",
            proposedName: "SOFÍA CRUZ",
            previewID: preview.id + "-stale",
            confirmed: true,
            requestedAt: now
        )

        let result = CommandEngine.execute(stale, project: original, now: now)

        #expect(result.result.status == .rejected)
        #expect(result.project == original)
        #expect(result.result.diagnostics == ["The rename preview is stale. Review affected elements again."])
    }

    @Test("Location rename preserves heading prefix and time of day")
    func locationRenamePreservesHeadingStructure() {
        let original = project()
        let preview = ProfileManagement.previewRename(
            profileID: "location-cafe",
            kind: .location,
            proposedName: "CAFÉ CENTRAL",
            in: original
        )

        #expect(preview.affectedElements.map(\.replacementText) == ["INT. CAFÉ CENTRAL - NIGHT"])

        let request = ProfileCommandRequest(
            id: "rename-cafe",
            action: .bulkRename,
            profileKind: .location,
            profileID: "location-cafe",
            proposedName: "CAFÉ CENTRAL",
            previewID: preview.id,
            confirmed: true,
            requestedAt: now
        )
        let renamed = CommandEngine.execute(request, project: original, now: now)

        #expect(renamed.result.status == .succeeded)
        #expect(renamed.project.locations.first?.displayName == "CAFÉ CENTRAL")
        #expect(renamed.project.screenplay.elements.first?.text == "INT. CAFÉ CENTRAL - NIGHT")
        #expect(renamed.project.screenplay.scenes.first == Scene(heading: "INT. CAFÉ CENTRAL - NIGHT", location: "CAFÉ CENTRAL", timeOfDay: "NIGHT"))
        #expect(renamed.project.sceneCards.first?.location == "CAFÉ CENTRAL")
        #expect(renamed.project.sceneCards.first?.sourceSceneHeading == "INT. CAFÉ CENTRAL - NIGHT")
    }

    @Test("Merge rewrites duplicate references and remaps linked notes")
    func mergeProfilesRewritesReferences() {
        let original = project()
        let request = ProfileCommandRequest(
            id: "merge-characters",
            action: .merge,
            profileKind: .character,
            profileID: "character-mara",
            sourceProfileIDs: ["character-sofia"],
            confirmed: true,
            requestedAt: now
        )

        let merged = CommandEngine.execute(request, project: original, now: now)

        #expect(merged.result.status == .succeeded)
        #expect(merged.result.snapshotID == "snapshot-merge-characters")
        #expect(merged.project.characters.map(\.id) == ["character-mara"])
        #expect(merged.project.characters.first?.source == .merged)
        #expect(merged.project.characters.first?.note == "Second lead\n\nLead detective")
        #expect(merged.project.screenplay.elements.filter { $0.kind == .characterCue }.map(\.text) == ["MARA", "MARA", "MARA"])
        #expect(merged.project.notes.first?.links == [NoteLink(targetKind: .character, targetID: "character-mara")])
        #expect(merged.project.sceneCards.first?.characters == ["MARA"])
    }

    @Test("Archive, merge, and Unicode rename persist through package save and reopen")
    func profileChangesPersistThroughPackageStorage() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterM12-\(UUID().uuidString)", isDirectory: true)
        let packageURL = root.appendingPathComponent("Writer Workflow.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let archive = ProfileCommandRequest(
            id: "archive-plaza",
            action: .archive,
            profileKind: .location,
            profileID: "location-plaza",
            requestedAt: now
        )
        var updated = CommandEngine.execute(archive, project: project(), now: now).project

        let preview = ProfileManagement.previewRename(
            profileID: "character-sofia",
            kind: .character,
            proposedName: "SOFÍA NIÑO",
            in: updated
        )
        let rename = ProfileCommandRequest(
            id: "rename-unicode",
            action: .bulkRename,
            profileKind: .character,
            profileID: "character-sofia",
            proposedName: "SOFÍA NIÑO",
            previewID: preview.id,
            confirmed: true,
            requestedAt: now
        )
        updated = CommandEngine.execute(rename, project: updated, now: now).project

        try DreamJotterPackageStore.save(updated, to: packageURL, updatedAt: now)
        let reopened = try #require(DreamJotterPackageStore.load(from: packageURL).project)

        #expect(ProfileManagement.isArchived(profileID: "location-plaza", kind: .location, in: reopened))
        #expect(reopened.characters.first?.displayName == "SOFÍA NIÑO")
        #expect(reopened.screenplay.elements.filter { $0.kind == .characterCue }.first?.text == "SOFÍA NIÑO")
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
        let characters = [
            CharacterRecord(id: "character-sofia", displayName: "SOFÍA", note: "Lead detective", createdAt: now, updatedAt: now),
            CharacterRecord(id: "character-mara", displayName: "MARA", note: "Second lead", createdAt: now, updatedAt: now)
        ]
        let locations = [
            LocationRecord(id: "location-cafe", displayName: "CAFÉ", note: "Opening location", createdAt: now, updatedAt: now),
            LocationRecord(id: "location-plaza", displayName: "PLAZA", note: "Final act", createdAt: now, updatedAt: now)
        ]
        let note = ProjectNote(
            id: "note-character",
            body: "Track this arc.",
            links: [NoteLink(targetKind: .character, targetID: "character-sofia")],
            createdAt: now,
            updatedAt: now
        )
        let cards = [
            SceneCard(
                id: "scene-card-cafe",
                sourceSceneHeading: "INT. CAFÉ - NIGHT",
                title: "Opening",
                location: "CAFÉ",
                timeOfDay: "NIGHT",
                characters: ["SOFÍA"],
                order: 0
            ),
            SceneCard(
                id: "scene-card-plaza",
                sourceSceneHeading: "EXT. PLAZA - DAY",
                title: "Square",
                location: "PLAZA",
                timeOfDay: "DAY",
                characters: ["SOFÍA", "MARA"],
                order: 1
            )
        ]
        return DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-m12",
                title: "Writer Workflow",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-m12"
            ),
            screenplay: screenplay,
            characters: characters,
            ignoredDetectedCharacterKeys: ["SOFÍA"],
            locations: locations,
            ignoredDetectedLocationKeys: ["CAFÉ"],
            notes: [note],
            sceneCards: cards
        )
    }
}
