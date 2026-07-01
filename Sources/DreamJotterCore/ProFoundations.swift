import Foundation

public struct ProProjectState: Codable, Equatable, Sendable {
    public let revisionSets: [RevisionSet]
    public let draftVersions: [DraftVersion]
    public let productionBreakdown: [ProductionBreakdownEntry]
    public let customFieldDefinitions: [CustomFieldDefinition]
    public let customFieldValues: [CustomFieldValue]
    public let routines: [RoutineDefinition]
    public let routineLogs: [RoutineRunLog]

    public init(
        revisionSets: [RevisionSet] = [],
        draftVersions: [DraftVersion] = [],
        productionBreakdown: [ProductionBreakdownEntry] = [],
        customFieldDefinitions: [CustomFieldDefinition] = [],
        customFieldValues: [CustomFieldValue] = [],
        routines: [RoutineDefinition] = [],
        routineLogs: [RoutineRunLog] = []
    ) {
        self.revisionSets = revisionSets
        self.draftVersions = draftVersions
        self.productionBreakdown = productionBreakdown
        self.customFieldDefinitions = customFieldDefinitions
        self.customFieldValues = customFieldValues
        self.routines = routines
        self.routineLogs = routineLogs
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
    case makeup
    case stunts
    case music
    case specialEquipment
}

public struct ProductionBreakdownEntry: Codable, Equatable, Sendable {
    public let id: String
    public let sceneReference: String
    public let category: ProductionBreakdownCategory
    public let title: String
    public let notes: String
    public let quantity: Int
    public let createdAt: Date

    public init(id: String, sceneReference: String, category: ProductionBreakdownCategory, title: String, notes: String = "", quantity: Int = 1, createdAt: Date) {
        self.id = id
        self.sceneReference = sceneReference
        self.category = category
        self.title = title
        self.notes = notes
        self.quantity = quantity
        self.createdAt = createdAt
    }
}

public enum BreakdownValidator {
    public static func orphanedEntries(_ entries: [ProductionBreakdownEntry], sceneReferences: Set<String>) -> [ProductionBreakdownEntry] {
        entries.filter { !sceneReferences.contains($0.sceneReference) }
    }
}

public enum ExportPresetScope: String, Codable, Equatable, Sendable {
    case builtIn
    case project
}

public struct AdvancedExportPreset: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let format: ExportFormat
    public let scope: ExportPresetScope
    public let options: [String: String]
    public let createdAt: Date

    public init(id: String, title: String, format: ExportFormat, scope: ExportPresetScope, options: [String: String] = [:], createdAt: Date) {
        self.id = id
        self.title = title
        self.format = format
        self.scope = scope
        self.options = options
        self.createdAt = createdAt
    }
}

public enum AdvancedExportPresetValidator {
    public static func diagnostics(for preset: AdvancedExportPreset, supportedFormats: Set<ExportFormat>) -> [String] {
        supportedFormats.contains(preset.format) ? [] : ["Export format is unavailable."]
    }
}

public enum CustomFieldType: String, Codable, Equatable, CaseIterable, Sendable {
    case text
    case number
    case boolean
    case date
    case singleSelect
    case multiSelect
}

public enum CustomFieldTarget: String, Codable, Equatable, CaseIterable, Sendable {
    case project
    case scene
    case character
    case productionBreakdown
}

public struct CustomFieldDefinition: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let type: CustomFieldType
    public let allowedTargets: [CustomFieldTarget]
    public let selectOptions: [String]

    public init(id: String, name: String, type: CustomFieldType, allowedTargets: [CustomFieldTarget], selectOptions: [String] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.allowedTargets = allowedTargets
        self.selectOptions = selectOptions
    }
}

public enum CustomFieldStoredValue: Codable, Equatable, Sendable {
    case text(String)
    case number(Double)
    case boolean(Bool)
    case date(String)
    case singleSelect(String)
    case multiSelect([String])
}

public struct CustomFieldValue: Codable, Equatable, Sendable {
    public let id: String
    public let definitionID: String
    public let targetKind: CustomFieldTarget
    public let targetID: String
    public let value: CustomFieldStoredValue

    public init(id: String, definitionID: String, targetKind: CustomFieldTarget, targetID: String, value: CustomFieldStoredValue) {
        self.id = id
        self.definitionID = definitionID
        self.targetKind = targetKind
        self.targetID = targetID
        self.value = value
    }
}

public enum CustomFieldValidator {
    public static func validate(_ value: CustomFieldValue, against definition: CustomFieldDefinition) -> [String] {
        guard definition.id == value.definitionID else { return ["Field value references a different definition."] }
        guard definition.allowedTargets.contains(value.targetKind) else { return ["Field value target is not allowed."] }
        switch (definition.type, value.value) {
        case (.text, .text), (.number, .number), (.boolean, .boolean), (.date, .date):
            return []
        case (.singleSelect, .singleSelect(let selected)):
            return definition.selectOptions.contains(selected) ? [] : ["Selected value is not allowed."]
        case (.multiSelect, .multiSelect(let selected)):
            return selected.allSatisfy { definition.selectOptions.contains($0) } ? [] : ["One or more selected values are not allowed."]
        default:
            return ["Field value type does not match definition."]
        }
    }
}

public enum CommandOrigin: String, Codable, Equatable, Sendable {
    case user
    case routine
    case aiAcceptance
    case `import`
}

public enum CommandType: String, Codable, Equatable, Sendable {
    case createSnapshot
    case addNote
    case runAnalysis
    case updateSceneStatus
    case exportProject
    case applyAISuggestion
}

public struct CommandRequest: Codable, Equatable, Sendable {
    public let id: String
    public let type: CommandType
    public let origin: CommandOrigin
    public let payload: [String: String]
    public let requestedAt: Date
    public let requiresSnapshot: Bool

    public init(id: String, type: CommandType, origin: CommandOrigin, payload: [String: String] = [:], requestedAt: Date, requiresSnapshot: Bool = false) {
        self.id = id
        self.type = type
        self.origin = origin
        self.payload = payload
        self.requestedAt = requestedAt
        self.requiresSnapshot = requiresSnapshot
    }
}

public enum CommandStatus: String, Codable, Equatable, Sendable {
    case succeeded
    case failed
    case rejected
    case cancelled
}

public struct CommandResult: Codable, Equatable, Sendable {
    public let commandID: String
    public let type: CommandType
    public let status: CommandStatus
    public let snapshotID: String?
    public let affectedIDs: [String]
    public let diagnostics: [String]
    public let completedAt: Date

    public init(commandID: String, type: CommandType, status: CommandStatus, snapshotID: String? = nil, affectedIDs: [String] = [], diagnostics: [String] = [], completedAt: Date) {
        self.commandID = commandID
        self.type = type
        self.status = status
        self.snapshotID = snapshotID
        self.affectedIDs = affectedIDs
        self.diagnostics = diagnostics
        self.completedAt = completedAt
    }
}

public enum CommandEngine {
    public static func execute(_ request: CommandRequest, project: DreamJotterProject, now: Date, canCreateSnapshot: Bool = true) -> (project: DreamJotterProject, result: CommandResult) {
        if request.requiresSnapshot && !canCreateSnapshot {
            return (project, CommandResult(commandID: request.id, type: request.type, status: .failed, diagnostics: ["Snapshot creation failed."], completedAt: now))
        }
        let snapshotID = request.requiresSnapshot ? "snapshot-\(request.id)" : nil
        switch request.type {
        case .createSnapshot:
            let snapshot = SnapshotManager.createSnapshot(id: "snapshot-\(request.id)", name: "Command snapshot", project: project, createdAt: now)
            let updated = project.replacing(snapshots: project.snapshots + [snapshot])
            return (updated, CommandResult(commandID: request.id, type: request.type, status: .succeeded, snapshotID: snapshot.id, affectedIDs: [snapshot.id], completedAt: now))
        case .addNote:
            guard let body = request.payload["body"], !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return (project, CommandResult(commandID: request.id, type: request.type, status: .failed, diagnostics: ["Note body is required."], completedAt: now))
            }
            let note = ProjectNote(id: request.payload["id"] ?? "note-\(request.id)", body: body, createdAt: now, updatedAt: now)
            let updated = project.replacing(notes: project.notes + [note])
            return (updated, CommandResult(commandID: request.id, type: request.type, status: .succeeded, snapshotID: snapshotID, affectedIDs: [note.id], completedAt: now))
        case .updateSceneStatus where request.requiresSnapshot:
            return (project, CommandResult(commandID: request.id, type: request.type, status: .succeeded, snapshotID: snapshotID, affectedIDs: [request.payload["scene"] ?? ""].filter { !$0.isEmpty }, completedAt: now))
        case .runAnalysis, .exportProject, .applyAISuggestion, .updateSceneStatus:
            return (project, CommandResult(commandID: request.id, type: request.type, status: .succeeded, snapshotID: snapshotID, completedAt: now))
        }
    }
}

public enum RoutineTrigger: String, Codable, Equatable, CaseIterable, Sendable {
    case manual
    case sceneStatusChanged
    case beforeExport
    case afterExport
    case beforeAIRewrite
}

public enum RoutineConditionKind: String, Codable, Equatable, CaseIterable, Sendable {
    case sceneStatusEquals
    case projectHasOpenTODOs
    case proModeEnabled
}

public enum RoutineActionKind: String, Codable, Equatable, CaseIterable, Sendable {
    case createSnapshot
    case addNote
    case runAnalysis
    case updateSceneStatus
    case exportProject
}

public struct RoutineCondition: Codable, Equatable, Sendable {
    public let kind: RoutineConditionKind
    public let expectedValue: String?

    public init(kind: RoutineConditionKind, expectedValue: String? = nil) {
        self.kind = kind
        self.expectedValue = expectedValue
    }
}

public struct RoutineAction: Codable, Equatable, Sendable {
    public let kind: RoutineActionKind
    public let payload: [String: String]
    public let requiresSnapshot: Bool

    public init(kind: RoutineActionKind, payload: [String: String] = [:], requiresSnapshot: Bool = false) {
        self.kind = kind
        self.payload = payload
        self.requiresSnapshot = requiresSnapshot
    }
}

public struct RoutineDefinition: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let enabled: Bool
    public let trigger: RoutineTrigger
    public let conditions: [RoutineCondition]
    public let actions: [RoutineAction]
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: String, title: String, enabled: Bool, trigger: RoutineTrigger, conditions: [RoutineCondition] = [], actions: [RoutineAction], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.enabled = enabled
        self.trigger = trigger
        self.conditions = conditions
        self.actions = actions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum RoutineRunStatus: String, Codable, Equatable, Sendable {
    case succeeded
    case failed
    case skipped
    case cancelled
}

public struct RoutineRunLog: Codable, Equatable, Sendable {
    public let runID: String
    public let routineID: String
    public let trigger: RoutineTrigger
    public let status: RoutineRunStatus
    public let commandRequests: [CommandRequest]
    public let commandResults: [CommandResult]
    public let diagnostics: [String]
    public let startedAt: Date
    public let endedAt: Date

    public init(runID: String, routineID: String, trigger: RoutineTrigger, status: RoutineRunStatus, commandRequests: [CommandRequest], commandResults: [CommandResult], diagnostics: [String] = [], startedAt: Date, endedAt: Date) {
        self.runID = runID
        self.routineID = routineID
        self.trigger = trigger
        self.status = status
        self.commandRequests = commandRequests
        self.commandResults = commandResults
        self.diagnostics = diagnostics
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}

public enum RoutineValidator {
    public static func diagnostics(for routine: RoutineDefinition) -> [String] {
        routine.actions.isEmpty ? ["Routine must include at least one action."] : []
    }
}

public enum RoutineRunner {
    public static func run(_ routine: RoutineDefinition, project: DreamJotterProject, trigger: RoutineTrigger, runID: String, now: Date, canCreateSnapshot: Bool = true) -> (project: DreamJotterProject, log: RoutineRunLog) {
        guard routine.enabled else {
            return (project, RoutineRunLog(runID: runID, routineID: routine.id, trigger: trigger, status: .skipped, commandRequests: [], commandResults: [], diagnostics: ["Routine is disabled."], startedAt: now, endedAt: now))
        }
        guard routine.trigger == trigger else {
            return (project, RoutineRunLog(runID: runID, routineID: routine.id, trigger: trigger, status: .skipped, commandRequests: [], commandResults: [], diagnostics: ["Trigger does not match routine."], startedAt: now, endedAt: now))
        }
        let validation = RoutineValidator.diagnostics(for: routine)
        guard validation.isEmpty else {
            return (project, RoutineRunLog(runID: runID, routineID: routine.id, trigger: trigger, status: .failed, commandRequests: [], commandResults: [], diagnostics: validation, startedAt: now, endedAt: now))
        }

        var currentProject = project
        var requests: [CommandRequest] = []
        var results: [CommandResult] = []

        for (index, action) in routine.actions.enumerated() {
            let request = CommandRequest(
                id: "\(runID)-command-\(index)",
                type: commandType(for: action.kind),
                origin: .routine,
                payload: action.payload,
                requestedAt: now,
                requiresSnapshot: action.requiresSnapshot
            )
            requests.append(request)
            let execution = CommandEngine.execute(request, project: currentProject, now: now, canCreateSnapshot: canCreateSnapshot)
            currentProject = execution.project
            results.append(execution.result)
            if execution.result.status != .succeeded {
                return (project, RoutineRunLog(runID: runID, routineID: routine.id, trigger: trigger, status: .failed, commandRequests: requests, commandResults: results, diagnostics: execution.result.diagnostics, startedAt: now, endedAt: now))
            }
        }

        return (currentProject, RoutineRunLog(runID: runID, routineID: routine.id, trigger: trigger, status: .succeeded, commandRequests: requests, commandResults: results, startedAt: now, endedAt: now))
    }

    private static func commandType(for action: RoutineActionKind) -> CommandType {
        switch action {
        case .createSnapshot:
            return .createSnapshot
        case .addNote:
            return .addNote
        case .runAnalysis:
            return .runAnalysis
        case .updateSceneStatus:
            return .updateSceneStatus
        case .exportProject:
            return .exportProject
        }
    }
}

public enum ProModeVisibility {
    public static func authoringControlsVisible(feature: String, mode: EditorMode) -> Bool {
        guard mode == .pro else { return false }
        return ["revisions", "drafts", "comparison", "productionBreakdown", "advancedExportPresets", "customFields", "routines"].contains(feature)
    }
}

public enum FuturePluginPolicy {
    public static func isDeferred(requiresRuntime: Bool, requiresArbitraryScripting: Bool) -> Bool {
        requiresRuntime || requiresArbitraryScripting
    }
}

extension DreamJotterProject {
    func replacing(
        notes: [ProjectNote]? = nil,
        snapshots: [SnapshotRecord]? = nil,
        pro: ProProjectState? = nil
    ) -> DreamJotterProject {
        DreamJotterProject(
            metadata: metadata,
            screenplay: screenplay,
            mode: mode,
            template: template,
            characters: characters,
            notes: notes ?? self.notes,
            inboxItems: inboxItems,
            sceneCards: sceneCards,
            snapshots: snapshots ?? self.snapshots,
            exportPresets: exportPresets,
            story: story,
            pro: pro ?? self.pro
        )
    }
}
