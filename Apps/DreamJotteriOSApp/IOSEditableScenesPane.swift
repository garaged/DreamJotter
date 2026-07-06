import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    var navigateToScene: (SceneCard) -> Void = { _ in }
    @State private var selectedCard: SceneCard?
    @State private var showsEditor = false

    var body: some View {
        List(SceneWorkflow.cards(in: project), id: \.id) { card in
            Button {
                selectedCard = card
                showsEditor = true
            } label: {
                Text(card.title)
            }
        }
        .sheet(isPresented: $showsEditor) {
            if let card = selectedCard {
                IOSPersistentSceneCardEditorSheet(card: card) { summary, note, status in
                    saveCard(card, summary: summary, note: note, status: status)
                }
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
