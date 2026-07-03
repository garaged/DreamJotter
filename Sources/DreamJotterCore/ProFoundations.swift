import Foundation

public struct ProProjectState: Codable, Equatable, Sendable {
    public let revisionSets: [RevisionSet]
    public let draftVersions: [DraftVersion]
    public let productionBreakdown: [ProductionBreakdownEntry]
    public let customFieldDefinitions: [CustomFieldDefinition]
    public let customFieldValues: [CustomFieldValue]
    public let routines: [RoutineDefinition]
    public let routineLogs: [RoutineRunLog]
    public let screenplayLanguage: ScreenplayLanguageProfile

    public init(
        revisionSets: [RevisionSet] = [],
        draftVersions: [DraftVersion] = [],
        productionBreakdown: [ProductionBreakdownEntry] = [],
        customFieldDefinitions: [CustomFieldDefinition] = [],
        customFieldValues: [CustomFieldValue] = [],
        routines: [RoutineDefinition] = [],
        routineLogs: [RoutineRunLog] = [],
        screenplayLanguage: ScreenplayLanguageProfile = .automatic
    ) {
        self.revisionSets = revisionSets
        self.draftVersions = draftVersions
        self.productionBreakdown = productionBreakdown
        self.customFieldDefinitions = customFieldDefinitions
        self.customFieldValues = customFieldValues
        self.routines = routines
        self.routineLogs = routineLogs
        self.screenplayLanguage = screenplayLanguage
    }

    private enum CodingKeys: String, CodingKey {
        case revisionSets
        case draftVersions
        case productionBreakdown
        case customFieldDefinitions
        case customFieldValues
        case routines
        case routineLogs
        case screenplayLanguage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        revisionSets = try container.decodeIfPresent([RevisionSet].self, forKey: .revisionSets) ?? []
        draftVersions = try container.decodeIfPresent([DraftVersion].self, forKey: .draftVersions) ?? []
        productionBreakdown = try container.decodeIfPresent([ProductionBreakdownEntry].self, forKey: .productionBreakdown) ?? []
        customFieldDefinitions = try container.decodeIfPresent([CustomFieldDefinition].self, forKey: .customFieldDefinitions) ?? []
        customFieldValues = try container.decodeIfPresent([CustomFieldValue].self, forKey: .customFieldValues) ?? []
        routines = try container.decodeIfPresent([RoutineDefinition].self, forKey: .routines) ?? []
        routineLogs = try container.decodeIfPresent([RoutineRunLog].self, forKey: .routineLogs) ?? []
        screenplayLanguage = try container.decodeIfPresent(ScreenplayLanguageProfile.self, forKey: .screenplayLanguage) ?? .automatic
    }
}

public enum RevisionColorKind: String, Codable, Equatable, CaseIterable, Sendable {
    case blue
    case pink
    case yellow
    case green
    case goldenrod
    case cherry
    case custom
}

public struct RevisionColor: Codable, Equatable, Sendable {
    public let kind: RevisionColorKind
    public let displayName: String
    public let portableValue: String?

    public init(kind: RevisionColorKind, displayName: String? = nil, portableValue: String? = nil) {
        self.kind = kind
        self.displayName = displayName ?? kind.rawValue
        self.portableValue = portableValue
    }

    public var isValid: Bool {
        kind != .custom || !(portableValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public struct RevisionSet: Codable, Equatable, Sendable {
    public let id: String
    public let label: String
    public let color: RevisionColor
    public let linkedElementIDs: [String]
    public let isActive: Bool
    public let createdAt: Date

    public init(id: String, label: String, color: RevisionColor, linkedElementIDs: [String] = [], isActive: Bool = false, createdAt: Date) {
        self.id = id
        self.label = label
        self.color = color
        self.linkedElementIDs = linkedElementIDs
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

public struct DraftVersion: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let sourceSnapshotID: String?
    public let revisionSetIDs: [String]
    public let notes: String
    public let createdAt: Date

    public init(id: String, name: String, sourceSnapshotID: String? = nil, revisionSetIDs: [String] = [], notes: String = "", createdAt: Date) {
        self.id = id
        self.name = name
        self.sourceSnapshotID = sourceSnapshotID
        self.revisionSetIDs = revisionSetIDs
        self.notes = notes
        self.createdAt = createdAt
    }
}

public enum DraftChangeKind: String, Codable, Equatable, Sendable {
    case added
    case removed
    case changed
    case moved
}

public struct DraftComparisonChange: Codable, Equatable, Sendable {
    public let kind: DraftChangeKind
    public let elementText: String
    public let leftIndex: Int?
    public let rightIndex: Int?

    public init(kind: DraftChangeKind, elementText: String, leftIndex: Int?, rightIndex: Int?) {
        self.kind = kind
        self.elementText = elementText
        self.leftIndex = leftIndex
        self.rightIndex = rightIndex
    }
}

public struct DraftComparisonResult: Codable, Equatable, Sendable {
    public let leftDraftID: String
    public let rightDraftID: String
    public let changes: [DraftComparisonChange]
    public let diagnostics: [String]

    public init(leftDraftID: String, rightDraftID: String, changes: [DraftComparisonChange], diagnostics: [String] = []) {
        self.leftDraftID = leftDraftID
        self.rightDraftID = rightDraftID
        self.changes = changes
        self.diagnostics = diagnostics
    }
}

public enum DraftComparer {
    public static func compare(left: ScreenplayDocument, leftDraftID: String, right: ScreenplayDocument, rightDraftID: String) -> DraftComparisonResult {
        var changes: [DraftComparisonChange] = []
        let leftTexts = left.elements.map(\.text)
        let rightTexts = right.elements.map(\.text)

        for (index, text) in leftTexts.enumerated() where !rightTexts.contains(text) {
            changes.append(DraftComparisonChange(kind: .removed, elementText: text, leftIndex: index, rightIndex: nil))
        }
        for (index, text) in rightTexts.enumerated() where !leftTexts.contains(text) {
            changes.append(DraftComparisonChange(kind: .added, elementText: text, leftIndex: nil, rightIndex: index))
        }
        for text in Set(leftTexts).intersection(Set(rightTexts)) {
            if let leftIndex = leftTexts.firstIndex(of: text),
               let rightIndex = rightTexts.firstIndex(of: text),
               leftIndex != rightIndex {
                changes.append(DraftComparisonChange(kind: .moved, elementText: text, leftIndex: leftIndex, rightIndex: rightIndex))
            }
        }
        return DraftComparisonResult(leftDraftID: leftDraftID, rightDraftID: rightDraftID, changes: changes)
    }
}

public enum ProductionBreakdownCategory: String, Codable, Equatable, CaseIterable, Sendable {
    case cast
    case extras
    case props
    case costumes
    case vehicles
    case animals
    case vfx
    case sfx
    case locations
}
