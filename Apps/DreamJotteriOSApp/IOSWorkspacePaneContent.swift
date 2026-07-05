import DreamJotterCore
import SwiftUI

struct IOSWorkspacePaneContent: View {
    let pane: IOSWorkspacePane
    let project: DreamJotterProject

    var body: some View {
        List {
            switch pane {
            case .screenplay:
                Text("Screenplay")
            case .scenes:
                ForEach(Array(project.screenplay.scenes.enumerated()), id: \.offset) { index, scene in
                    Text("\(index + 1). \(scene.location)")
                }
            case .characters:
                ForEach(Array(project.characters.enumerated()), id: \.offset) { _, character in
                    Text(character.displayName)
                }
            case .locations:
                ForEach(project.screenplay.scenes.map(\.location), id: \.self) { location in
                    Text(location)
                }
            case .notes:
                Text("Notes")
            case .review:
                Text("Review")
            }
        }
        .navigationTitle(pane.title)
    }
}
