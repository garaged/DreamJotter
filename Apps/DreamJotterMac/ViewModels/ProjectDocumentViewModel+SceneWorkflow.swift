import DreamJotterCore
import Foundation

extension ProjectDocumentViewModel {
    mutating func updateSceneCard(_ card: SceneCard, summary: String, note: String, status: SceneCardStatus, tags: [String]) {
        guard let heading = card.sourceSceneHeading else { return }
        applySceneWorkflow(
            SceneWorkflowRequest(
                id: "scene-metadata-\(UUID().uuidString)",
                action: .updateMetadata,
                sceneHeading: heading,
                summary: summary,
                note: note,
                status: status,
                plotlineTags: tags,
                requestedAt: Date()
            )
        )
    }

    mutating func reorderScenePlanning(_ headings: [String]) {
        applySceneWorkflow(
            SceneWorkflowRequest(
                id: "scene-planning-\(UUID().uuidString)",
                action: .reorderPlanning,
                orderedSceneHeadings: headings,
                requestedAt: Date()
            )
        )
    }

    mutating func reorderScreenplayScenes(_ headings: [String]) {
        applySceneWorkflow(
            SceneWorkflowRequest(
                id: "scene-screenplay-\(UUID().uuidString)",
                action: .reorderScreenplay,
                orderedSceneHeadings: headings,
                confirmed: true,
                requestedAt: Date()
            ),
            updateScriptText: true
        )
    }

    private mutating func applySceneWorkflow(_ request: SceneWorkflowRequest, updateScriptText: Bool = false) {
        let output = CommandEngine.execute(request, project: project, now: request.requestedAt)
        guard output.result.status == .succeeded else { return }
        self = ProjectDocumentViewModel(
            project: output.project,
            packageURL: packageURL,
            scriptText: updateScriptText ? FountainIO.exportScreenplay(output.project.screenplay) : scriptText,
            isDirty: true
        )
    }
}
