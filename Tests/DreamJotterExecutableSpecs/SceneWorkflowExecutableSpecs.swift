import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M12.3 Scene Workflow")
struct SceneWorkflowExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_730_000_000)

    @Test("Metadata update preserves screenplay order and Unicode")
    func metadataUpdate() {
        let project = fixture()
        let originalElements = project.screenplay.elements
        let result = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "metadata",
                action: .updateMetadata,
                sceneHeading: "INT. CAFÉ - DAY",
                summary: "Niña descubre la verdad",
                note: "Revisar el diálogo de Íñigo",
                status: .needsRewrite,
                plotlineTags: ["Misterio", "Familía", "misterio"],
                requestedAt: now
            ),
            project: project,
            now: now
        )

        let card = SceneWorkflow.cards(in: result.project).first { $0.sourceSceneHeading == "INT. CAFÉ - DAY" }
        #expect(result.result.status == .succeeded)
        #expect(result.project.screenplay.elements == originalElements)
        #expect(card?.summary == "Niña descubre la verdad")
        #expect(card?.note == "Revisar el diálogo de Íñigo")
        #expect(card?.status == .needsRewrite)
        #expect(card?.plotlineTags == ["Misterio", "Familía"])
    }

    @Test("Unicode search and filters inspect scene metadata")
    func filtering() {
        let updated = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "filter-metadata",
                action: .updateMetadata,
                sceneHeading: "INT. CAFÉ - DAY",
                summary: "Conversación en el café",
                status: .reviewed,
                plotlineTags: ["Corazón"],
                requestedAt: now
            ),
            project: fixture(),
            now: now
        ).project

        let results = SceneWorkflow.filteredCards(
            in: updated,
            query: SceneWorkflowQuery(text: "cafe", status: .reviewed, plotlineTag: "corazon")
        )
        #expect(results.map(\.sourceSceneHeading) == ["INT. CAFÉ - DAY"])
    }

    @Test("Planning reorder does not alter screenplay")
    func planningReorder() {
        let project = fixture()
        let originalScreenplay = project.screenplay
        let result = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "planning",
                action: .reorderPlanning,
                orderedSceneHeadings: ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"],
                requestedAt: now
            ),
            project: project,
            now: now
        )
        #expect(result.result.status == .succeeded)
        #expect(result.project.screenplay == originalScreenplay)
        #expect(SceneWorkflow.cards(in: result.project).map(\.sourceSceneHeading) == ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"])
        #expect(result.project.snapshots.isEmpty)
    }

    @Test("Screenplay reorder requires confirmation and snapshot")
    func screenplayReorderProtection() {
        let project = fixture()
        let request = SceneWorkflowRequest(
            id: "screenplay-reorder",
            action: .reorderScreenplay,
            orderedSceneHeadings: ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"],
            confirmed: true,
            requestedAt: now
        )

        let unconfirmed = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "unconfirmed",
                action: .reorderScreenplay,
                orderedSceneHeadings: request.orderedSceneHeadings,
                requestedAt: now
            ),
            project: project,
            now: now
        )
        #expect(unconfirmed.result.status == .rejected)
        #expect(unconfirmed.project == project)

        let failed = CommandEngine.execute(request, project: project, now: now, canCreateSnapshot: false)
        #expect(failed.result.status == .failed)
        #expect(failed.project == project)

        let result = CommandEngine.execute(request, project: project, now: now)
        #expect(result.result.status == .succeeded)
        #expect(result.result.snapshotID == "snapshot-screenplay-reorder")
        #expect(result.project.screenplay.scenes.map(\.heading) == ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"])
        #expect(result.project.screenplay.elements.first?.kind == .titlePage)
        #expect(result.project.screenplay.elements.first(where: { $0.kind == .sceneHeading })?.text == "EXT. PARK - NIGHT")
    }

    @Test("Scene workflow persists through save and reopen")
    func persistence() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("DreamJotterM12Scenes-\(UUID().uuidString)", isDirectory: true)
        let packageURL = root.appendingPathComponent("Scenes.dreamjotter", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let metadata = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "persist-metadata",
                action: .updateMetadata,
                sceneHeading: "INT. CAFÉ - DAY",
                summary: "Résumé de la scène",
                note: "Niña e Íñigo",
                status: .reviewed,
                plotlineTags: ["Corazón"],
                requestedAt: now
            ),
            project: fixture(),
            now: now
        ).project
        let planning = CommandEngine.execute(
            SceneWorkflowRequest(
                id: "persist-planning",
                action: .reorderPlanning,
                orderedSceneHeadings: ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"],
                requestedAt: now
            ),
            project: metadata,
            now: now
        ).project

        try DreamJotterPackageStore.save(planning, to: packageURL, updatedAt: now)
        let reopened = try #require(DreamJotterPackageStore.load(from: packageURL).project)
        let cards = SceneWorkflow.cards(in: reopened)
        #expect(cards.map(\.sourceSceneHeading) == ["EXT. PARK - NIGHT", "INT. CAFÉ - DAY"])
        #expect(cards.first { $0.sourceSceneHeading == "INT. CAFÉ - DAY" }?.summary == "Résumé de la scène")
        #expect(cards.first { $0.sourceSceneHeading == "INT. CAFÉ - DAY" }?.plotlineTags == ["Corazón"])
    }

    private func fixture() -> DreamJotterProject {
        let screenplay = ScreenplayDocument(
            elements: [
                ScriptElement(kind: .titlePage, text: "Title: M12"),
                ScriptElement(kind: .sceneHeading, text: "INT. CAFÉ - DAY"),
                ScriptElement(kind: .action, text: "SOFÍA waits."),
                ScriptElement(kind: .characterCue, text: "SOFÍA"),
                ScriptElement(kind: .dialogue, text: "Hola."),
                ScriptElement(kind: .sceneHeading, text: "EXT. PARK - NIGHT"),
                ScriptElement(kind: .action, text: "ÍÑIGO arrives.")
            ],
            scenes: [
                Scene(heading: "INT. CAFÉ - DAY", location: "CAFÉ", timeOfDay: "DAY"),
                Scene(heading: "EXT. PARK - NIGHT", location: "PARK", timeOfDay: "NIGHT")
            ],
            characters: ["SOFÍA"]
        )
        return DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-scenes",
                title: "Scenes",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-scenes"
            ),
            screenplay: screenplay
        )
    }
}
