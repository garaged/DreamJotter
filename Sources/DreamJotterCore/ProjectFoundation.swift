import Foundation

public struct ProjectMetadata: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let schemaVersion: Int
    public let primaryScreenplayID: String
    public let packageExtension: String

    public init(
        id: String,
        title: String,
        createdAt: Date,
        modifiedAt: Date,
        schemaVersion: Int,
        primaryScreenplayID: String,
        packageExtension: String = ".dreamjotter"
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.schemaVersion = schemaVersion
        self.primaryScreenplayID = primaryScreenplayID
        self.packageExtension = packageExtension
    }
}

public struct DreamJotterProject: Codable, Equatable, Sendable {
    public let metadata: ProjectMetadata
    public let screenplay: ScreenplayDocument
    public let mode: EditorMode
    public let template: ProjectTemplateMetadata?
    public let characters: [CharacterRecord]
    public let notes: [ProjectNote]
    public let inboxItems: [InboxItem]
    public let sceneCards: [SceneCard]
    public let snapshots: [SnapshotRecord]
    public let exportPresets: [ExportPreset]
    public let story: StoryDevelopmentState
    public let pro: ProProjectState

    public init(
        metadata: ProjectMetadata,
        screenplay: ScreenplayDocument,
        mode: EditorMode = .simple,
        template: ProjectTemplateMetadata? = nil,
        characters: [CharacterRecord] = [],
        notes: [ProjectNote] = [],
        inboxItems: [InboxItem] = [],
        sceneCards: [SceneCard] = [],
        snapshots: [SnapshotRecord] = [],
        exportPresets: [ExportPreset] = ExportPresetCatalog.builtInPresets(),
        story: StoryDevelopmentState = StoryDevelopmentState(),
        pro: ProProjectState = ProProjectState()
    ) {
        self.metadata = metadata
        self.screenplay = screenplay
        self.mode = mode
        self.template = template
        self.characters = characters
        self.notes = notes
        self.inboxItems = inboxItems
        self.sceneCards = sceneCards
        self.snapshots = snapshots
        self.exportPresets = exportPresets
        self.story = story
        self.pro = pro
    }

    private enum CodingKeys: String, CodingKey {
        case metadata
        case screenplay
        case mode
        case template
        case characters
        case notes
        case inboxItems
        case sceneCards
        case snapshots
        case exportPresets
        case story
        case pro
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metadata = try container.decode(ProjectMetadata.self, forKey: .metadata)
        screenplay = try container.decode(ScreenplayDocument.self, forKey: .screenplay)
        mode = try container.decodeIfPresent(EditorMode.self, forKey: .mode) ?? .simple
        template = try container.decodeIfPresent(ProjectTemplateMetadata.self, forKey: .template)
        characters = try container.decodeIfPresent([CharacterRecord].self, forKey: .characters) ?? []
        notes = try container.decodeIfPresent([ProjectNote].self, forKey: .notes) ?? []
        inboxItems = try container.decodeIfPresent([InboxItem].self, forKey: .inboxItems) ?? []
        sceneCards = try container.decodeIfPresent([SceneCard].self, forKey: .sceneCards) ?? []
        snapshots = try container.decodeIfPresent([SnapshotRecord].self, forKey: .snapshots) ?? []
        exportPresets = try container.decodeIfPresent([ExportPreset].self, forKey: .exportPresets) ?? ExportPresetCatalog.builtInPresets()
        story = try container.decodeIfPresent(StoryDevelopmentState.self, forKey: .story) ?? StoryDevelopmentState()
        pro = try container.decodeIfPresent(ProProjectState.self, forKey: .pro) ?? ProProjectState()
    }
}

public enum ProjectFactory {
    public static let currentSchemaVersion = 1

    public static func createBlankProject(
        title: String,
        projectID: String,
        screenplayID: String,
        createdAt: Date
    ) -> DreamJotterProject {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let metadata = ProjectMetadata(
            id: projectID,
            title: normalizedTitle.isEmpty ? "Untitled" : normalizedTitle,
            createdAt: createdAt,
            modifiedAt: createdAt,
            schemaVersion: currentSchemaVersion,
            primaryScreenplayID: screenplayID
        )

        return DreamJotterProject(metadata: metadata, screenplay: ScreenplayDocument())
    }

    public static func packageName(for project: DreamJotterProject) -> String {
        "\(project.metadata.title)\(project.metadata.packageExtension)"
    }
}
