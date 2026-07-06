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
                IOSNotesPane(
                    project: $project,
                    commitProjectChange: commitProjectChange,
                    navigateToLink: navigateToNoteLink
                )
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
        openScreenplayText(
            heading,
            title: card.title,
            entityType: .scene,
            entityID: heading,
            id: "scene-navigation-\(card.id)"
        )
    }

    private func navigateToNoteLink(_ link: NoteLink) {
        switch link.targetKind {
        case .project:
            openReviewFinding(navigationFinding(
                id: "note-project-\(link.targetID)",
                title: project.metadata.title,
                entityType: .project,
                entityID: link.targetID,
                range: ScriptTextRange(location: 0, length: 0)
            ))
        case .scene:
            openScreenplayText(
                link.targetID,
                title: link.targetID,
                entityType: .scene,
                entityID: link.targetID,
                id: "note-scene-\(link.targetID)"
            )
        case .character:
            guard let character = project.characters.first(where: { $0.id == link.targetID }) else { return }
            openScreenplayText(
                character.displayName,
                title: character.displayName,
                entityType: .character,
                entityID: character.id,
                id: "note-character-\(character.id)"
            )
        case .location:
            guard let location = project.locations.first(where: { $0.id == link.targetID }) else { return }
            openScreenplayText(
                location.displayName,
                title: location.displayName,
                entityType: .location,
                entityID: location.id,
                id: "note-location-\(location.id)"
            )
        case .screenplayElement:
            guard let index = Int(link.targetID.replacingOccurrences(of: "element-", with: "")),
                  project.screenplay.elements.indices.contains(index) else { return }
            let element = project.screenplay.elements[index]
            openScreenplayText(
                element.text,
                title: "Screenplay Element \(index + 1)",
                entityType: .screenplayElement,
                entityID: link.targetID,
                id: "note-element-\(index)"
            )
        }
    }

    private func openScreenplayText(
        _ value: String,
        title: String,
        entityType: ReviewLinkedEntityType,
        entityID: String,
        id: String
    ) {
        let text = FountainIO.exportScreenplay(project.screenplay)
        let range = (text as NSString).range(of: value)
        guard range.location != NSNotFound else { return }
        openReviewFinding(navigationFinding(
            id: id,
            title: title,
            entityType: entityType,
            entityID: entityID,
            range: ScriptTextRange(location: range.location, length: range.length)
        ))
    }

    private func navigationFinding(
        id: String,
        title: String,
        entityType: ReviewLinkedEntityType,
        entityID: String,
        range: ScriptTextRange
    ) -> ReviewFinding {
        ReviewFinding(
            id: id,
            severity: .info,
            title: title,
            message: "Open linked target in screenplay",
            source: .formatting,
            linkedEntityType: entityType,
            linkedEntityID: entityID,
            scriptRange: range,
            generatedAt: project.metadata.modifiedAt
        )
    }
}
