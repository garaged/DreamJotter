import DreamJotterCore
import Foundation

enum IOSWorkspaceProjectEditing {
    static func updatingDashboard(
        _ project: DreamJotterProject,
        title: String,
        logline: String,
        synopsis: String,
        now: Date = Date()
    ) -> DreamJotterProject {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTitle = normalizedTitle.isEmpty ? "Untitled" : normalizedTitle
        let cleanLogline = logline.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSynopsis = synopsis.trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: cleanTitle,
            createdAt: project.metadata.createdAt,
            modifiedAt: now,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
        let story = StoryDevelopmentState(
            setup: project.story.setup,
            logline: cleanLogline.isEmpty ? nil : LoglineRecord(
                id: project.story.logline?.id ?? "logline",
                text: cleanLogline,
                createdAt: project.story.logline?.createdAt ?? now,
                updatedAt: now
            ),
            synopsis: cleanSynopsis.isEmpty ? nil : SynopsisRecord(
                id: project.story.synopsis?.id ?? "synopsis",
                text: cleanSynopsis,
                createdAt: project.story.synopsis?.createdAt ?? now,
                updatedAt: now
            ),
            beatSheets: project.story.beatSheets,
            suggestions: project.story.suggestions
        )
        return replacing(project, metadata: metadata, story: story, modifiedAt: now)
    }

    static func upsertingCharacter(
        _ project: DreamJotterProject,
        existing: CharacterRecord?,
        name: String,
        note: String,
        now: Date = Date()
    ) -> DreamJotterProject {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return project }
        let key = TextNormalization.key(for: trimmed)
        guard !project.characters.contains(where: { $0.id != existing?.id && $0.normalizedKey == key }) else { return project }
        let record = CharacterRecord(
            id: existing?.id ?? "character-\(UUID().uuidString)",
            displayName: trimmed,
            normalizedKey: key,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: existing?.source == .detected ? .manual : (existing?.source ?? .manual),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
        let records = existing == nil
            ? project.characters + [record]
            : project.characters.map { $0.id == record.id ? record : $0 }
        return replacing(project, characters: records, modifiedAt: now)
    }

    static func removingCharacter(_ project: DreamJotterProject, id: String, now: Date = Date()) -> DreamJotterProject {
        replacing(project, characters: project.characters.filter { $0.id != id }, modifiedAt: now)
    }

    static func upsertingLocation(
        _ project: DreamJotterProject,
        existing: LocationRecord?,
        name: String,
        note: String,
        now: Date = Date()
    ) -> DreamJotterProject {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return project }
        let key = TextNormalization.key(for: trimmed)
        guard !project.locations.contains(where: { $0.id != existing?.id && $0.normalizedKey == key }) else { return project }
        let record = LocationRecord(
            id: existing?.id ?? "location-\(UUID().uuidString)",
            displayName: trimmed,
            normalizedKey: key,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: existing?.source == .detected ? .manual : (existing?.source ?? .manual),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
        let records = existing == nil
            ? project.locations + [record]
            : project.locations.map { $0.id == record.id ? record : $0 }
        return replacing(project, locations: records, modifiedAt: now)
    }

    static func removingLocation(_ project: DreamJotterProject, id: String, now: Date = Date()) -> DreamJotterProject {
        replacing(project, locations: project.locations.filter { $0.id != id }, modifiedAt: now)
    }

    static func upsertingNote(
        _ project: DreamJotterProject,
        existing: ProjectNote?,
        title: String,
        body: String,
        now: Date = Date()
    ) -> DreamJotterProject {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBody.isEmpty else { return project }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = ProjectNote(
            id: existing?.id ?? "note-\(UUID().uuidString)",
            title: trimmedTitle.isEmpty ? nil : trimmedTitle,
            body: trimmedBody,
            status: existing?.status ?? .open,
            source: existing?.source ?? .manual,
            links: existing?.links ?? [NoteLink(targetKind: .project, targetID: project.metadata.id)],
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
        let notes = existing == nil
            ? project.notes + [note]
            : project.notes.map { $0.id == note.id ? note : $0 }
        return replacing(project, notes: notes, modifiedAt: now)
    }

    static func settingNoteStatus(
        _ project: DreamJotterProject,
        note: ProjectNote,
        status: ProjectNoteStatus,
        now: Date = Date()
    ) -> DreamJotterProject {
        let updated = ProjectNote(
            id: note.id,
            title: note.title,
            body: note.body,
            status: status,
            source: note.source,
            links: note.links,
            createdAt: note.createdAt,
            updatedAt: now
        )
        return replacing(project, notes: project.notes.map { $0.id == note.id ? updated : $0 }, modifiedAt: now)
    }

    static func removingNote(_ project: DreamJotterProject, id: String, now: Date = Date()) -> DreamJotterProject {
        replacing(project, notes: project.notes.filter { $0.id != id }, modifiedAt: now)
    }

    private static func replacing(
        _ project: DreamJotterProject,
        metadata: ProjectMetadata? = nil,
        characters: [CharacterRecord]? = nil,
        locations: [LocationRecord]? = nil,
        notes: [ProjectNote]? = nil,
        story: StoryDevelopmentState? = nil,
        modifiedAt: Date
    ) -> DreamJotterProject {
        let updatedMetadata = metadata ?? ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
        return DreamJotterProject(
            metadata: updatedMetadata,
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: characters ?? project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: locations ?? project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: notes ?? project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: story ?? project.story,
            pro: project.pro
        )
    }
}

extension NotesIndex {
    static func detectedScriptTodos(in project: DreamJotterProject) -> [ProjectNote] {
        detectedScriptTodos(in: project, now: project.metadata.modifiedAt)
    }
}
