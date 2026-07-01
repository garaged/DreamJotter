import DreamJotterCore
import SwiftUI

struct SceneListView: View {
    let scenes: [DreamJotterCore.Scene]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Scenes")
                .font(.headline)

            if scenes.isEmpty {
                Text("No scenes yet. Add a scene heading in the Script pane, such as INT. ROOM - DAY.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(scenes.enumerated()), id: \.offset) { index, scene in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(index + 1). \(scene.heading)")
                            .lineLimit(2)
                        Text(scene.location)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
