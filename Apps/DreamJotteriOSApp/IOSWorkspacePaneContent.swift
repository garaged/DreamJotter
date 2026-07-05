import DreamJotterCore
import Foundation
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
                IOSEditableScenesPane(
                    project: $project,
                    commitProjectChange: commitProjectChange,
                    navigateToScene: navigateToScene
                )
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

    private func navigateToScene(_ card: SceneCard) {
        guard let heading = card.sourceSceneHeading else { return }
        let text = FountainIO.exportScreenplay(project.screenplay)
        let range = (text as NSString).range(of: heading)
        guard range.location != NSNotFound else { return }

        openReviewFinding(ReviewFinding(
            id: "scene-navigation-\(card.id)",
            severity: .info,
            title: card.title,
            message: "Open scene in screenplay",
            source: .formatting,
            linkedEntityType: .scene,
            linkedEntityID: heading,
            scriptRange: ScriptTextRange(location: range.location, length: range.length),
            generatedAt: project.metadata.modifiedAt
        ))
    }
}
