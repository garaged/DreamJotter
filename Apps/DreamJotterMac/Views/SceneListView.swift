import DreamJotterCore
import SwiftUI

struct SceneListView: View {
    let scenes: [DreamJotterCore.Scene]
    let selectedSceneID: String?
    let selectAction: (Int) -> Void

    init(
        scenes: [DreamJotterCore.Scene],
        selectedSceneID: String? = nil,
        selectAction: @escaping (Int) -> Void = { _ in }
    ) {
        self.scenes = scenes
        self.selectedSceneID = selectedSceneID
        self.selectAction = selectAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scenes")
                .font(.headline)

            if scenes.isEmpty {
                Text("No scenes yet. Add a scene heading in the Script pane, such as INT. ROOM - DAY.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(scenes.enumerated()), id: \.offset) { index, scene in
                    Button {
                        selectAction(index)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(index + 1). \(scene.heading)")
                                    .lineLimit(2)
                                Text(scene.location)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(8)
                        .background(selectedSceneID == "scene-\(index + 1)" ? Color.accentColor.opacity(0.14) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
