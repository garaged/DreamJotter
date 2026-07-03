import Foundation

public enum NotesWorkspaceStateFilter: String, Codable, Equatable, Sendable, CaseIterable {
    case all
    case open
    case resolved
    case archived
}

public enum NotesWorkspaceTargetFilter: String, Codable, Equatable, Sendable, CaseIterable {
    case all
    case project
    case scene
    case character
    case location
    case screenplayElement
    case orphaned
}

public struct NotesWorkspaceQuery: Codable, Equatable, Sendable {
    public let text: String
    public let state: NotesWorkspaceStateFilter
    public let target: NotesWorkspaceTargetFilter

    public init(text: String = "", state: NotesWorkspaceStateFilter = .all, target: NotesWorkspaceTargetFilter = .all) {
        self.text = text
        self.state = state
        self.target = target
    }
}

public enum NoteWorkspaceCommandAction: String, Codable, Equatable, Sendable {
    case update
    case delete
    case resolve
    case reopen
    case bulkResolve
    case unlinkOrphans
}

public struct NoteWorkspaceCommandRequest: Codable, Equatable, Sendable {
    public let id: String
    public let action: NoteWorkspaceCommandAction
    public let noteIDs: [String]
    public let title: String?
    public let body: String?
    public let links: [NoteLink]?
    public let confirmed: Bool
    public let requestedAt: Date
    public let requiresSnapshot: Bool

    public init(
        id: String,
        action: NoteWorkspaceCommandAction,
        noteIDs: [String],
        title: String? = nil,
        body: String? = nil,
        links: [NoteLink]? = nil,
        confirmed: Bool = false,
        requestedAt: Date,
        requiresSnapshot: Bool? = nil
    ) {
        self.id = id
        self.action = action
        self.noteIDs = noteIDs
        self.title = title
        self.body = body
        self.links = links
        self.confirmed = confirmed
        self.requestedAt = requestedAt
        self.requiresSnapshot = requiresSnapshot ?? [.delete, .bulkResolve, .unlinkOrphans].contains(action)
    }
}

public struct NoteWorkspaceCommandResult: Codable, Equatable, Sendable {
    public let commandID: String
    public let action: NoteWorkspaceCommandAction
    public let status: CommandStatus
    public let snapshotID: String?
    public let affectedNoteIDs: [String]
    public let diagnostics: [String]
    public let completedAt: Date

    public init(
        commandID: String,
        action: NoteWorkspaceCommandAction,
        status: CommandStatus,
        snapshotID: String? = nil,
        affectedNoteIDs: [String] = [],
        diagnostics: [String] = [],
        completedAt: Date
    ) {
        self.commandID = commandID
        self.action = action
        self.status = status
        self.snapshotID = snapshotID
        self.affectedNoteIDs = affectedNoteIDs
        self.diagnostics = diagnostics
        self.completedAt = completedAt
    }
}

public enum NotesWorkspace {
    public static func filteredNotes(in project: DreamJotterProject, query: NotesWorkspaceQuery) -> [ProjectNote] {
        let searchKey = TextNormalization.key(for: query.text.trimmingCharacters(in: .whitespacesAndNewlines))
        return project.notes.filter { note in
            matchesState(note, filter: query.state)
                && matchesTarget(note, filter: query.target, project: project)
                && matchesSearch(note, searchKey: searchKey)
        }
    }

    public static func unresolvedParsedTodos(in project: DreamJotterProject, now: Date) -> [ProjectNote] {
        LocalizedNotesProjection.unresolvedScriptTodos(in: project, now: now)
    }

    public static func orphanedLinks(for note: ProjectNote, in project: DreamJotterProject) -> [NoteLink] {
        note.links.filter { !linkExists($0, in: project) }
    }

    public static func hasOrphanedLinks(_ note: ProjectNote, in project: DreamJotterProject) -> Bool {
        !orphanedLinks(for: note, in: project).isEmpty
    }

    public static func navigationTarget(for note: ProjectNote, in project: DreamJotterProject) -> NoteLink? {
        note.links.first { linkExists($0, in: project) }
    }

    private static func matchesState(_ note: ProjectNote, filter: NotesWorkspaceStateFilter) -> Bool {
        switch filter {
        case .all: return true
        case .open: return note.status == .open
        case .resolved: return note.status == .resolved
        case .archived: return note.status == .archived
        }
    }

    private static func matchesTarget(_ note: ProjectNote, filter: NotesWorkspaceTargetFilter, project: DreamJotterProject) -> Bool {
        switch filter {
        case .all: return true
        case .orphaned: return hasOrphanedLinks(note, in: project)
        case .project: return note.links.contains { $0.targetKind == .project }
        case .scene: return note.links.contains { $0.targetKind == .scene }
        case .character: return note.links.contains { $0.targetKind == .character }
        case .location: return note.links.contains { $0.targetKind == .location }
        case .screenplayElement: return note.links.contains { $0.targetKind == .screenplayElement }
        }
    }

    private static func matchesSearch(_ note: ProjectNote, searchKey: String) -> Bool {
        guard !searchKey.isEmpty else { return true }
        let material = [note.title ?? "", note.body].joined(separator: " ")
        return TextNormalization.key(for: material).contains(searchKey)
    }

    private static func linkExists(_ link: NoteLink, in project: DreamJotterProject) -> Bool {
        switch link.targetKind {
        case .project:
            return link.targetID == project.metadata.id
        case .scene:
            return project.screenplay.scenes.contains { $0.heading == link.targetID }
        case .character:
            return project.characters.contains { $0.id == link.targetID }
        case .location:
            return project.locations.contains { $0.id == link.targetID }
        case .screenplayElement:
            guard link.targetID.hasPrefix("element-"), let index = Int(link.targetID.dropFirst("element-".count)) else { return false }
            return index > 0 && index <= project.screenplay.elements.count
        }
    }

    fileprivate static func replacingNotes(_ notes: [ProjectNote], in project: DreamJotterProject) -> DreamJotterProject {
        DreamJotterProject(
            metadata: project.metadata,
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }
}

public extension CommandEngine {
    static func execute(
        _ request: NoteWorkspaceCommandRequest,
        project: DreamJotterProject,
        now: Date,
        canCreateSnapshot: Bool = true
    ) -> (project: DreamJotterProject, result: NoteWorkspaceCommandResult) {
        if request.requiresSnapshot && !canCreateSnapshot {
            return failure(request, project: project, now: now, diagnostic: "Snapshot creation failed.")
        }

        let ids = Array(Set(request.noteIDs))
        let existing = project.notes.filter { ids.contains($0.id) }
        guard !ids.isEmpty, existing.count == ids.count else {
            return rejection(request, project: project, now: now, diagnostic: "One or more selected notes do not exist.")
        }

        if [.delete, .bulkResolve, .unlinkOrphans].contains(request.action), !request.confirmed {
            return rejection(request, project: project, now: now, diagnostic: "This note operation requires explicit confirmation.")
        }

        let snapshot = request.requiresSnapshot
            ? SnapshotManager.createSnapshot(id: "snapshot-\(request.id)", name: "Before notes \(request.action.rawValue)", project: project, createdAt: now)
            : nil

        let updatedNotes: [ProjectNote]
        switch request.action {
        case .update:
            guard ids.count == 1, let note = existing.first else {
                return rejection(request, project: project, now: now, diagnostic: "Updating requires exactly one note.")
            }
            let body = (request.body ?? note.body).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !body.isEmpty else {
                return rejection(request, project: project, now: now, diagnostic: "A note body cannot be empty.")
            }
            let title = request.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedNotes = project.notes.map {
                guard $0.id == note.id else { return $0 }
                return ProjectNote(
                    id: note.id,
                    title: title?.isEmpty == true ? nil : (title ?? note.title),
                    body: body,
                    status: note.status,
                    source: note.source,
                    links: request.links ?? note.links,
                    createdAt: note.createdAt,
                    updatedAt: now
                )
            }
        case .delete:
            updatedNotes = project.notes.filter { !ids.contains($0.id) }
        case .resolve, .bulkResolve:
            updatedNotes = project.notes.map { note in
                guard ids.contains(note.id) else { return note }
                return ProjectNote(id: note.id, title: note.title, body: note.body, status: .resolved, source: note.source, links: note.links, createdAt: note.createdAt, updatedAt: now)
            }
        case .reopen:
            updatedNotes = project.notes.map { note in
                guard ids.contains(note.id) else { return note }
                return ProjectNote(id: note.id, title: note.title, body: note.body, status: .open, source: note.source, links: note.links, createdAt: note.createdAt, updatedAt: now)
            }
        case .unlinkOrphans:
            updatedNotes = project.notes.map { note in
                guard ids.contains(note.id) else { return note }
                let links = note.links.filter { NotesWorkspace.orphanedLinks(for: note, in: project).contains($0) == false }
                return ProjectNote(id: note.id, title: note.title, body: note.body, status: note.status, source: note.source, links: links, createdAt: note.createdAt, updatedAt: now)
            }
        }

        var mutated = NotesWorkspace.replacingNotes(updatedNotes, in: project)
        if let snapshot {
            mutated = DreamJotterProject(
                metadata: mutated.metadata,
                screenplay: mutated.screenplay,
                mode: mutated.mode,
                template: mutated.template,
                characters: mutated.characters,
                ignoredDetectedCharacterKeys: mutated.ignoredDetectedCharacterKeys,
                locations: mutated.locations,
                ignoredDetectedLocationKeys: mutated.ignoredDetectedLocationKeys,
                notes: mutated.notes,
                inboxItems: mutated.inboxItems,
                sceneCards: mutated.sceneCards,
                snapshots: mutated.snapshots + [snapshot],
                exportPresets: mutated.exportPresets,
                story: mutated.story,
                pro: mutated.pro
            )
        }

        return (
            mutated,
            NoteWorkspaceCommandResult(
                commandID: request.id,
                action: request.action,
                status: .succeeded,
                snapshotID: snapshot?.id,
                affectedNoteIDs: ids.sorted(),
                completedAt: now
            )
        )
    }

    private static func rejection(_ request: NoteWorkspaceCommandRequest, project: DreamJotterProject, now: Date, diagnostic: String) -> (DreamJotterProject, NoteWorkspaceCommandResult) {
        (project, NoteWorkspaceCommandResult(commandID: request.id, action: request.action, status: .rejected, diagnostics: [diagnostic], completedAt: now))
    }

    private static func failure(_ request: NoteWorkspaceCommandRequest, project: DreamJotterProject, now: Date, diagnostic: String) -> (DreamJotterProject, NoteWorkspaceCommandResult) {
        (project, NoteWorkspaceCommandResult(commandID: request.id, action: request.action, status: .failed, diagnostics: [diagnostic], completedAt: now))
    }
}
