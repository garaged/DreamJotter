import DreamJotterCore
import SwiftUI

struct BoundSceneWorkflowView: View {
    @Binding var document: ProjectDocumentViewModel
    let openScriptAction: () -> Void

    var body: some View {
        SceneWorkflowView(
            project: document.project,
            selectedSceneID: document.editorNavigationState.selectedSceneID,
            selectAction: openScene,
            updateAction: updateCard,
            planningReorderAction: updatePlanningOrder,
            screenplayReorderAction: updateScriptOrder
        )
    }

    private func openScene(_ card: SceneCard) {
        guard let heading = card.sourceSceneHeading,
              let index = document.scenes.firstIndex(where: { $0.heading == heading }) else {
            return
        }
        document.requestNavigation(toSceneAt: index)
        openScriptAction()
    }

    private func updateCard(_ card: SceneCard, _ summary: String, _ note: String, _ status: SceneCardStatus, _ tags: [String]) {
        document.updateSceneCard(card, summary: summary, note: note, status: status, tags: tags)
    }

    private func updatePlanningOrder(_ headings: [String]) {
        document.reorderScenePlanning(headings)
    }

    private func updateScriptOrder(_ headings: [String]) {
        document.reorderScreenplayScenes(headings)
    }
}
