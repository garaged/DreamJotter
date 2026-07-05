import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
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
        }
        .sheet(item: $selectedCard) { card in
            IOSSceneCardEditorSheet(card: card)
        }
    }
}
