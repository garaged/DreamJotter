import DreamJotterCore
import SwiftUI

struct IOSWorkspacePaneContent: View {
    let pane: IOSWorkspacePane
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    let openReviewFinding: (ReviewFinding) -> Void

    var body: some View {
        Group {
            switch pane {
            case .dashboard:
                IOSDashboardPane(project: $project, commitProjectChange: commitProjectChange)
            case .screenplay:
                EmptyView()
            case .scenes:
                IOSScenesPane(project: project)
            case .characters:
                IOSCharactersPane(project: $project, commitProjectChange: commitProjectChange)
            case .locations:
                IOSLocationsPane(project: $project, commitProjectChange: commitProjectChange)
            case .notes:
                IOSNotesPane(project: $project, commitProjectChange: commitProjectChange)
            case .review:
                IOSReviewPane(project: project, openFinding: openReviewFinding)
            case .healthReport:
                IOSHealthReportPane(project: project)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}
