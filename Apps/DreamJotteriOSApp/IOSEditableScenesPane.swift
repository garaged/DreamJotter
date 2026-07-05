import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var selectedCard: SceneCard?

    var body: some View {
        VStack {
            IOSScenesPane(project: project)
            if let firstCard = SceneWorkflow.cards(in: project).first {
                Button("Edit First Scene") {
                    selectedCard = firstCard
                }
            }
        }
        .sheet(item: $selectedCard) { card in
            IOSSceneCardEditorSheet(card: card)
        }
    }
}
