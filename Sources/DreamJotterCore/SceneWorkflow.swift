import Foundation

public struct SceneWorkflowQuery: Codable, Equatable, Sendable {
    public let text: String
    public let status: SceneCardStatus?
    public let plotlineTag: String?

    public init(text: String = "", status: SceneCardStatus? = nil, plotlineTag: String? = nil) {
        self.text = text
        self.status = status
        self.plotlineTag = plotlineTag
    }
}

public enum SceneWorkflowAction: String, Codable, Equatable, Sendable {
    case updateMetadata
    case reorderPlanning
    case reorderScreenplay
}

public struct SceneWorkflowRequest: Codable, Equatable, Sendable {
    public let id: String
    public let action: SceneWorkflowAction
    public let sceneHeading: String?
    public let summary: String?
    public let note: String?
    public let status: SceneCardStatus?
    public let plotlineTags: [String]?
    public let orderedSceneHeadings: [String]?
    public let confirmed: Bool
    public let requestedAt: Date

    public init(
        id: String,
        action: SceneWorkflowAction,
        sceneHeading: String? = nil,
        summary: String? = nil,
        note: String? = nil,
        status: SceneCardStatus? = nil,
        plotlineTags: [String]? = nil,
        orderedSceneHeadings: [String]? = nil,
        confirmed: Bool = false,
        requestedAt: Date
    ) {
        self.id = id
        self.action = action
        self.sceneHeading = sceneHeading
        self.summary = summary
        self.note = note
        self.status = status
        self.plotlineTags = plotlineTags
        self.orderedSceneHeadings = orderedSceneHeadings
        self.confirmed = confirmed
        self.requestedAt = requestedAt
    }
}

public struct SceneWorkflowResult: Codable, Equatable, Sendable {
    public let commandID: String
    public let action: SceneWorkflowAction
    public let status: CommandStatus
    public let snapshotID: String?
    public let affectedSceneHeadings: [String]
    public let diagnostics: [String]
    public let completedAt: Date

    public init(
        commandID: String,
        action: SceneWorkflowAction,
        status: CommandStatus,
        snapshotID: String? = nil,
        affectedSceneHeadings: [String] = [],
        diagnostics: [String] = [],
        completedAt: Date
    ) {
        self.commandID = commandID
        self.action = action
        self.status = status
        self.snapshotID = snapshotID
        self.affectedSceneHeadings = affectedSceneHeadings
        self.diagnostics = diagnostics
        self.completedAt = completedAt
    }
}

public enum SceneWorkflow {
    public static func cards(in project: DreamJotterProject) -> [SceneCard] {
        let storedByHeading = Dictionary(uniqueKeysWithValues: project.sceneCards.compactMap { card in
            card.sourceSceneHeading.map { ($0, card) }
        })

        return project.screenplay.scenes.enumerated().map { screenplayIndex, scene in
            let stored = storedByHeading[scene.heading]
            return SceneCard(
                id: stored?.id ?? "scene-card-\(screenplayIndex)",
                sourceSceneHeading: scene.heading,
                title: scene.heading,
                location: scene.location,
                timeOfDay: scene.timeOfDay,
                characters: characters(in: scene, project: project),
                summary: stored?.summary ?? "",
                note: stored?.note ?? "",
                status: stored?.status ?? .drafted,
                plotlineTags: stored?.plotlineTags ?? [],
                order: stored?.order ?? screenplayIndex
            )
        }
        .sorted { lhs, rhs in
            if lhs.order == rhs.order { return lhs.title < rhs.title }
            return lhs.order < rhs.order
        }
    }

    public static func filteredCards(in project: DreamJotterProject, query: SceneWorkflowQuery) -> [SceneCard] {
        let searchKey = TextNormalization.key(for: query.text.trimmingCharacters(in: .whitespacesAndNewlines))
        let tagKey = query.plotlineTag.map(TextNormalization.key(for:))
        return cards(in: project).filter { card in
            guard query.status == nil || card.status == query.status else { return false }
            if let tagKey, !card.plotlineTags.contains(where: { TextNormalization.key(for: $0) == tagKey }) {
                return false
            }
            guard !searchKey.isEmpty else { return true }
            let material = [
                card.title,
                card.location ?? "",
                card.timeOfDay ?? "",
                card.characters.joined(separator: " "),
                card.summary,
                card.note,
                card.plotlineTags.joined(separator: " ")
            ].joined(separator: " ")
            return TextNormalization.key(for: material).contains(searchKey)
        }
    }

    public static func screenplayReorderPreview(
        orderedSceneHeadings: [String],
        in project: DreamJotterProject
    ) -> [String] {
        guard Set(orderedSceneHeadings) == Set(project.screenplay.scenes.map(\.heading)),
              orderedSceneHeadings.count == project.screenplay.scenes.count else {
            return []
        }
        return orderedSceneHeadings.enumerated().compactMap { index, heading in
            project.screenplay.scenes[index].heading == heading ? nil : heading
        }
    }

    fileprivate static func normalizedTags(_ tags: [String]) -> [String] {
        var seen: Set<String> = []
        return tags.compactMap { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = TextNormalization.key(for: trimmed)
            guard !trimmed.isEmpty, seen.insert(key).inserted else { return nil }
            return trimmed
        }
    }

    private static func characters(in scene: Scene, project: DreamJotterProject) -> [String] {
        guard let sceneIndex = project.screenplay.scenes.firstIndex(of: scene) else { return [] }
        let nextHeading = project.screenplay.scenes.indices.contains(sceneIndex + 1)
            ? project.screenplay.scenes[sceneIndex + 1].heading
            : nil
        var active = false
        var values: [String] = []
        for element in project.screenplay.elements {
            if element.kind == .sceneHeading {
                if element.text == scene.heading {
                    active = true
                    continue
                }
                if active && element.text == nextHeading { break }
            }
            if active, element.kind == .characterCue, !values.contains(element.text) {
                values.append(element.text)
            }
        }
        return values
    }
}

public extension CommandEngine {
    static func execute(
        _ request: SceneWorkflowRequest,
        project: DreamJotterProject,
        now: Date,
        canCreateSnapshot: Bool = true
    ) -> (project: DreamJotterProject, result: SceneWorkflowResult) {
        switch request.action {
        case .updateMetadata:
            guard let heading = request.sceneHeading,
                  project.screenplay.scenes.contains(where: { $0.heading == heading }) else {
                return rejected(request, project: project, now: now, "The selected scene does not exist.")
            }
            let cards = updatedMetadataCards(request, project: project)
            return succeeded(request, project: replacing(project, sceneCards: cards, modifiedAt: now), now: now, affected: [heading])

        case .reorderPlanning:
            guard let headings = request.orderedSceneHeadings,
                  validPermutation(headings, project: project) else {
                return rejected(request, project: project, now: now, "Planning order must contain every scene exactly once.")
            }
            let byHeading = Dictionary(uniqueKeysWithValues: SceneWorkflow.cards(in: project).compactMap { card in
                card.sourceSceneHeading.map { ($0, card) }
            })
            let cards = headings.enumerated().compactMap { order, heading -> SceneCard? in
                guard let card = byHeading[heading] else { return nil }
                return SceneCard(
                    id: card.id,
                    sourceSceneHeading: heading,
                    title: card.title,
                    location: card.location,
                    timeOfDay: card.timeOfDay,
                    characters: card.characters,
                    summary: card.summary,
                    note: card.note,
                    status: card.status,
                    plotlineTags: card.plotlineTags,
                    order: order
                )
            }
            return succeeded(request, project: replacing(project, sceneCards: cards, modifiedAt: now), now: now, affected: headings)

        case .reorderScreenplay:
            guard request.confirmed else {
                return rejected(request, project: project, now: now, "Screenplay reorder requires explicit confirmation.")
            }
            guard canCreateSnapshot else {
                return failed(request, project: project, now: now, "Snapshot creation failed.")
            }
            guard let headings = request.orderedSceneHeadings,
                  validPermutation(headings, project: project) else {
                return rejected(request, project: project, now: now, "Screenplay order must contain every scene exactly once.")
            }
            let snapshot = SnapshotManager.createSnapshot(
                id: "snapshot-\(request.id)",
                name: "Before screenplay scene reorder",
                project: project,
                createdAt: now
            )
            let reordered = reorderedScreenplay(headings: headings, project: project)
            let storedCards = SceneWorkflow.cards(in: project)
            let mutated = DreamJotterProject(
                metadata: modifiedMetadata(project.metadata, now: now),
                screenplay: reordered,
                mode: project.mode,
                template: project.template,
                characters: project.characters,
                ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
                locations: project.locations,
                ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
                notes: project.notes,
                inboxItems: project.inboxItems,
                sceneCards: storedCards,
                snapshots: project.snapshots + [snapshot],
                exportPresets: project.exportPresets,
                story: project.story,
                pro: project.pro
            )
            return (
                mutated,
                SceneWorkflowResult(
                    commandID: request.id,
                    action: request.action,
                    status: .succeeded,
                    snapshotID: snapshot.id,
                    affectedSceneHeadings: SceneWorkflow.screenplayReorderPreview(orderedSceneHeadings: headings, in: project),
                    completedAt: now
                )
            )
        }
    }

    private static func updatedMetadataCards(_ request: SceneWorkflowRequest, project: DreamJotterProject) -> [SceneCard] {
        SceneWorkflow.cards(in: project).map { card in
            guard card.sourceSceneHeading == request.sceneHeading else { return card }
            return SceneCard(
                id: card.id,
                sourceSceneHeading: card.sourceSceneHeading,
                title: card.title,
                location: card.location,
                timeOfDay: card.timeOfDay,
                characters: card.characters,
                summary: request.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? card.summary,
                note: request.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? card.note,
                status: request.status ?? card.status,
                plotlineTags: request.plotlineTags.map(SceneWorkflow.normalizedTags) ?? card.plotlineTags,
                order: card.order
            )
        }
    }

    private static func validPermutation(_ headings: [String], project: DreamJotterProject) -> Bool {
        headings.count == project.screenplay.scenes.count
            && Set(headings) == Set(project.screenplay.scenes.map(\.heading))
    }

    private static func reorderedScreenplay(headings: [String], project: DreamJotterProject) -> ScreenplayDocument {
        let elements = project.screenplay.elements
        let firstSceneIndex = elements.firstIndex(where: { $0.kind == .sceneHeading }) ?? elements.count
        let preamble = Array(elements[..<firstSceneIndex])
        var blocks: [String: [ScriptElement]] = [:]
        var currentHeading: String?
        for element in elements[firstSceneIndex...] {
            if element.kind == .sceneHeading { currentHeading = element.text }
            if let currentHeading { blocks[currentHeading, default: []].append(element) }
        }
        let reorderedElements = preamble + headings.flatMap { blocks[$0] ?? [] }
        let sceneByHeading = Dictionary(uniqueKeysWithValues: project.screenplay.scenes.map { ($0.heading, $0) })
        return ScreenplayDocument(
            elements: reorderedElements,
            scenes: headings.compactMap { sceneByHeading[$0] },
            characters: project.screenplay.characters,
            diagnostics: project.screenplay.diagnostics
        )
    }

    private static func replacing(_ project: DreamJotterProject, sceneCards: [SceneCard], modifiedAt: Date) -> DreamJotterProject {
        DreamJotterProject(
            metadata: modifiedMetadata(project.metadata, now: modifiedAt),
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
    }

    private static func modifiedMetadata(_ metadata: ProjectMetadata, now: Date) -> ProjectMetadata {
        ProjectMetadata(
            id: metadata.id,
            title: metadata.title,
            createdAt: metadata.createdAt,
            modifiedAt: now,
            schemaVersion: metadata.schemaVersion,
            primaryScreenplayID: metadata.primaryScreenplayID,
            packageExtension: metadata.packageExtension
        )
    }

    private static func succeeded(_ request: SceneWorkflowRequest, project: DreamJotterProject, now: Date, affected: [String]) -> (DreamJotterProject, SceneWorkflowResult) {
        (project, SceneWorkflowResult(commandID: request.id, action: request.action, status: .succeeded, affectedSceneHeadings: affected, completedAt: now))
    }

    private static func rejected(_ request: SceneWorkflowRequest, project: DreamJotterProject, now: Date, _ diagnostic: String) -> (DreamJotterProject, SceneWorkflowResult) {
        (project, SceneWorkflowResult(commandID: request.id, action: request.action, status: .rejected, diagnostics: [diagnostic], completedAt: now))
    }

    private static func failed(_ request: SceneWorkflowRequest, project: DreamJotterProject, now: Date, _ diagnostic: String) -> (DreamJotterProject, SceneWorkflowResult) {
        (project, SceneWorkflowResult(commandID: request.id, action: request.action, status: .failed, diagnostics: [diagnostic], completedAt: now))
    }
}
