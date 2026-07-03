import Foundation

public enum ProfileKind: String, Codable, Equatable, Sendable {
    case character
    case location
}

public enum ProfileCommandAction: String, Codable, Equatable, Sendable {
    case archive
    case restore
    case delete
    case merge
    case bulkRename
}

public struct ProfileCommandRequest: Codable, Equatable, Sendable {
    public let id: String
    public let action: ProfileCommandAction
    public let profileKind: ProfileKind
    public let profileID: String
    public let sourceProfileIDs: [String]
    public let proposedName: String?
    public let previewID: String?
    public let confirmed: Bool
    public let requestedAt: Date
    public let requiresSnapshot: Bool

    public init(
        id: String,
        action: ProfileCommandAction,
        profileKind: ProfileKind,
        profileID: String,
        sourceProfileIDs: [String] = [],
        proposedName: String? = nil,
        previewID: String? = nil,
        confirmed: Bool = false,
        requestedAt: Date,
        requiresSnapshot: Bool? = nil
    ) {
        self.id = id
        self.action = action
        self.profileKind = profileKind
        self.profileID = profileID
        self.sourceProfileIDs = sourceProfileIDs
        self.proposedName = proposedName
        self.previewID = previewID
        self.confirmed = confirmed
        self.requestedAt = requestedAt
        self.requiresSnapshot = requiresSnapshot ?? [.delete, .merge, .bulkRename].contains(action)
    }
}

public struct ProfileAffectedElement: Codable, Equatable, Sendable {
    public let index: Int
    public let kind: ScriptElementKind
    public let originalText: String
    public let replacementText: String

    public init(index: Int, kind: ScriptElementKind, originalText: String, replacementText: String) {
        self.index = index
        self.kind = kind
        self.originalText = originalText
        self.replacementText = replacementText
    }
}

public struct ProfileRenamePreview: Codable, Equatable, Sendable {
    public let id: String
    public let profileKind: ProfileKind
    public let profileID: String
    public let currentName: String
    public let proposedName: String
    public let affectedElements: [ProfileAffectedElement]
    public let diagnostics: [String]

    public init(
        id: String,
        profileKind: ProfileKind,
        profileID: String,
        currentName: String,
        proposedName: String,
        affectedElements: [ProfileAffectedElement],
        diagnostics: [String]
    ) {
        self.id = id
        self.profileKind = profileKind
        self.profileID = profileID
        self.currentName = currentName
        self.proposedName = proposedName
        self.affectedElements = affectedElements
        self.diagnostics = diagnostics
    }
}

public struct ProfileCommandResult: Codable, Equatable, Sendable {
    public let commandID: String
    public let action: ProfileCommandAction
    public let status: CommandStatus
    public let snapshotID: String?
    public let affectedProfileIDs: [String]
    public let affectedElementIndexes: [Int]
    public let diagnostics: [String]
    public let completedAt: Date

    public init(
        commandID: String,
        action: ProfileCommandAction,
        status: CommandStatus,
        snapshotID: String? = nil,
        affectedProfileIDs: [String] = [],
        affectedElementIndexes: [Int] = [],
        diagnostics: [String] = [],
        completedAt: Date
    ) {
        self.commandID = commandID
        self.action = action
        self.status = status
        self.snapshotID = snapshotID
        self.affectedProfileIDs = affectedProfileIDs
        self.affectedElementIndexes = affectedElementIndexes
        self.diagnostics = diagnostics
        self.completedAt = completedAt
    }
}

public enum ProfileManagement {
    private static let archiveDefinitionID = "__dreamjotter.profileArchive"

    public static func isArchived(profileID: String, kind: ProfileKind, in project: DreamJotterProject) -> Bool {
        project.pro.customFieldValues.contains {
            $0.definitionID == archiveDefinitionID &&
            $0.targetKind == .project &&
            $0.targetID == archiveTargetID(profileID: profileID, kind: kind) &&
            $0.value == .boolean(true)
        }
    }

    public static func activeCharacters(in project: DreamJotterProject) -> [CharacterRecord] {
        project.characters.filter { !isArchived(profileID: $0.id, kind: .character, in: project) }
    }

    public static func archivedCharacters(in project: DreamJotterProject) -> [CharacterRecord] {
        project.characters.filter { isArchived(profileID: $0.id, kind: .character, in: project) }
    }

    public static func activeLocations(in project: DreamJotterProject) -> [LocationRecord] {
        project.locations.filter { !isArchived(profileID: $0.id, kind: .location, in: project) }
    }

    public static func archivedLocations(in project: DreamJotterProject) -> [LocationRecord] {
        project.locations.filter { isArchived(profileID: $0.id, kind: .location, in: project) }
    }

    public static func previewRename(
        profileID: String,
        kind: ProfileKind,
        proposedName: String,
        in project: DreamJotterProject
    ) -> ProfileRenamePreview {
        let trimmedName = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = profileName(profileID: profileID, kind: kind, in: project) ?? ""
        var diagnostics: [String] = []

        if currentName.isEmpty {
            diagnostics.append("The selected profile does not exist.")
        }
        if trimmedName.isEmpty {
            diagnostics.append("The new profile name cannot be empty.")
        }
        if normalizedKey(trimmedName) != normalizedKey(currentName), profileWithName(trimmedName, kind: kind, excluding: profileID, in: project) != nil {
            diagnostics.append("Another profile already uses the proposed normalized name.")
        }

        let affected = affectedElements(
            kind: kind,
            names: currentName.isEmpty ? [] : [currentName],
            replacementName: trimmedName,
            screenplay: project.screenplay
        )
        if diagnostics.isEmpty && affected.isEmpty {
            diagnostics.append("No screenplay elements currently reference this profile name.")
        }

        return ProfileRenamePreview(
            id: previewIdentity(profileID: profileID, kind: kind, currentName: currentName, proposedName: trimmedName, affected: affected),
            profileKind: kind,
            profileID: profileID,
            currentName: currentName,
            proposedName: trimmedName,
            affectedElements: affected,
            diagnostics: diagnostics
        )
    }

    fileprivate static func applyingArchive(
        profileID: String,
        kind: ProfileKind,
        archived: Bool,
        to project: DreamJotterProject
    ) -> DreamJotterProject? {
        guard profileExists(profileID: profileID, kind: kind, in: project) else { return nil }
        let targetID = archiveTargetID(profileID: profileID, kind: kind)
        var values = project.pro.customFieldValues.filter {
            !($0.definitionID == archiveDefinitionID && $0.targetKind == .project && $0.targetID == targetID)
        }
        if archived {
            values.append(CustomFieldValue(
                id: "archive-\(kind.rawValue)-\(profileID)",
                definitionID: archiveDefinitionID,
                targetKind: .project,
                targetID: targetID,
                value: .boolean(true)
            ))
        }
        return replacing(project, pro: replacing(project.pro, customFieldValues: values))
    }

    fileprivate static func applyingDelete(
        profileID: String,
        kind: ProfileKind,
        to project: DreamJotterProject
    ) -> DreamJotterProject? {
        guard profileExists(profileID: profileID, kind: kind, in: project) else { return nil }
        let targetID = archiveTargetID(profileID: profileID, kind: kind)
        let values = project.pro.customFieldValues.filter {
            !($0.definitionID == archiveDefinitionID && $0.targetKind == .project && $0.targetID == targetID)
        }
        let notes = project.notes.map { note in
            ProjectNote(
                id: note.id,
                title: note.title,
                body: note.body,
                status: note.status,
                source: note.source,
                links: note.links.filter { !($0.targetKind == noteTargetKind(for: kind) && $0.targetID == profileID) },
                createdAt: note.createdAt,
                updatedAt: note.updatedAt
            )
        }
        switch kind {
        case .character:
            return replacing(
                project,
                characters: project.characters.filter { $0.id != profileID },
                notes: notes,
                pro: replacing(project.pro, customFieldValues: values)
            )
        case .location:
            return replacing(
                project,
                locations: project.locations.filter { $0.id != profileID },
                notes: notes,
                pro: replacing(project.pro, customFieldValues: values)
            )
        }
    }

    fileprivate static func applyingRename(
        preview: ProfileRenamePreview,
        to project: DreamJotterProject,
        now: Date
    ) -> DreamJotterProject? {
        let current = previewRename(
            profileID: preview.profileID,
            kind: preview.profileKind,
            proposedName: preview.proposedName,
            in: project
        )
        guard current.id == preview.id,
              current.diagnostics.filter({ $0 != "No screenplay elements currently reference this profile name." }).isEmpty else {
            return nil
        }

        let screenplay = replacingElements(in: project.screenplay, changes: current.affectedElements)
        switch preview.profileKind {
        case .character:
            let characters = project.characters.map { record in
                guard record.id == preview.profileID else { return record }
                return CharacterRecord(
                    id: record.id,
                    displayName: preview.proposedName,
                    note: record.note,
                    source: record.source,
                    createdAt: record.createdAt,
                    updatedAt: now
                )
            }
            let sceneCards = project.sceneCards.map { card in
                SceneCard(
                    id: card.id,
                    sourceSceneHeading: card.sourceSceneHeading,
                    title: card.title,
                    location: card.location,
                    timeOfDay: card.timeOfDay,
                    characters: card.characters.map { normalizedKey($0) == normalizedKey(preview.currentName) ? preview.proposedName : $0 },
                    summary: card.summary,
                    note: card.note,
                    status: card.status,
                    plotlineTags: card.plotlineTags,
                    order: card.order
                )
            }
            return replacing(
                project,
                screenplay: screenplay,
                characters: characters,
                ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys.filter {
                    ![normalizedKey(preview.currentName), normalizedKey(preview.proposedName)].contains(normalizedKey($0))
                },
                sceneCards: sceneCards
            )
        case .location:
            let locations = project.locations.map { record in
                guard record.id == preview.profileID else { return record }
                return LocationRecord(
                    id: record.id,
                    displayName: preview.proposedName,
                    note: record.note,
                    source: record.source,
                    createdAt: record.createdAt,
                    updatedAt: now
                )
            }
            let sceneCards = project.sceneCards.map { card in
                SceneCard(
                    id: card.id,
                    sourceSceneHeading: card.sourceSceneHeading.map { replaceLocation(in: $0, oldNames: [preview.currentName], newName: preview.proposedName) },
                    title: card.title,
                    location: card.location.map { normalizedKey($0) == normalizedKey(preview.currentName) ? preview.proposedName : $0 },
                    timeOfDay: card.timeOfDay,
                    characters: card.characters,
                    summary: card.summary,
                    note: card.note,
                    status: card.status,
                    plotlineTags: card.plotlineTags,
                    order: card.order
                )
            }
            return replacing(
                project,
                screenplay: screenplay,
                locations: locations,
                ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys.filter {
                    ![normalizedKey(preview.currentName), normalizedKey(preview.proposedName)].contains(normalizedKey($0))
                },
                sceneCards: sceneCards
            )
        }
    }

    fileprivate static func applyingMerge(
        survivorID: String,
        sourceIDs: [String],
        kind: ProfileKind,
        to project: DreamJotterProject,
        now: Date
    ) -> (project: DreamJotterProject, affectedIndexes: [Int])? {
        let uniqueSources = Array(Set(sourceIDs)).filter { $0 != survivorID }
        guard !uniqueSources.isEmpty,
              profileExists(profileID: survivorID, kind: kind, in: project),
              uniqueSources.allSatisfy({ profileExists(profileID: $0, kind: kind, in: project) }) else { return nil }

        switch kind {
        case .character:
            guard let survivor = project.characters.first(where: { $0.id == survivorID }) else { return nil }
            let sources = project.characters.filter { uniqueSources.contains($0.id) }
            let oldNames = sources.map(\.displayName)
            let changes = affectedElements(kind: .character, names: oldNames, replacementName: survivor.displayName, screenplay: project.screenplay)
            let mergedNote = mergedNotes([survivor.note] + sources.map(\.note))
            let characters = project.characters.compactMap { record -> CharacterRecord? in
                if uniqueSources.contains(record.id) { return nil }
                guard record.id == survivorID else { return record }
                return CharacterRecord(
                    id: record.id,
                    displayName: record.displayName,
                    note: mergedNote,
                    source: .merged,
                    createdAt: record.createdAt,
                    updatedAt: now
                )
            }
            let notes = remappingNoteLinks(project.notes, kind: kind, sourceIDs: uniqueSources, survivorID: survivorID, now: now)
            let sceneCards = project.sceneCards.map { card in
                let rewritten = card.characters.map { name in
                    oldNames.contains(where: { normalizedKey($0) == normalizedKey(name) }) ? survivor.displayName : name
                }
                return SceneCard(
                    id: card.id,
                    sourceSceneHeading: card.sourceSceneHeading,
                    title: card.title,
                    location: card.location,
                    timeOfDay: card.timeOfDay,
                    characters: deduplicatedNames(rewritten),
                    summary: card.summary,
                    note: card.note,
                    status: card.status,
                    plotlineTags: card.plotlineTags,
                    order: card.order
                )
            }
            let updated = replacing(
                project,
                screenplay: replacingElements(in: project.screenplay, changes: changes),
                characters: characters,
                ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys.filter { ignored in
                    !oldNames.contains(where: { normalizedKey($0) == normalizedKey(ignored) })
                },
                notes: notes,
                sceneCards: sceneCards,
                pro: removingArchiveMarkers(project.pro, profileIDs: uniqueSources, kind: kind)
            )
            return (updated, changes.map(\.index))

        case .location:
            guard let survivor = project.locations.first(where: { $0.id == survivorID }) else { return nil }
            let sources = project.locations.filter { uniqueSources.contains($0.id) }
            let oldNames = sources.map(\.displayName)
            let changes = affectedElements(kind: .location, names: oldNames, replacementName: survivor.displayName, screenplay: project.screenplay)
            let mergedNote = mergedNotes([survivor.note] + sources.map(\.note))
            let locations = project.locations.compactMap { record -> LocationRecord? in
                if uniqueSources.contains(record.id) { return nil }
                guard record.id == survivorID else { return record }
                return LocationRecord(
                    id: record.id,
                    displayName: record.displayName,
                    note: mergedNote,
                    source: .merged,
                    createdAt: record.createdAt,
                    updatedAt: now
                )
            }
            let notes = remappingNoteLinks(project.notes, kind: kind, sourceIDs: uniqueSources, survivorID: survivorID, now: now)
            let sceneCards = project.sceneCards.map { card in
                SceneCard(
                    id: card.id,
                    sourceSceneHeading: card.sourceSceneHeading.map { replaceLocation(in: $0, oldNames: oldNames, newName: survivor.displayName) },
                    title: card.title,
                    location: card.location.map { location in
                        oldNames.contains(where: { normalizedKey($0) == normalizedKey(location) }) ? survivor.displayName : location
                    },
                    timeOfDay: card.timeOfDay,
                    characters: card.characters,
                    summary: card.summary,
                    note: card.note,
                    status: card.status,
                    plotlineTags: card.plotlineTags,
                    order: card.order
                )
            }
            let updated = replacing(
                project,
                screenplay: replacingElements(in: project.screenplay, changes: changes),
                locations: locations,
                ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys.filter { ignored in
                    !oldNames.contains(where: { normalizedKey($0) == normalizedKey(ignored) })
                },
                notes: notes,
                sceneCards: sceneCards,
                pro: removingArchiveMarkers(project.pro, profileIDs: uniqueSources, kind: kind)
            )
            return (updated, changes.map(\.index))
        }
    }

    private static func profileName(profileID: String, kind: ProfileKind, in project: DreamJotterProject) -> String? {
        switch kind {
        case .character: return project.characters.first(where: { $0.id == profileID })?.displayName
        case .location: return project.locations.first(where: { $0.id == profileID })?.displayName
        }
    }

    private static func profileExists(profileID: String, kind: ProfileKind, in project: DreamJotterProject) -> Bool {
        profileName(profileID: profileID, kind: kind, in: project) != nil
    }

    private static func profileWithName(_ name: String, kind: ProfileKind, excluding profileID: String, in project: DreamJotterProject) -> String? {
        let key = normalizedKey(name)
        switch kind {
        case .character: return project.characters.first(where: { $0.id != profileID && $0.normalizedKey == key })?.id
        case .location: return project.locations.first(where: { $0.id != profileID && $0.normalizedKey == key })?.id
        }
    }

    private static func affectedElements(
        kind: ProfileKind,
        names: [String],
        replacementName: String,
        screenplay: ScreenplayDocument
    ) -> [ProfileAffectedElement] {
        let keys = Set(names.map(normalizedKey))
        return screenplay.elements.enumerated().compactMap { index, element in
            switch kind {
            case .character:
                guard element.kind == .characterCue, keys.contains(normalizedKey(element.text)) else { return nil }
                return ProfileAffectedElement(index: index, kind: element.kind, originalText: element.text, replacementText: replacementName)
            case .location:
                guard element.kind == .sceneHeading else { return nil }
                let replacement = replaceLocation(in: element.text, oldNames: names, newName: replacementName)
                guard replacement != element.text else { return nil }
                return ProfileAffectedElement(index: index, kind: element.kind, originalText: element.text, replacementText: replacement)
            }
        }
    }

    private static func replacingElements(in screenplay: ScreenplayDocument, changes: [ProfileAffectedElement]) -> ScreenplayDocument {
        let replacements = Dictionary(uniqueKeysWithValues: changes.map { ($0.index, $0.replacementText) })
        let elements = screenplay.elements.enumerated().map { index, element in
            guard let replacement = replacements[index] else { return element }
            return ScriptElement(
                kind: element.kind,
                text: replacement,
                characterName: element.kind == .characterCue ? replacement : element.characterName
            )
        }
        return ScreenplayDocument(
            elements: elements,
            scenes: deriveScenes(from: elements),
            characters: deriveCharacters(from: elements),
            diagnostics: screenplay.diagnostics
        )
    }

    private static func replaceLocation(in heading: String, oldNames: [String], newName: String) -> String {
        guard let dashRange = heading.range(of: " - ", options: .backwards) else {
            return replaceLocationSegment(heading, oldNames: oldNames, newName: newName)
        }
        let prefixAndLocation = String(heading[..<dashRange.lowerBound])
        let suffix = String(heading[dashRange.lowerBound...])
        let replaced = replaceLocationSegment(prefixAndLocation, oldNames: oldNames, newName: newName)
        return replaced == prefixAndLocation ? heading : replaced + suffix
    }

    private static func replaceLocationSegment(_ segment: String, oldNames: [String], newName: String) -> String {
        let prefixes = ["INT./EXT.", "INT/EXT.", "I/E.", "INT.", "EXT."]
        let trimmed = segment.trimmingCharacters(in: .whitespacesAndNewlines)
        let matchedPrefix = prefixes.first { trimmed.uppercased().hasPrefix($0) }
        let location = matchedPrefix.map { String(trimmed.dropFirst($0.count)).trimmingCharacters(in: .whitespaces) } ?? trimmed
        guard oldNames.contains(where: { normalizedKey($0) == normalizedKey(location) }) else { return segment }
        return matchedPrefix.map { "\($0) \(newName)" } ?? newName
    }

    private static func deriveCharacters(from elements: [ScriptElement]) -> [String] {
        deduplicatedNames(elements.filter { $0.kind == .characterCue }.map(\.text))
    }

    private static func deriveScenes(from elements: [ScriptElement]) -> [Scene] {
        elements.compactMap { element in
            guard element.kind == .sceneHeading else { return nil }
            let heading = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = heading.components(separatedBy: " - ")
            let first = parts.first ?? heading
            let location = ["INT./EXT.", "INT/EXT.", "I/E.", "INT.", "EXT."]
                .reduce(first) { result, prefix in
                    result.uppercased().hasPrefix(prefix) ? String(result.dropFirst(prefix.count)) : result
                }
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return Scene(heading: heading, location: location, timeOfDay: parts.count > 1 ? parts.last?.trimmingCharacters(in: .whitespacesAndNewlines) : nil)
        }
    }

    private static func deduplicatedNames(_ names: [String]) -> [String] {
        var seen: Set<String> = []
        return names.filter { seen.insert(normalizedKey($0)).inserted }
    }

    private static func mergedNotes(_ notes: [String]) -> String {
        var seen: Set<String> = []
        return notes
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
            .joined(separator: "\n\n")
    }

    private static func remappingNoteLinks(
        _ notes: [ProjectNote],
        kind: ProfileKind,
        sourceIDs: [String],
        survivorID: String,
        now: Date
    ) -> [ProjectNote] {
        notes.map { note in
            let links = note.links.map { link in
                guard link.targetKind == noteTargetKind(for: kind), sourceIDs.contains(link.targetID) else { return link }
                return NoteLink(targetKind: link.targetKind, targetID: survivorID)
            }
            return ProjectNote(
                id: note.id,
                title: note.title,
                body: note.body,
                status: note.status,
                source: note.source,
                links: deduplicatedLinks(links),
                createdAt: note.createdAt,
                updatedAt: links == note.links ? note.updatedAt : now
            )
        }
    }

    private static func deduplicatedLinks(_ links: [NoteLink]) -> [NoteLink] {
        var seen: Set<String> = []
        return links.filter { seen.insert("\($0.targetKind.rawValue):\($0.targetID)").inserted }
    }

    private static func noteTargetKind(for kind: ProfileKind) -> NoteTargetKind {
        kind == .character ? .character : .location
    }

    private static func normalizedKey(_ text: String) -> String {
        TextNormalization.key(for: text)
    }

    private static func archiveTargetID(profileID: String, kind: ProfileKind) -> String {
        "\(kind.rawValue):\(profileID)"
    }

    private static func previewIdentity(
        profileID: String,
        kind: ProfileKind,
        currentName: String,
        proposedName: String,
        affected: [ProfileAffectedElement]
    ) -> String {
        let material = ([kind.rawValue, profileID, normalizedKey(currentName), normalizedKey(proposedName)] + affected.map { "\($0.index):\($0.originalText):\($0.replacementText)" }).joined(separator: "|")
        return "profile-preview-\(stableHash(material))"
    }

    private static func stableHash(_ text: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return String(hash, radix: 16)
    }

    private static func removingArchiveMarkers(_ pro: ProProjectState, profileIDs: [String], kind: ProfileKind) -> ProProjectState {
        let targets = Set(profileIDs.map { archiveTargetID(profileID: $0, kind: kind) })
        return replacing(pro, customFieldValues: pro.customFieldValues.filter {
            !($0.definitionID == archiveDefinitionID && targets.contains($0.targetID))
        })
    }

    private static func replacing(_ pro: ProProjectState, customFieldValues: [CustomFieldValue]) -> ProProjectState {
        ProProjectState(
            revisionSets: pro.revisionSets,
            draftVersions: pro.draftVersions,
            productionBreakdown: pro.productionBreakdown,
            customFieldDefinitions: pro.customFieldDefinitions,
            customFieldValues: customFieldValues,
            routines: pro.routines,
            routineLogs: pro.routineLogs
        )
    }

    private static func replacing(
        _ project: DreamJotterProject,
        screenplay: ScreenplayDocument? = nil,
        characters: [CharacterRecord]? = nil,
        ignoredDetectedCharacterKeys: [String]? = nil,
        locations: [LocationRecord]? = nil,
        ignoredDetectedLocationKeys: [String]? = nil,
        notes: [ProjectNote]? = nil,
        sceneCards: [SceneCard]? = nil,
        snapshots: [SnapshotRecord]? = nil,
        pro: ProProjectState? = nil
    ) -> DreamJotterProject {
        DreamJotterProject(
            metadata: project.metadata,
            screenplay: screenplay ?? project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: characters ?? project.characters,
            ignoredDetectedCharacterKeys: ignoredDetectedCharacterKeys ?? project.ignoredDetectedCharacterKeys,
            locations: locations ?? project.locations,
            ignoredDetectedLocationKeys: ignoredDetectedLocationKeys ?? project.ignoredDetectedLocationKeys,
            notes: notes ?? project.notes,
            inboxItems: project.inboxItems,
            sceneCards: sceneCards ?? project.sceneCards,
            snapshots: snapshots ?? project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: pro ?? project.pro
        )
    }
}

public extension CommandEngine {
    static func execute(
        _ request: ProfileCommandRequest,
        project: DreamJotterProject,
        now: Date,
        canCreateSnapshot: Bool = true
    ) -> (project: DreamJotterProject, result: ProfileCommandResult) {
        if request.requiresSnapshot && !canCreateSnapshot {
            return (
                project,
                ProfileCommandResult(
                    commandID: request.id,
                    action: request.action,
                    status: .failed,
                    diagnostics: ["Snapshot creation failed."],
                    completedAt: now
                )
            )
        }

        let snapshot: SnapshotRecord? = request.requiresSnapshot
            ? SnapshotManager.createSnapshot(id: "snapshot-\(request.id)", name: "Before profile \(request.action.rawValue)", project: project, createdAt: now)
            : nil

        func finalized(_ mutated: DreamJotterProject, affectedProfiles: [String], affectedElements: [Int] = []) -> (DreamJotterProject, ProfileCommandResult) {
            let completedProject: DreamJotterProject
            if let snapshot {
                completedProject = DreamJotterProject(
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
            } else {
                completedProject = mutated
            }
            return (
                completedProject,
                ProfileCommandResult(
                    commandID: request.id,
                    action: request.action,
                    status: .succeeded,
                    snapshotID: snapshot?.id,
                    affectedProfileIDs: affectedProfiles,
                    affectedElementIndexes: affectedElements,
                    completedAt: now
                )
            )
        }

        switch request.action {
        case .archive:
            guard let updated = ProfileManagement.applyingArchive(profileID: request.profileID, kind: request.profileKind, archived: true, to: project) else {
                return rejected(request, project: project, now: now, diagnostic: "The selected profile does not exist.")
            }
            return finalized(updated, affectedProfiles: [request.profileID])

        case .restore:
            guard let updated = ProfileManagement.applyingArchive(profileID: request.profileID, kind: request.profileKind, archived: false, to: project) else {
                return rejected(request, project: project, now: now, diagnostic: "The selected profile does not exist.")
            }
            return finalized(updated, affectedProfiles: [request.profileID])

        case .delete:
            guard request.confirmed else {
                return rejected(request, project: project, now: now, diagnostic: "Profile deletion requires explicit confirmation.")
            }
            guard let updated = ProfileManagement.applyingDelete(profileID: request.profileID, kind: request.profileKind, to: project) else {
                return rejected(request, project: project, now: now, diagnostic: "The selected profile does not exist.")
            }
            return finalized(updated, affectedProfiles: [request.profileID])

        case .merge:
            guard request.confirmed else {
                return rejected(request, project: project, now: now, diagnostic: "Profile merge requires explicit confirmation.")
            }
            guard let merged = ProfileManagement.applyingMerge(
                survivorID: request.profileID,
                sourceIDs: request.sourceProfileIDs,
                kind: request.profileKind,
                to: project,
                now: now
            ) else {
                return rejected(request, project: project, now: now, diagnostic: "The merge request is invalid or references missing profiles.")
            }
            return finalized(merged.project, affectedProfiles: [request.profileID] + request.sourceProfileIDs, affectedElements: merged.affectedIndexes)

        case .bulkRename:
            guard request.confirmed,
                  let proposedName = request.proposedName,
                  let previewID = request.previewID else {
                return rejected(request, project: project, now: now, diagnostic: "Bulk rename requires an accepted preview and explicit confirmation.")
            }
            let preview = ProfileManagement.previewRename(
                profileID: request.profileID,
                kind: request.profileKind,
                proposedName: proposedName,
                in: project
            )
            guard preview.id == previewID else {
                return rejected(request, project: project, now: now, diagnostic: "The rename preview is stale. Review affected elements again.")
            }
            guard let updated = ProfileManagement.applyingRename(preview: preview, to: project, now: now) else {
                return rejected(request, project: project, now: now, diagnostic: "The rename could not be applied to the current project state.")
            }
            return finalized(updated, affectedProfiles: [request.profileID], affectedElements: preview.affectedElements.map(\.index))
        }
    }

    private static func rejected(
        _ request: ProfileCommandRequest,
        project: DreamJotterProject,
        now: Date,
        diagnostic: String
    ) -> (project: DreamJotterProject, result: ProfileCommandResult) {
        (
            project,
            ProfileCommandResult(
                commandID: request.id,
                action: request.action,
                status: .rejected,
                diagnostics: [diagnostic],
                completedAt: now
            )
        )
    }
}
