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

public enum NoteTargetKind: String, Codable, Equatable, Sendable {
    case project
    case scene
    case character
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
    public let links: [NoteLink]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        title: String? = nil,
        body: String,
        links: [NoteLink] = [],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.links = links
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
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
    public let summary: String
    public let note: String
    public let order: Int

    public init(
        id: String,
        sourceSceneHeading: String?,
        title: String,
        summary: String = "",
        note: String = "",
        order: Int
    ) {
        self.id = id
        self.sourceSceneHeading = sourceSceneHeading
        self.title = title
        self.summary = summary
        self.note = note
        self.order = order
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
    public let notes: [ProjectNote]
    public let inboxItems: [InboxItem]
    public let sceneCards: [SceneCard]
    public let exportPresets: [ExportPreset]

    public init(project: DreamJotterProject) {
        metadata = project.metadata
        screenplay = project.screenplay
        mode = project.mode
        template = project.template
        characters = project.characters
        notes = project.notes
        inboxItems = project.inboxItems
        sceneCards = project.sceneCards
        exportPresets = project.exportPresets
    }
}

public enum SearchResultType: String, Codable, Equatable, Sendable {
    case screenplay
    case note
    case character
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

    public init(id: String, title: String, format: ExportFormat, availability: ExportCapability, isBuiltIn: Bool = true) {
        self.id = id
        self.title = title
        self.format = format
        self.availability = availability
        self.isBuiltIn = isBuiltIn
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
                    summary: existing.summary,
                    note: existing.note,
                    order: index
                )
            }
            return SceneCard(
                id: "scene-card-\(index)",
                sourceSceneHeading: scene.heading,
                title: scene.heading,
                order: index
            )
        }
    }
}

public enum NotesIndex {
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
                case .project, .screenplayElement:
                    return false
                }
            }
        }
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
            notes: snapshot.project.notes,
            inboxItems: snapshot.project.inboxItems,
            sceneCards: snapshot.project.sceneCards,
            snapshots: snapshots,
            exportPresets: snapshot.project.exportPresets
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
            ExportPreset(id: "draft-pdf", title: "Draft PDF", format: .pdf, availability: .unavailable),
            ExportPreset(id: "fountain", title: "Fountain", format: .fountain, availability: .available)
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

enum TextNormalization {
    static func key(for value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .uppercased()
    }
}
