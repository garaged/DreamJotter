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
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(card.order + 1). \(card.title)")
                        .font(.headline)
                    if !card.summary.isEmpty {
                        Text(card.summary).lineLimit(2)
                    }
                }
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .leading) {
                Button {
                    navigateToScene(card)
                } label: {
                    Label("Open", systemImage: "text.cursor")
                }
                .tint(.blue)
            }
        }
        .sheet(item: $selectedCard) { card in
            IOSSceneCardEditorSheet(card: card) { summary, note, status in
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
