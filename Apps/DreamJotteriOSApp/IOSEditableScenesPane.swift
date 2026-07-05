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
    }
}
