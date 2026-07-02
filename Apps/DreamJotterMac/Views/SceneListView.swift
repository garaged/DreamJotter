import DreamJotterCore
import SwiftUI

struct SceneListView: View {
    let sceneCards: [SceneCard]
    let selectedSceneID: String?
    let selectAction: (Int) -> Void
    let updateStatusAction: (SceneCard, SceneCardStatus) -> Void

    init(
        sceneCards: [SceneCard],
        selectedSceneID: String? = nil,
        selectAction: @escaping (Int) -> Void = { _ in },
        updateStatusAction: @escaping (SceneCard, SceneCardStatus) -> Void = { _, _ in }
    ) {
        self.sceneCards = sceneCards
        self.selectedSceneID = selectedSceneID
        self.selectAction = selectAction
        self.updateStatusAction = updateStatusAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scenes")
                .font(.headline)

            if sceneCards.isEmpty {
                Text("No scenes yet. Add a scene heading in the Script pane, such as INT. ROOM - DAY.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sceneCards, id: \.id) { card in
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            selectAction(card.order)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(card.order + 1). \(card.title)")
                                        .lineLimit(2)
                                    Text([card.location, card.timeOfDay].compactMap { $0 }.joined(separator: " - "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding(8)
                            .background(selectedSceneID == "scene-\(card.order + 1)" ? Color.accentColor.opacity(0.14) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)

                        Picker("Status", selection: statusBinding(for: card)) {
                            ForEach(SceneCardStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .labelsHidden()
                    }
                }
            }
        }
    }

    private func statusBinding(for card: SceneCard) -> Binding<SceneCardStatus> {
        Binding(
            get: { card.status },
            set: { updateStatusAction(card, $0) }
        )
    }
}
