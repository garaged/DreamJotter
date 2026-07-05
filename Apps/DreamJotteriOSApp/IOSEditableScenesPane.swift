import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void

    var body: some View {
        IOSScenesPane(project: project)
    }
}
