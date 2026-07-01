import DreamJotterCore
import SwiftUI

struct SceneListView: View {
    let scenes: [DreamJotterCore.Scene]

    var body: some View {
        if scenes.isEmpty {
            Text("No scenes")
                .foregroundStyle(.secondary)
        } else {
            ForEach(Array(scenes.enumerated()), id: \.offset) { _, scene in
                VStack(alignment: .leading, spacing: 2) {
                    Text(scene.heading)
                        .lineLimit(2)
                    Text(scene.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
