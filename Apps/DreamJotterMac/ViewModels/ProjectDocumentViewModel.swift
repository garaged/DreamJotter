import DreamJotterCore
import Foundation

struct ProjectDashboardSnapshot: Equatable {
    let title: String
    let logline: String?
    let synopsis: String?
    let sceneCount: Int
    let characterCount: Int
    let noteCount: Int
}

enum NoteLinkTarget: Equatable {
    case project
    case scene(DreamJotterCore.Scene)
}

struct ProjectDocumentViewModel: Equatable {
    private(set) var project: DreamJotterProject
    var scriptText: String {
        didSet {
            reparseScript()
        }
    }
    private(set) var packageURL: URL?

    init(project: DreamJotterProject, packageURL: URL? = nil, scriptText: String? = nil) {
        self.project = project
        self.packageURL = packageURL
        self.scriptText = scriptText ?? FountainIO.exportScreenplay(project.screenplay)
        reparseScript()
    }

    var dashboard: ProjectDashboardSnapshot {
        ProjectDashboardSnapshot(
            title: project.metadata.title,
            logline: project.story.logline?.text.nilIfBlank,
            synopsis: project.story.synopsis?.text.nilIfBlank,
            sceneCount: project.screenplay.scenes.count,
            characterCount: CharacterManager.records(for: project, now: project.metadata.modifiedAt).count,
            noteCount: project.notes.count
        )
    }

    var scenes: [Scene] {
        project.screenplay.scenes
    }

    var characters: [CharacterRecord] {
        CharacterManager.records(for: project, now: project.metadata.modifiedAt)
    }

    var notes: [ProjectNote] {
        project.notes
    }

    var loglineText: String {
        project.story.logline?.text ?? ""
    }

    var synopsisText: String {
        project.story.synopsis?.text ?? ""
    }

    var healthFindings: [HealthFinding] {
        HealthReport.findings(for: project)
    }

    var fountainExportText: String {
        FountainIO.exportScreenplay(project.screenplay)
    }

    mutating func save(to packageURL: URL, now: Date = Date()) throws {
        reparseScript(modifiedAt: now)
        try DreamJotterPackageStore.save(project, to: packageURL, updatedAt: now)
        self.packageURL = packageURL
    }

    func exportFountain(to fileURL: URL) throws {
        try fountainExportText.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    mutating func updateScriptText(_ text: String) {
        scriptText = text
    }

    mutating func refreshParse(now: Date = Date()) {
        reparseScript(modifiedAt: now)
    }

    mutating func updateTitle(_ title: String, now: Date = Date()) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: trimmed.isEmpty ? "Untitled" : trimmed,
            createdAt: project.metadata.createdAt,
            modifiedAt: now,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
        replaceProject(metadata: metadata)
    }

    mutating func updateLogline(_ text: String, now: Date = Date()) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let story = StoryDevelopmentState(
            setup: project.story.setup,
            logline: trimmed.isEmpty ? nil : LoglineRecord(
                id: project.story.logline?.id ?? "logline",
                text: trimmed,
                createdAt: project.story.logline?.createdAt ?? now,
                updatedAt: now
            ),
            synopsis: project.story.synopsis,
            beatSheets: project.story.beatSheets,
            suggestions: project.story.suggestions
        )
        replaceProject(story: story, modifiedAt: now)
    }

    mutating func updateSynopsis(_ text: String, now: Date = Date()) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let story = StoryDevelopmentState(
            setup: project.story.setup,
            logline: project.story.logline,
            synopsis: trimmed.isEmpty ? nil : SynopsisRecord(
                id: project.story.synopsis?.id ?? "synopsis",
                text: trimmed,
                createdAt: project.story.synopsis?.createdAt ?? now,
                updatedAt: now
            ),
            beatSheets: project.story.beatSheets,
            suggestions: project.story.suggestions
        )
        replaceProject(story: story, modifiedAt: now)
    }

    mutating func addNote(title: String, body: String, target: NoteLinkTarget, now: Date = Date()) {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBody.isEmpty else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = ProjectNote(
            id: "note-\(UUID().uuidString)",
            title: trimmedTitle.isEmpty ? nil : trimmedTitle,
            body: trimmedBody,
            links: [noteLink(for: target)],
            createdAt: now,
            updatedAt: now
        )
        replaceProject(notes: project.notes + [note], modifiedAt: now)
    }

    private mutating func reparseScript(modifiedAt: Date? = nil) {
        let parsed = ScreenplayParser.parse(scriptText)
        let updatedMetadata = metadata(modifiedAt: modifiedAt)
        project = DreamJotterProject(
            metadata: updatedMetadata,
            screenplay: parsed,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }

    private func noteLink(for target: NoteLinkTarget) -> NoteLink {
        switch target {
        case .project:
            return NoteLink(targetKind: .project, targetID: project.metadata.id)
        case .scene(let scene):
            return NoteLink(targetKind: .scene, targetID: scene.heading)
        }
    }

    private func metadata(modifiedAt: Date?) -> ProjectMetadata {
        guard let modifiedAt else { return project.metadata }
        return ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
    }

    private mutating func replaceProject(
        metadata: ProjectMetadata? = nil,
        notes: [ProjectNote]? = nil,
        story: StoryDevelopmentState? = nil,
        modifiedAt: Date? = nil
    ) {
        project = DreamJotterProject(
            metadata: metadata ?? self.metadata(modifiedAt: modifiedAt),
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
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

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
