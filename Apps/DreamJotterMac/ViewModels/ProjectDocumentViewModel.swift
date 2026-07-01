import DreamJotterCore
import Foundation

struct ProjectDashboardSnapshot: Equatable {
    let title: String
    let logline: String?
    let sceneCount: Int
    let characterCount: Int
    let noteCount: Int
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

    private mutating func reparseScript(modifiedAt: Date? = nil) {
        let parsed = ScreenplayParser.parse(scriptText)
        let updatedMetadata: ProjectMetadata
        if let modifiedAt {
            updatedMetadata = ProjectMetadata(
                id: project.metadata.id,
                title: project.metadata.title,
                createdAt: project.metadata.createdAt,
                modifiedAt: modifiedAt,
                schemaVersion: project.metadata.schemaVersion,
                primaryScreenplayID: project.metadata.primaryScreenplayID,
                packageExtension: project.metadata.packageExtension
            )
        } else {
            updatedMetadata = project.metadata
        }
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
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
