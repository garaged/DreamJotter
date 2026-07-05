import DreamJotterCore
import Foundation

enum IOSSceneCardEditing {
    static func update(
        project: DreamJotterProject,
        card: SceneCard,
        summary: String,
        note: String,
        status: SceneCardStatus,
        plotlineTags: [String],
        now: Date = Date()
    ) -> DreamJotterProject {
        var cards = SceneCardBuilder.cards(for: project)
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else {
            return project
        }

        let existing = cards[index]
        cards[index] = SceneCard(
            id: existing.id,
            sourceSceneHeading: existing.sourceSceneHeading,
            title: existing.title,
            location: existing.location,
            timeOfDay: existing.timeOfDay,
            characters: existing.characters,
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            plotlineTags: normalizedTags(plotlineTags),
            order: existing.order
        )

        return copy(project, sceneCards: cards, notes: project.notes, now: now)
    }

    private static func normalizedTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags.compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = TextNormalization.key(for: trimmed)
            guard !trimmed.isEmpty, seen.insert(key).inserted else { return nil }
            return trimmed
        }
    }

    fileprivate static func copy(
        _ project: DreamJotterProject,
        sceneCards: [SceneCard],
        notes: [ProjectNote],
        now: Date
    ) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: project.metadata.id,
                title: project.metadata.title,
                createdAt: project.metadata.createdAt,
                modifiedAt: now,
                schemaVersion: project.metadata.schemaVersion,
                primaryScreenplayID: project.metadata.primaryScreenplayID,
                packageExtension: project.metadata.packageExtension
            ),
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: notes,
            inboxItems: project.inboxItems,
            sceneCards: sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }
}

enum IOSNoteLinkEditing {
    static func update(
        project: DreamJotterProject,
        note: ProjectNote,
        title: String,
        body: String,
        links: [NoteLink],
        now: Date = Date()
    ) -> DreamJotterProject {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBody.isEmpty else { return project }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let updated = ProjectNote(
            id: note.id,
            title: trimmedTitle.isEmpty ? nil : trimmedTitle,
            body: trimmedBody,
            status: note.status,
            source: note.source,
            links: links.isEmpty
                ? [NoteLink(targetKind: .project, targetID: project.metadata.id)]
                : links,
            createdAt: note.createdAt,
            updatedAt: now
        )

        let notes = project.notes.map { $0.id == updated.id ? updated : $0 }
        return IOSSceneCardEditing.copy(
            project,
            sceneCards: project.sceneCards,
            notes: notes,
            now: now
        )
    }
}
