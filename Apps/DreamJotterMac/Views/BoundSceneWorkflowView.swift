import DreamJotterCore
import SwiftUI

struct BoundSceneWorkflowView: View {
    @Binding var document: ProjectDocumentViewModel
    let openScriptAction: () -> Void

    var body: some View {
        Text("Scene Workflow")
    }
}
