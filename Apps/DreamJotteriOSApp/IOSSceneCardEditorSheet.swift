import DreamJotterCore
import SwiftUI

struct IOSSceneCardEditorSheet: View {
    let card: SceneCard
    @State private var summary: String
    @State private var note: String

    init(card: SceneCard) {
        self.card = card
        _summary = State(initialValue: card.summary)
        _note = State(initialValue: card.note)
    }

    var body: some View {
        Form {
            Text(card.title).font(.headline)
            TextField("Summary", text: $summary, axis: .vertical)
            TextField("Scene note", text: $note, axis: .vertical)
        }
    }
}
