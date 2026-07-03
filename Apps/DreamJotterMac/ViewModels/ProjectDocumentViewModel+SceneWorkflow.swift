import DreamJotterCore
import Foundation

extension ProjectDocumentViewModel {
    mutating func applySceneWorkflow(_ request: SceneWorkflowRequest, updateScriptText: Bool = false) {
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
