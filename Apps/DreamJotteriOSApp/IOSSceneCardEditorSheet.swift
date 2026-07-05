import DreamJotterCore
import SwiftUI

struct IOSPersistentSceneCardEditorSheet: View {
    let card: SceneCard
    let save: (String, String, SceneCardStatus) -> Void
    @State private var summary: String
    @State private var note: String
    @State private var status: SceneCardStatus

    init(card: SceneCard, save: @escaping (String, String, SceneCardStatus) -> Void) {
        self.card = card
        self.save = save
        _summary = State(initialValue: card.summary)
        _note = State(initialValue: card.note)
        _status = State(initialValue: card.status)
    }

    var body: some View {
        Form {
            Text(card.title).font(.headline)
            Picker("Status", selection: $status) {
                ForEach(SceneCardStatus.allCases, id: \.self) { value in
                    Text(value.rawValue).tag(value)
                }
            }
            TextField("Summary", text: $summary, axis: .vertical)
            TextField("Scene note", text: $note, axis: .vertical)
            Button("Save Scene Card") {
                save(summary, note, status)
            }
        }
    }
}
