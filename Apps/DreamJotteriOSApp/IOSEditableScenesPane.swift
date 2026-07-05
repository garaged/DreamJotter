import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    var navigateToScene: (SceneCard) -> Void = { _ in }
    @State private var selectedCard: SceneCard?

    var body: some View {
        List(SceneWorkflow.cards(in: project), id: \.id) { card in
            Button {
                selectedCard = card
            } label: {
                Text(card.title)
            }
        }
        .sheet(item: $selectedCard) { card in
            IOSPersistentSceneCardEditorSheet(card: card) { summary, note, status in
                saveCard(card, summary: summary, note: note, status: status)
            }
        }
    }

    private func saveCard(
        _ card: SceneCard,
        summary: String,
        note: String,
        status: SceneCardStatus
    ) {
        let updated = IOSSceneCardEditing.update(
            project: project,
            card: card,
            summary: summary,
            note: note,
            status: status,
            plotlineTags: card.plotlineTags
        )
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}
