import DreamJotterCore

struct IOSNoteTargetOption: Identifiable {
    let link: NoteLink
    let title: String

    var id: String {
        "\(link.targetKind.rawValue):\(link.targetID)"
    }

    static func entityOptions(for project: DreamJotterProject) -> [IOSNoteTargetOption] {
        var values = [IOSNoteTargetOption(
            link: NoteLink(targetKind: .project, targetID: project.metadata.id),
            title: "Project"
        )]
        values += project.screenplay.scenes.map { scene in
            IOSNoteTargetOption(
                link: NoteLink(targetKind: .scene, targetID: scene.heading),
                title: "Scene: \(scene.heading)"
            )
        }
        values += project.characters.map { character in
            IOSNoteTargetOption(
                link: NoteLink(targetKind: .character, targetID: character.id),
                title: "Character: \(character.displayName)"
            )
        }
        values += project.locations.map { location in
            IOSNoteTargetOption(
                link: NoteLink(targetKind: .location, targetID: location.id),
                title: "Location: \(location.displayName)"
            )
        }
        return values
    }
}
