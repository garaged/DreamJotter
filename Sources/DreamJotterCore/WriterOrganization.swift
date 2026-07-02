import Foundation

public struct ProjectTemplateMetadata: Codable, Equatable, Sendable {
    public let id: String
    public let version: String
    public let displayName: String

    public init(id: String, version: String = "1.0.0", displayName: String) {
        self.id = id
        self.version = version
        self.displayName = displayName
    }
}

public enum ProjectTemplateID: String, Codable, Equatable, Sendable {
    case blankScreenplay = "blank-screenplay"
    case shortFilm = "short-film"
    case featureFilm = "feature-film"
}

public struct CharacterRecord: Codable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let normalizedKey: String
    public let note: String
    public let source: CharacterSource
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        displayName: String,
        normalizedKey: String? = nil,
        note: String = "",
        source: CharacterSource = .manual,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey ?? TextNormalization.key(for: displayName)
        self.note = note
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum CharacterSource: String, Codable, Equatable, Sendable {
    case detected
    case manual
    case merged
}

public struct LocationRecord: Codable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let normalizedKey: String
    public let note: String
    public let source: LocationSource
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        displayName: String,
        normalizedKey: String? = nil,
        note: String = "",
        source: LocationSource = .manual,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.displayName = displayName
        self.normalizedKey = normalizedKey ?? TextNormalization.key(for: displayName)
        self.note = note
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum LocationSource: String, Codable, Equatable, Sendable {
    case detected
    case manual
    case merged
}

public enum DetectedCharacterResolutionStatus: String, Codable, Equatable, Sendable {
    case unresolved
    case converted
    case ignored
    case matchedProfile
}

public struct DetectedCharacter: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let normalizedName: String
    public let firstElementID: String?
    public let occurrenceCount: Int
    public let isGenericRole: Bool
    public let resolutionStatus: DetectedCharacterResolutionStatus
    public let matchedCharacterID: String?

    public init(
        id: String,
        name: String,
        normalizedName: String,
        firstElementID: String?,
        occurrenceCount: Int,
        isGenericRole: Bool,
        resolutionStatus: DetectedCharacterResolutionStatus,
        matchedCharacterID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.normalizedName = normalizedName
        self.firstElementID = firstElementID
        self.occurrenceCount = occurrenceCount
        self.isGenericRole = isGenericRole
        self.resolutionStatus = resolutionStatus
        self.matchedCharacterID = matchedCharacterID
    }
}

public enum DetectedLocationResolutionStatus: String, Codable, Equatable, Sendable {
    case unresolved
    case converted
    case ignored
    case matchedProfile
}

public struct DetectedLocation: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let normalizedName: String
    public let firstSceneID: String?
    public let sceneCount: Int
    public let resolutionStatus: DetectedLocationResolutionStatus
    public let matchedLocationID: String?

    public init(
        id: String,
        name: String,
        normalizedName: String,
        firstSceneID: String?,
        sceneCount: Int,
        resolutionStatus: DetectedLocationResolutionStatus,
        matchedLocationID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.normalizedName = normalizedName
        self.firstSceneID = firstSceneID
        self.sceneCount = sceneCount
        self.resolutionStatus = resolutionStatus
        self.matchedLocationID = matchedLocationID
    }
}

public enum NoteTargetKind: String, Codable, Equatable, Sendable {
    case project
    case scene
    case character
    case location
    case screenplayElement
}

public struct NoteLink: Codable, Equatable, Sendable {
    public let targetKind: NoteTargetKind
    public let targetID: String

    public init(targetKind: NoteTargetKind, targetID: String) {
        self.targetKind = targetKind
        self.targetID = targetID
    }
}

public struct ProjectNote: Codable, Equatable, Sendable {
    public let id: String
    public let title: String?
    public let body: String
    public let status: ProjectNoteStatus
    public let source: ProjectNoteSource
    public let links: [NoteLink]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        title: String? = nil,
        body: String,
        status: ProjectNoteStatus = .open,
        source: ProjectNoteSource = .manual,
        links: [NoteLink] = [],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.status = status
        self.source = source
        self.links = links
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum ProjectNoteStatus: String, Codable, Equatable, Sendable {
    case open
    case resolved
    case archived
}

public enum ProjectNoteSource: String, Codable, Equatable, Sendable {
    case manual
    case parsedScriptTodo
    case imported
    case routine
}

public enum InboxItemState: String, Codable, Equatable, Sendable {
    case active
    case resolved
    case archived
}

public struct InboxItem: Codable, Equatable, Sendable {
    public let id: String
    public let body: String
    public let state: InboxItemState
    public let tags: [String]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        body: String,
        state: InboxItemState = .active,
        tags: [String] = [],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.body = body
        self.state = state
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct SceneCard: Codable, Equatable, Sendable {
    public let id: String
    public let sourceSceneHeading: String?
    public let title: String
    public let location: String?
    public let timeOfDay: String?
    public let characters: [String]
    public let summary: String
    public let note: String
    public let status: SceneCardStatus
    public let plotlineTags: [String]
    public let order: Int

    public init(
        id: String,
        sourceSceneHeading: String?,
        title: String,
        location: String? = nil,
        timeOfDay: String? = nil,
        characters: [String] = [],
        summary: String = "",
        note: String = "",
        status: SceneCardStatus = .drafted,
        plotlineTags: [String] = [],
        order: Int
    ) {
        self.id = id
        self.sourceSceneHeading = sourceSceneHeading
        self.title = title
        self.location = location
        self.timeOfDay = timeOfDay
        self.characters = characters
        self.summary = summary
        self.note = note
        self.status = status
        self.plotlineTags = plotlineTags
        self.order = order
    }
}

public enum SceneCardStatus: String, Codable, Equatable, Sendable, CaseIterable {
    case idea
    case outlined
    case drafted
    case needsRewrite
    case reviewed
    case locked
    case ready
}

public struct ProjectWorkspaceSummary: Codable, Equatable, Sendable {
    public let projectTitle: String
    public let logline: String?
    public let synopsis: String?
    public let sceneCount: Int
    public let characterProfileCount: Int
    public let unresolvedDetectedCharacterCount: Int
    public let locationProfileCount: Int
    public let unresolvedDetectedLocationCount: Int
    public let openNotesCount: Int
    public let todoCount: Int
    public let isDirty: Bool
    public let lastSavedAt: Date?

    public init(
        projectTitle: String,
        logline: String?,
        synopsis: String?,
        sceneCount: Int,
        characterProfileCount: Int,
        unresolvedDetectedCharacterCount: Int,
        locationProfileCount: Int,
        unresolvedDetectedLocationCount: Int,
        openNotesCount: Int,
        todoCount: Int,
        isDirty: Bool,
        lastSavedAt: Date?
    ) {
        self.projectTitle = projectTitle
        self.logline = logline
        self.synopsis = synopsis
        self.sceneCount = sceneCount
        self.characterProfileCount = characterProfileCount
        self.unresolvedDetectedCharacterCount = unresolvedDetectedCharacterCount
        self.locationProfileCount = locationProfileCount
        self.unresolvedDetectedLocationCount = unresolvedDetectedLocationCount
        self.openNotesCount = openNotesCount
        self.todoCount = todoCount
        self.isDirty = isDirty
        self.lastSavedAt = lastSavedAt
    }
}

public struct SnapshotRecord: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let createdAt: Date
    public let schemaVersion: Int
    public let project: ProjectSnapshotContent

    public init(id: String, name: String, createdAt: Date, schemaVersion: Int, project: ProjectSnapshotContent) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.schemaVersion = schemaVersion
        self.project = project
    }
}

public struct ProjectSnapshotContent: Codable, Equatable, Sendable {
    public let metadata: ProjectMetadata
    public let screenplay: ScreenplayDocument
    public let mode: EditorMode
    public let template: ProjectTemplateMetadata?
    public let characters: [CharacterRecord]
    public let ignoredDetectedCharacterKeys: [String]
    public let locations: [LocationRecord]
    public let ignoredDetectedLocationKeys: [String]
    public let notes: [ProjectNote]
    public let inboxItems: [InboxItem]
    public let sceneCards: [SceneCard]
    public let exportPresets: [ExportPreset]
    public let story: StoryDevelopmentState
    public let pro: ProProjectState

    public init(project: DreamJotterProject) {
        metadata = project.metadata
        screenplay = project.screenplay
        mode = project.mode
        template = project.template
        characters = project.characters
        ignoredDetectedCharacterKeys = project.ignoredDetectedCharacterKeys
        locations = project.locations
        ignoredDetectedLocationKeys = project.ignoredDetectedLocationKeys
        notes = project.notes
        inboxItems = project.inboxItems
        sceneCards = project.sceneCards
        exportPresets = project.exportPresets
        story = project.story
        pro = project.pro
    }

    private enum CodingKeys: String, CodingKey {
        case metadata
        case screenplay
        case mode
        case template
        case characters
        case ignoredDetectedCharacterKeys
        case locations
        case ignoredDetectedLocationKeys
        case notes
        case inboxItems
        case sceneCards
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
        ignoredDetectedCharacterKeys = try container.decodeIfPresent([String].self, forKey: .ignoredDetectedCharacterKeys) ?? []
        locations = try container.decodeIfPresent([LocationRecord].self, forKey: .locations) ?? []
        ignoredDetectedLocationKeys = try container.decodeIfPresent([String].self, forKey: .ignoredDetectedLocationKeys) ?? []
        notes = try container.decodeIfPresent([ProjectNote].self, forKey: .notes) ?? []
        inboxItems = try container.decodeIfPresent([InboxItem].self, forKey: .inboxItems) ?? []
        sceneCards = try container.decodeIfPresent([SceneCard].self, forKey: .sceneCards) ?? []
        exportPresets = try container.decodeIfPresent([ExportPreset].self, forKey: .exportPresets) ?? ExportPresetCatalog.builtInPresets()
        story = try container.decodeIfPresent(StoryDevelopmentState.self, forKey: .story) ?? StoryDevelopmentState()
        pro = try container.decodeIfPresent(ProProjectState.self, forKey: .pro) ?? ProProjectState()
    }
}

public enum SearchResultType: String, Codable, Equatable, Sendable {
    case screenplay
    case note
    case character
    case location
    case inbox
    case sceneCard
}

public struct SearchResult: Codable, Equatable, Sendable {
    public let type: SearchResultType
    public let sourceID: String
    public let preview: String
    public let navigationTarget: String?

    public init(type: SearchResultType, sourceID: String, preview: String, navigationTarget: String? = nil) {
        self.type = type
        self.sourceID = sourceID
        self.preview = preview
        self.navigationTarget = navigationTarget
    }
}

public enum HealthSeverity: String, Codable, Equatable, Sendable {
    case info
    case advisory
    case warning
}

public struct HealthFinding: Codable, Equatable, Sendable {
    public let id: String
    public let severity: HealthSeverity
    public let message: String
    public let sourceReference: String?
    public let suggestedAction: String?

    public init(
        id: String,
        severity: HealthSeverity,
        message: String,
        sourceReference: String? = nil,
        suggestedAction: String? = nil
    ) {
        self.id = id
        self.severity = severity
        self.message = message
        self.sourceReference = sourceReference
        self.suggestedAction = suggestedAction
    }
}

public enum ExportCapability: String, Codable, Equatable, Sendable {
    case available
    case unavailable
}

public struct ExportPreset: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let format: ExportFormat
    public let availability: ExportCapability
    public let isBuiltIn: Bool
    public let goal: String
    public let allowedFormats: [ExportFormat]
    public let includesNotes: Bool
    public let includesSceneMetadata: Bool
    public let includesCharacterLocationMetadata: Bool
    public let includesUnresolvedDetectedItems: Bool
    public let includesInternalIDs: Bool
    public let includesAppVersion: Bool
    public let filenameSuggestion: String
    public let privacyWarning: String?

    public init(
        id: String,
        title: String,
        format: ExportFormat,
        availability: ExportCapability,
        isBuiltIn: Bool = true,
        goal: String = "",
        allowedFormats: [ExportFormat]? = nil,
        includesNotes: Bool = false,
        includesSceneMetadata: Bool = false,
        includesCharacterLocationMetadata: Bool = false,
        includesUnresolvedDetectedItems: Bool = false,
        includesInternalIDs: Bool = false,
        includesAppVersion: Bool = false,
        filenameSuggestion: String? = nil,
        privacyWarning: String? = nil
    ) {
        self.id = id
        self.title = title
        self.format = format
        self.availability = availability
        self.isBuiltIn = isBuiltIn
        self.goal = goal
        self.allowedFormats = allowedFormats ?? [format]
        self.includesNotes = includesNotes
        self.includesSceneMetadata = includesSceneMetadata
        self.includesCharacterLocationMetadata = includesCharacterLocationMetadata
        self.includesUnresolvedDetectedItems = includesUnresolvedDetectedItems
        self.includesInternalIDs = includesInternalIDs
        self.includesAppVersion = includesAppVersion
        self.filenameSuggestion = filenameSuggestion ?? title
        self.privacyWarning = privacyWarning
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case format
        case availability
        case isBuiltIn
        case goal
        case allowedFormats
        case includesNotes
        case includesSceneMetadata
        case includesCharacterLocationMetadata
        case includesUnresolvedDetectedItems
        case includesInternalIDs
        case includesAppVersion
        case filenameSuggestion
        case privacyWarning
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let format = try container.decode(ExportFormat.self, forKey: .format)
        self.init(
            id: id,
            title: title,
            format: format,
            availability: try container.decodeIfPresent(ExportCapability.self, forKey: .availability) ?? .available,
            isBuiltIn: try container.decodeIfPresent(Bool.self, forKey: .isBuiltIn) ?? true,
            goal: try container.decodeIfPresent(String.self, forKey: .goal) ?? "",
            allowedFormats: try container.decodeIfPresent([ExportFormat].self, forKey: .allowedFormats) ?? [format],
            includesNotes: try container.decodeIfPresent(Bool.self, forKey: .includesNotes) ?? false,
            includesSceneMetadata: try container.decodeIfPresent(Bool.self, forKey: .includesSceneMetadata) ?? false,
            includesCharacterLocationMetadata: try container.decodeIfPresent(Bool.self, forKey: .includesCharacterLocationMetadata) ?? false,
            includesUnresolvedDetectedItems: try container.decodeIfPresent(Bool.self, forKey: .includesUnresolvedDetectedItems) ?? false,
            includesInternalIDs: try container.decodeIfPresent(Bool.self, forKey: .includesInternalIDs) ?? false,
            includesAppVersion: try container.decodeIfPresent(Bool.self, forKey: .includesAppVersion) ?? false,
            filenameSuggestion: try container.decodeIfPresent(String.self, forKey: .filenameSuggestion) ?? title,
            privacyWarning: try container.decodeIfPresent(String.self, forKey: .privacyWarning)
        )
    }
}

public struct DashboardProjectSummary: Codable, Equatable, Sendable {
    public let projectID: String
    public let title: String
    public let packagePath: String
    public let lastOpenedAt: Date?
    public let modifiedAt: Date
    public let status: DashboardProjectStatus

    public init(
        projectID: String,
        title: String,
        packagePath: String,
        lastOpenedAt: Date?,
        modifiedAt: Date,
        status: DashboardProjectStatus
    ) {
        self.projectID = projectID
        self.title = title
        self.packagePath = packagePath
        self.lastOpenedAt = lastOpenedAt
        self.modifiedAt = modifiedAt
        self.status = status
    }
}

public enum DashboardProjectStatus: String, Codable, Equatable, Sendable {
    case available
    case unavailable
    case invalid
}

public enum ModePolicy {
    public static func defaultMode() -> EditorMode {
        .simple
    }

    public static func simpleModeAvailability(for feature: String) -> Bool {
        switch feature {
        case "customFields", "routines", "pluginConfiguration", "advancedExportPresetEditing":
            return false
        default:
            return true
        }
    }
}

public enum TemplateFactory {
    public static func createProject(
        templateID: ProjectTemplateID,
        title: String,
        projectID: String,
        screenplayID: String,
        createdAt: Date
    ) -> DreamJotterProject {
        let base = ProjectFactory.createBlankProject(
            title: title,
            projectID: projectID,
            screenplayID: screenplayID,
            createdAt: createdAt
        )
        let template = ProjectTemplateMetadata(
            id: templateID.rawValue,
            displayName: displayName(for: templateID)
        )

        switch templateID {
        case .blankScreenplay:
            return DreamJotterProject(metadata: base.metadata, screenplay: base.screenplay, template: template)
        case .shortFilm:
            let note = ProjectNote(
                id: "template-note-short-film",
                title: "Short film starter",
                body: "Keep the story focused on one strong turn.",
                createdAt: createdAt,
                updatedAt: createdAt
            )
            return DreamJotterProject(metadata: base.metadata, screenplay: base.screenplay, template: template, notes: [note])
        case .featureFilm:
            let note = ProjectNote(
                id: "template-note-feature-film",
                title: "Feature film starter",
                body: "Track setup, escalation, and resolution as editable planning notes.",
                createdAt: createdAt,
                updatedAt: createdAt
            )
            return DreamJotterProject(metadata: base.metadata, screenplay: base.screenplay, template: template, notes: [note])
        }
    }

    private static func displayName(for templateID: ProjectTemplateID) -> String {
        switch templateID {
        case .blankScreenplay:
            return "Blank Screenplay"
        case .shortFilm:
            return "Short Film"
        case .featureFilm:
            return "Feature Film"
        }
    }
}

public enum CharacterManager {
    public static let genericRoleKeys: Set<String> = [
        "MAN",
        "WOMAN",
        "GUARD",
        "COP",
        "COP #2",
        "VOICE",
        "ANNOUNCER",
        "CROWD",
        "EVERYONE"
    ]

    public static func records(for project: DreamJotterProject, now: Date) -> [CharacterRecord] {
        var records = project.characters
        var existingKeys = Set(records.map(\.normalizedKey))
        let detected = ScreenplayDerivedData.characterSuggestions(from: project.screenplay)

        for suggestion in detected where !existingKeys.contains(suggestion.normalizedKey) {
            records.append(CharacterRecord(
                id: "detected-character-\(suggestion.normalizedKey)",
                displayName: suggestion.displayText,
                normalizedKey: suggestion.normalizedKey,
                source: .detected,
                createdAt: now,
                updatedAt: now
            ))
            existingKeys.insert(suggestion.normalizedKey)
        }

        return records
    }

    public static func detectedCharacters(for project: DreamJotterProject) -> [DetectedCharacter] {
        detectedCharacters(
            in: project.screenplay,
            profiles: project.characters,
            ignoredKeys: project.ignoredDetectedCharacterKeys
        )
    }

    public static func unresolvedDetectedCharacters(for project: DreamJotterProject) -> [DetectedCharacter] {
        detectedCharacters(for: project).filter { $0.resolutionStatus == .unresolved }
    }

    public static func detectedCharacters(
        in document: ScreenplayDocument,
        profiles: [CharacterRecord],
        ignoredKeys: [String] = []
    ) -> [DetectedCharacter] {
        var orderedKeys: [String] = []
        var buckets: [String: (name: String, firstElementID: String, count: Int)] = [:]

        for (index, element) in document.elements.enumerated() where element.kind == .characterCue {
            let name = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else {
                continue
            }

            let key = TextNormalization.key(for: name)
            let elementID = "element-\(index + 1)"
            if let bucket = buckets[key] {
                buckets[key] = (bucket.name, bucket.firstElementID, bucket.count + 1)
            } else {
                orderedKeys.append(key)
                buckets[key] = (name, elementID, 1)
            }
        }

        let ignoredKeySet = Set(ignoredKeys.map(TextNormalization.key(for:)))
        var profileByKey: [String: CharacterRecord] = [:]
        for profile in profiles {
            profileByKey[profile.normalizedKey] = profile
        }

        return orderedKeys.compactMap { key in
            guard let bucket = buckets[key] else {
                return nil
            }

            let matchedProfile = profileByKey[key]
            let status: DetectedCharacterResolutionStatus
            if ignoredKeySet.contains(key) {
                status = .ignored
            } else if matchedProfile != nil {
                status = .matchedProfile
            } else {
                status = .unresolved
            }

            return DetectedCharacter(
                id: "detected-character-\(key)",
                name: bucket.name,
                normalizedName: key,
                firstElementID: bucket.firstElementID,
                occurrenceCount: bucket.count,
                isGenericRole: genericRoleKeys.contains(key),
                resolutionStatus: status,
                matchedCharacterID: matchedProfile?.id
            )
        }
    }

    public static func convertDetectedCharacter(
        named name: String,
        in project: DreamJotterProject,
        now: Date
    ) -> DreamJotterProject {
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = TextNormalization.key(for: displayName)
        guard !displayName.isEmpty else {
            return project
        }

        let filteredIgnoredKeys = project.ignoredDetectedCharacterKeys.filter { TextNormalization.key(for: $0) != key }
        if project.characters.contains(where: { $0.normalizedKey == key }) {
            return copy(project: project, ignoredDetectedCharacterKeys: filteredIgnoredKeys, modifiedAt: now)
        }

        let profile = CharacterRecord(
            id: "character-\(key.lowercased())",
            displayName: displayName,
            normalizedKey: key,
            source: .manual,
            createdAt: now,
            updatedAt: now
        )

        return copy(
            project: project,
            characters: project.characters + [profile],
            ignoredDetectedCharacterKeys: filteredIgnoredKeys,
            modifiedAt: now
        )
    }

    public static func ignoreDetectedCharacter(
        named name: String,
        in project: DreamJotterProject,
        now: Date
    ) -> DreamJotterProject {
        let key = TextNormalization.key(for: name)
        guard !key.isEmpty else {
            return project
        }

        var keys = project.ignoredDetectedCharacterKeys
        if !keys.map(TextNormalization.key(for:)).contains(key) {
            keys.append(key)
        }

        return copy(project: project, ignoredDetectedCharacterKeys: keys, modifiedAt: now)
    }

    private static func copy(
        project: DreamJotterProject,
        characters: [CharacterRecord]? = nil,
        ignoredDetectedCharacterKeys: [String]? = nil,
        modifiedAt: Date
    ) -> DreamJotterProject {
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )

        return DreamJotterProject(
            metadata: metadata,
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: characters ?? project.characters,
            ignoredDetectedCharacterKeys: ignoredDetectedCharacterKeys ?? project.ignoredDetectedCharacterKeys,
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

public enum LocationManager {
    public static func records(for project: DreamJotterProject, now: Date) -> [LocationRecord] {
        var records = project.locations
        var existingKeys = Set(records.map(\.normalizedKey))
        let detected = ScreenplayDerivedData.locationSuggestions(from: project.screenplay)

        for suggestion in detected where !existingKeys.contains(suggestion.normalizedKey) {
            records.append(LocationRecord(
                id: "detected-location-\(suggestion.normalizedKey)",
                displayName: suggestion.displayText,
                normalizedKey: suggestion.normalizedKey,
                source: .detected,
                createdAt: now,
                updatedAt: now
            ))
            existingKeys.insert(suggestion.normalizedKey)
        }

        return records
    }

    public static func detectedLocations(for project: DreamJotterProject) -> [DetectedLocation] {
        detectedLocations(
            in: project.screenplay,
            profiles: project.locations,
            ignoredKeys: project.ignoredDetectedLocationKeys
        )
    }

    public static func unresolvedDetectedLocations(for project: DreamJotterProject) -> [DetectedLocation] {
        detectedLocations(for: project).filter { $0.resolutionStatus == .unresolved }
    }

    public static func detectedLocations(
        in document: ScreenplayDocument,
        profiles: [LocationRecord],
        ignoredKeys: [String] = []
    ) -> [DetectedLocation] {
        var orderedKeys: [String] = []
        var buckets: [String: (name: String, firstSceneID: String, count: Int)] = [:]

        for (index, scene) in document.scenes.enumerated() {
            let name = scene.location.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else {
                continue
            }

            let key = TextNormalization.key(for: name)
            let sceneID = "scene-\(index + 1)"
            if let bucket = buckets[key] {
                buckets[key] = (bucket.name, bucket.firstSceneID, bucket.count + 1)
            } else {
                orderedKeys.append(key)
                buckets[key] = (name, sceneID, 1)
            }
        }

        let ignoredKeySet = Set(ignoredKeys.map(TextNormalization.key(for:)))
        var profileByKey: [String: LocationRecord] = [:]
        for profile in profiles {
            profileByKey[profile.normalizedKey] = profile
        }

        return orderedKeys.compactMap { key in
            guard let bucket = buckets[key] else { return nil }

            let matchedProfile = profileByKey[key]
            let status: DetectedLocationResolutionStatus
            if ignoredKeySet.contains(key) {
                status = .ignored
            } else if matchedProfile != nil {
                status = .matchedProfile
            } else {
                status = .unresolved
            }

            return DetectedLocation(
                id: "detected-location-\(key)",
                name: bucket.name,
                normalizedName: key,
                firstSceneID: bucket.firstSceneID,
                sceneCount: bucket.count,
                resolutionStatus: status,
                matchedLocationID: matchedProfile?.id
            )
        }
    }

    public static func convertDetectedLocation(named name: String, in project: DreamJotterProject, now: Date) -> DreamJotterProject {
        let displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = TextNormalization.key(for: displayName)
        guard !displayName.isEmpty else { return project }

        let filteredIgnoredKeys = project.ignoredDetectedLocationKeys.filter { TextNormalization.key(for: $0) != key }
        if project.locations.contains(where: { $0.normalizedKey == key }) {
            return copy(project: project, ignoredDetectedLocationKeys: filteredIgnoredKeys, modifiedAt: now)
        }

        let profile = LocationRecord(
            id: "location-\(key.lowercased())",
            displayName: displayName,
            normalizedKey: key,
            source: .manual,
            createdAt: now,
            updatedAt: now
        )

        return copy(
            project: project,
            locations: project.locations + [profile],
            ignoredDetectedLocationKeys: filteredIgnoredKeys,
            modifiedAt: now
        )
    }

    public static func ignoreDetectedLocation(named name: String, in project: DreamJotterProject, now: Date) -> DreamJotterProject {
        let key = TextNormalization.key(for: name)
        guard !key.isEmpty else { return project }

        var keys = project.ignoredDetectedLocationKeys
        if !keys.map(TextNormalization.key(for:)).contains(key) {
            keys.append(key)
        }

        return copy(project: project, ignoredDetectedLocationKeys: keys, modifiedAt: now)
    }

    private static func copy(
        project: DreamJotterProject,
        locations: [LocationRecord]? = nil,
        ignoredDetectedLocationKeys: [String]? = nil,
        modifiedAt: Date
    ) -> DreamJotterProject {
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )

        return DreamJotterProject(
            metadata: metadata,
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: locations ?? project.locations,
            ignoredDetectedLocationKeys: ignoredDetectedLocationKeys ?? project.ignoredDetectedLocationKeys,
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

public enum SceneCardBuilder {
    public static func cards(for project: DreamJotterProject) -> [SceneCard] {
        let metadataByHeading = Dictionary(uniqueKeysWithValues: project.sceneCards.compactMap { card in
            card.sourceSceneHeading.map { ($0, card) }
        })

        return project.screenplay.scenes.enumerated().map { index, scene in
            if let existing = metadataByHeading[scene.heading] {
                return SceneCard(
                    id: existing.id,
                    sourceSceneHeading: scene.heading,
                    title: scene.heading,
                    location: scene.location,
                    timeOfDay: scene.timeOfDay,
                    characters: characters(in: scene, project: project),
                    summary: existing.summary,
                    note: existing.note,
                    status: existing.status,
                    plotlineTags: existing.plotlineTags,
                    order: index
                )
            }
            return SceneCard(
                id: "scene-card-\(index)",
                sourceSceneHeading: scene.heading,
                title: scene.heading,
                location: scene.location,
                timeOfDay: scene.timeOfDay,
                characters: characters(in: scene, project: project),
                order: index
            )
        }
    }

    public static func updateStatus(_ status: SceneCardStatus, forSceneHeading heading: String, in project: DreamJotterProject, now: Date) -> DreamJotterProject {
        var cards = cards(for: project)
        if let index = cards.firstIndex(where: { $0.sourceSceneHeading == heading }) {
            let existing = cards[index]
            cards[index] = SceneCard(
                id: existing.id,
                sourceSceneHeading: existing.sourceSceneHeading,
                title: existing.title,
                location: existing.location,
                timeOfDay: existing.timeOfDay,
                characters: existing.characters,
                summary: existing.summary,
                note: existing.note,
                status: status,
                plotlineTags: existing.plotlineTags,
                order: existing.order
            )
        }

        return DreamJotterProject(
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
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: cards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }

    private static func characters(in scene: Scene, project: DreamJotterProject) -> [String] {
        guard let sceneIndex = project.screenplay.scenes.firstIndex(of: scene) else { return [] }
        let nextSceneHeading = project.screenplay.scenes.indices.contains(sceneIndex + 1)
            ? project.screenplay.scenes[sceneIndex + 1].heading
            : nil

        var isInScene = false
        var characters: [String] = []
        for element in project.screenplay.elements {
            if element.kind == .sceneHeading {
                if element.text == scene.heading {
                    isInScene = true
                    continue
                }
                if isInScene && element.text == nextSceneHeading {
                    break
                }
            }
            if isInScene, element.kind == .characterCue, !characters.contains(element.text) {
                characters.append(element.text)
            }
        }
        return characters
    }
}

public enum NotesIndex {
    public static func openNotes(in project: DreamJotterProject) -> [ProjectNote] {
        project.notes.filter { $0.status == .open }
    }

    public static func detectedScriptTodos(in project: DreamJotterProject, now: Date) -> [ProjectNote] {
        project.screenplay.elements.enumerated().compactMap { index, element in
            guard element.kind == .noteReference,
                  let todo = todoText(from: element.text) else {
                return nil
            }
            return ProjectNote(
                id: "script-todo-\(index + 1)",
                title: "Script TODO",
                body: todo,
                status: .open,
                source: .parsedScriptTodo,
                links: [NoteLink(targetKind: .screenplayElement, targetID: "element-\(index + 1)")],
                createdAt: now,
                updatedAt: now
            )
        }
    }

    public static func resolve(noteID: String, in project: DreamJotterProject, now: Date) -> DreamJotterProject {
        let notes = project.notes.map { note in
            guard note.id == noteID else { return note }
            return ProjectNote(
                id: note.id,
                title: note.title,
                body: note.body,
                status: .resolved,
                source: note.source,
                links: note.links,
                createdAt: note.createdAt,
                updatedAt: now
            )
        }
        return DreamJotterProject(
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
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }

    public static func notes(linkedTo link: NoteLink, in project: DreamJotterProject) -> [ProjectNote] {
        project.notes.filter { note in note.links.contains(link) }
    }

    public static func orphanedNotes(in project: DreamJotterProject) -> [ProjectNote] {
        let sceneIDs = Set(project.screenplay.scenes.map(\.heading))
        let characterIDs = Set(CharacterManager.records(for: project, now: project.metadata.modifiedAt).map(\.id))
        return project.notes.filter { note in
            note.links.contains { link in
                switch link.targetKind {
                case .scene:
                    return !sceneIDs.contains(link.targetID)
                case .character:
                    return !characterIDs.contains(link.targetID)
                case .location:
                    return !project.locations.map(\.id).contains(link.targetID)
                case .project, .screenplayElement:
                    return false
                }
            }
        }
    }

    private static func todoText(from text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let uppercased = trimmed.uppercased()
        guard uppercased.hasPrefix("TODO:") else { return nil }
        let value = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

public enum ProjectWorkspaceSummaryBuilder {
    public static func summary(for project: DreamJotterProject, isDirty: Bool = false, lastSavedAt: Date? = nil) -> ProjectWorkspaceSummary {
        ProjectWorkspaceSummary(
            projectTitle: project.metadata.title,
            logline: nilIfBlank(project.story.logline?.text),
            synopsis: nilIfBlank(project.story.synopsis?.text),
            sceneCount: project.screenplay.scenes.count,
            characterProfileCount: project.characters.count,
            unresolvedDetectedCharacterCount: CharacterManager.unresolvedDetectedCharacters(for: project).count,
            locationProfileCount: project.locations.count,
            unresolvedDetectedLocationCount: LocationManager.unresolvedDetectedLocations(for: project).count,
            openNotesCount: NotesIndex.openNotes(in: project).count,
            todoCount: NotesIndex.detectedScriptTodos(in: project, now: project.metadata.modifiedAt).count,
            isDirty: isDirty,
            lastSavedAt: lastSavedAt
        )
    }

    private static func nilIfBlank(_ text: String?) -> String? {
        guard let text else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

public enum InboxIndex {
    public static func activeItems(in project: DreamJotterProject) -> [InboxItem] {
        project.inboxItems.filter { $0.state == .active }
    }
}

public enum ProjectSearch {
    public static func search(_ query: String, in project: DreamJotterProject) -> [SearchResult] {
        let normalizedQuery = TextNormalization.key(for: query)
        guard !normalizedQuery.isEmpty else {
            return []
        }

        var results: [SearchResult] = []

        for (index, element) in project.screenplay.elements.enumerated() where matches(element.text, normalizedQuery) {
            results.append(SearchResult(
                type: .screenplay,
                sourceID: "screenplay-element-\(index)",
                preview: element.text,
                navigationTarget: "screenplay:\(index)"
            ))
        }

        for note in project.notes where matches(note.body, normalizedQuery) || matches(note.title ?? "", normalizedQuery) {
            results.append(SearchResult(type: .note, sourceID: note.id, preview: note.body, navigationTarget: "note:\(note.id)"))
        }

        for character in CharacterManager.records(for: project, now: project.metadata.modifiedAt)
            where matches(character.displayName, normalizedQuery) || matches(character.note, normalizedQuery) {
            results.append(SearchResult(type: .character, sourceID: character.id, preview: character.displayName, navigationTarget: "character:\(character.id)"))
        }

        for location in LocationManager.records(for: project, now: project.metadata.modifiedAt)
            where matches(location.displayName, normalizedQuery) || matches(location.note, normalizedQuery) {
            results.append(SearchResult(type: .location, sourceID: location.id, preview: location.displayName, navigationTarget: "location:\(location.id)"))
        }

        for item in project.inboxItems where matches(item.body, normalizedQuery) {
            results.append(SearchResult(type: .inbox, sourceID: item.id, preview: item.body, navigationTarget: "inbox:\(item.id)"))
        }

        for card in SceneCardBuilder.cards(for: project)
            where matches(card.title, normalizedQuery) || matches(card.summary, normalizedQuery) || matches(card.note, normalizedQuery) {
            results.append(SearchResult(type: .sceneCard, sourceID: card.id, preview: card.title, navigationTarget: "scene:\(card.order)"))
        }

        return results
    }

    private static func matches(_ text: String, _ normalizedQuery: String) -> Bool {
        TextNormalization.key(for: text).contains(normalizedQuery)
    }
}

public enum SnapshotManager {
    public static func createSnapshot(id: String, name: String, project: DreamJotterProject, createdAt: Date) -> SnapshotRecord {
        SnapshotRecord(
            id: id,
            name: name,
            createdAt: createdAt,
            schemaVersion: project.metadata.schemaVersion,
            project: ProjectSnapshotContent(project: project)
        )
    }

    public static func projectByRestoring(_ snapshot: SnapshotRecord, preserving snapshots: [SnapshotRecord] = []) -> DreamJotterProject {
        DreamJotterProject(
            metadata: snapshot.project.metadata,
            screenplay: snapshot.project.screenplay,
            mode: snapshot.project.mode,
            template: snapshot.project.template,
            characters: snapshot.project.characters,
            ignoredDetectedCharacterKeys: snapshot.project.ignoredDetectedCharacterKeys,
            locations: snapshot.project.locations,
            ignoredDetectedLocationKeys: snapshot.project.ignoredDetectedLocationKeys,
            notes: snapshot.project.notes,
            inboxItems: snapshot.project.inboxItems,
            sceneCards: snapshot.project.sceneCards,
            snapshots: snapshots,
            exportPresets: snapshot.project.exportPresets,
            story: snapshot.project.story,
            pro: snapshot.project.pro
        )
    }
}

public enum HealthReport {
    public static func findings(for project: DreamJotterProject) -> [HealthFinding] {
        var findings: [HealthFinding] = []

        if project.metadata.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || project.metadata.title == "Untitled" {
            findings.append(HealthFinding(
                id: "missingTitle",
                severity: .advisory,
                message: "Add a project title when you are ready.",
                suggestedAction: "Rename the project from the dashboard or document header."
            ))
        }

        if project.screenplay.scenes.isEmpty {
            findings.append(HealthFinding(
                id: "noScenes",
                severity: .advisory,
                message: "No scenes have been added yet.",
                suggestedAction: "Start with a scene heading such as INT. ROOM - DAY."
            ))
        }

        for note in NotesIndex.orphanedNotes(in: project) {
            findings.append(HealthFinding(
                id: "orphanedNote",
                severity: .warning,
                message: "A note points to content that is no longer present.",
                sourceReference: note.id,
                suggestedAction: "Review the note link before deleting it."
            ))
        }

        let characters = CharacterManager.records(for: project, now: project.metadata.modifiedAt)
        for pair in possibleCharacterVariants(in: characters) {
            findings.append(HealthFinding(
                id: "possibleCharacterVariant",
                severity: .info,
                message: "\(pair.0.displayName) and \(pair.1.displayName) may be spelling variants.",
                sourceReference: pair.0.id,
                suggestedAction: "Keep both names if intentional, or merge the character records later."
            ))
        }

        return findings
    }

    private static func possibleCharacterVariants(in characters: [CharacterRecord]) -> [(CharacterRecord, CharacterRecord)] {
        var pairs: [(CharacterRecord, CharacterRecord)] = []
        for leftIndex in characters.indices {
            for rightIndex in characters.indices where rightIndex > leftIndex {
                let left = characters[leftIndex]
                let right = characters[rightIndex]
                if left.normalizedKey == right.normalizedKey && left.displayName != right.displayName {
                    pairs.append((left, right))
                }
            }
        }
        return pairs
    }
}

public enum ExportPresetCatalog {
    public static func builtInPresets() -> [ExportPreset] {
        [
            ExportPreset(
                id: "reader-copy",
                title: "Reader Copy",
                format: .fountain,
                availability: .available,
                goal: "Share a clean script with a reader.",
                allowedFormats: [.fountain, .plainText, .markdown, .pdf],
                filenameSuggestion: "Reader Copy"
            ),
            ExportPreset(
                id: "contest-submission",
                title: "Contest Submission",
                format: .fountain,
                availability: .available,
                goal: "Export a clean submission without internal project metadata.",
                allowedFormats: [.fountain, .pdf],
                filenameSuggestion: "Contest Submission"
            ),
            ExportPreset(
                id: "print-script",
                title: "Print Script",
                format: .pdf,
                availability: .unavailable,
                goal: "Create a readable print copy.",
                allowedFormats: [.pdf],
                filenameSuggestion: "Print Script"
            ),
            ExportPreset(
                id: "writer-backup",
                title: "Writer Backup",
                format: .jsonBackup,
                availability: .unavailable,
                goal: "Create a structured backup that can restore the project.",
                allowedFormats: [.jsonBackup],
                includesNotes: true,
                includesSceneMetadata: true,
                includesCharacterLocationMetadata: true,
                includesUnresolvedDetectedItems: true,
                includesInternalIDs: true,
                includesAppVersion: true,
                filenameSuggestion: "Writer Backup",
                privacyWarning: "Backups include private notes, internal IDs, and project metadata."
            ),
            ExportPreset(
                id: "plain-text-archive",
                title: "Plain Text Archive",
                format: .plainText,
                availability: .available,
                goal: "Create a durable readable text archive.",
                allowedFormats: [.plainText],
                filenameSuggestion: "Plain Text Archive"
            )
        ]
    }
}

public enum DashboardBuilder {
    public static func summary(for project: DreamJotterProject, packagePath: String, lastOpenedAt: Date? = nil) -> DashboardProjectSummary {
        DashboardProjectSummary(
            projectID: project.metadata.id,
            title: project.metadata.title,
            packagePath: packagePath,
            lastOpenedAt: lastOpenedAt,
            modifiedAt: project.metadata.modifiedAt,
            status: .available
        )
    }

    public static func unavailableSummary(projectID: String, title: String, packagePath: String, lastOpenedAt: Date? = nil) -> DashboardProjectSummary {
        DashboardProjectSummary(
            projectID: projectID,
            title: title,
            packagePath: packagePath,
            lastOpenedAt: lastOpenedAt,
            modifiedAt: Date(timeIntervalSince1970: 0),
            status: .unavailable
        )
    }
}

public enum TextNormalization {
    public static func key(for value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .uppercased()
    }
}
