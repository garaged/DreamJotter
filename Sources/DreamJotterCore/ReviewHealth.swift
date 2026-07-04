import Foundation

public enum ReviewFindingSeverity: String, Codable, Equatable, Sendable {
    case info
    case warning
    case issue
}

public enum ReviewFindingSource: String, Codable, Equatable, Sendable {
    case healthReport
    case formatting
    case unresolvedCharacter
    case unresolvedLocation
    case todo
    case storage
}

public enum ReviewLinkedEntityType: String, Codable, Equatable, Sendable {
    case project
    case scene
    case character
    case location
    case note
    case screenplayElement
}

public struct ScriptTextRange: Codable, Equatable, Sendable {
    public let location: Int
    public let length: Int

    public init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }
}

public struct ReviewFinding: Codable, Equatable, Sendable {
    public let id: String
    public let severity: ReviewFindingSeverity
    public let title: String
    public let message: String
    public let source: ReviewFindingSource
    public let linkedEntityType: ReviewLinkedEntityType?
    public let linkedEntityID: String?
    public let scriptRange: ScriptTextRange?
    public let suggestedAction: String?
    public let generatedAt: Date

    public init(
        id: String,
        severity: ReviewFindingSeverity,
        title: String,
        message: String,
        source: ReviewFindingSource,
        linkedEntityType: ReviewLinkedEntityType? = nil,
        linkedEntityID: String? = nil,
        scriptRange: ScriptTextRange? = nil,
        suggestedAction: String? = nil,
        generatedAt: Date
    ) {
        self.id = id
        self.severity = severity
        self.title = title
        self.message = message
        self.source = source
        self.linkedEntityType = linkedEntityType
        self.linkedEntityID = linkedEntityID
        self.scriptRange = scriptRange
        self.suggestedAction = suggestedAction
        self.generatedAt = generatedAt
    }
}

public struct SceneHealthSummary: Codable, Equatable, Sendable {
    public let sceneID: String
    public let heading: String
    public let elementCount: Int

    public init(sceneID: String, heading: String, elementCount: Int) {
        self.sceneID = sceneID
        self.heading = heading
        self.elementCount = elementCount
    }
}

public struct ScriptHealthReport: Codable, Equatable, Sendable {
    public let id: String
    public let generatedAt: Date
    public let projectID: String
    public let sceneCount: Int
    public let elementCount: Int
    public let characterProfileCount: Int
    public let unresolvedDetectedCharacterCount: Int
    public let locationProfileCount: Int
    public let unresolvedDetectedLocationCount: Int
    public let openNotesCount: Int
    public let todoCount: Int
    public let dialogueActionRatio: Double
    public let longestScenes: [SceneHealthSummary]
    public let scenesWithoutDialogue: [SceneHealthSummary]
    public let formattingWarnings: [ReviewFinding]
    public let findings: [ReviewFinding]
    public let lastSavedAt: Date?

    public init(
        id: String,
        generatedAt: Date,
        projectID: String,
        sceneCount: Int,
        elementCount: Int,
        characterProfileCount: Int,
        unresolvedDetectedCharacterCount: Int,
        locationProfileCount: Int,
        unresolvedDetectedLocationCount: Int,
        openNotesCount: Int,
        todoCount: Int,
        dialogueActionRatio: Double,
        longestScenes: [SceneHealthSummary],
        scenesWithoutDialogue: [SceneHealthSummary],
        formattingWarnings: [ReviewFinding],
        findings: [ReviewFinding],
        lastSavedAt: Date? = nil
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.projectID = projectID
        self.sceneCount = sceneCount
        self.elementCount = elementCount
        self.characterProfileCount = characterProfileCount
        self.unresolvedDetectedCharacterCount = unresolvedDetectedCharacterCount
        self.locationProfileCount = locationProfileCount
        self.unresolvedDetectedLocationCount = unresolvedDetectedLocationCount
        self.openNotesCount = openNotesCount
        self.todoCount = todoCount
        self.dialogueActionRatio = dialogueActionRatio
        self.longestScenes = longestScenes
        self.scenesWithoutDialogue = scenesWithoutDialogue
        self.formattingWarnings = formattingWarnings
        self.findings = findings
        self.lastSavedAt = lastSavedAt
    }
}

public enum ReviewModeFocus: String, Codable, Equatable, Sendable {
    case script
    case scenes
    case notes
    case findings
    case export
}

public struct ReviewModeState: Codable, Equatable, Sendable {
    public let isActive: Bool
    public let isReadOnly: Bool
    public let selectedFindingID: String?
    public let selectedSceneID: String?
    public let focus: ReviewModeFocus
    public let generatedAt: Date?

    public init(
        isActive: Bool = false,
        isReadOnly: Bool = true,
        selectedFindingID: String? = nil,
        selectedSceneID: String? = nil,
        focus: ReviewModeFocus = .script,
        generatedAt: Date? = nil
    ) {
        self.isActive = isActive
        self.isReadOnly = isReadOnly
        self.selectedFindingID = selectedFindingID
        self.selectedSceneID = selectedSceneID
        self.focus = focus
        self.generatedAt = generatedAt
    }

    public static let inactive = ReviewModeState()
}

public enum ScriptHealthReportBuilder {
    private struct SceneAnalysis {
        var summary: SceneHealthSummary
        var hasDialogue: Bool
    }

    public static func report(for project: DreamJotterProject, generatedAt: Date = Date(), lastSavedAt: Date? = nil) -> ScriptHealthReport {
        let unresolvedCharacters = CharacterManager.unresolvedDetectedCharacters(for: project)
        let unresolvedLocations = LocationManager.unresolvedDetectedLocations(for: project)
        let openNotes = NotesIndex.openNotes(in: project)
        let todos = NotesIndex.detectedScriptTodos(in: project, now: generatedAt)
        let formattingWarnings = ReviewFindingBuilder.formattingFindings(for: project, generatedAt: generatedAt)
        let findings = ReviewFindingBuilder.findings(
            for: project,
            unresolvedCharacters: unresolvedCharacters,
            unresolvedLocations: unresolvedLocations,
            todos: todos,
            formattingWarnings: formattingWarnings,
            generatedAt: generatedAt
        )
        let analysis = analyze(project.screenplay)

        return ScriptHealthReport(
            id: "script-health-\(project.metadata.id)-\(Int(generatedAt.timeIntervalSince1970))",
            generatedAt: generatedAt,
            projectID: project.metadata.id,
            sceneCount: project.screenplay.scenes.count,
            elementCount: project.screenplay.elements.count,
            characterProfileCount: project.characters.count,
            unresolvedDetectedCharacterCount: unresolvedCharacters.count,
            locationProfileCount: project.locations.count,
            unresolvedDetectedLocationCount: unresolvedLocations.count,
            openNotesCount: openNotes.count,
            todoCount: todos.count,
            dialogueActionRatio: analysis.dialogueActionRatio,
            longestScenes: Array(analysis.scenes.map(\.summary).sorted { $0.elementCount > $1.elementCount }.prefix(5)),
            scenesWithoutDialogue: analysis.scenes.compactMap { $0.hasDialogue ? nil : $0.summary },
            formattingWarnings: formattingWarnings,
            findings: findings,
            lastSavedAt: lastSavedAt
        )
    }

    private static func analyze(_ document: ScreenplayDocument) -> (dialogueActionRatio: Double, scenes: [SceneAnalysis]) {
        var dialogueCount = 0
        var actionCount = 0
        var scenes: [SceneAnalysis] = []
        scenes.reserveCapacity(document.scenes.count)
        var currentSceneIndex: Int?

        for element in document.elements {
            switch element.kind {
            case .dialogue:
                dialogueCount += 1
            case .action:
                actionCount += 1
            default:
                break
            }

            if element.kind == .sceneHeading {
                let sceneIndex = scenes.count
                scenes.append(SceneAnalysis(
                    summary: SceneHealthSummary(
                        sceneID: "scene-\(sceneIndex + 1)",
                        heading: element.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        elementCount: 0
                    ),
                    hasDialogue: false
                ))
                currentSceneIndex = sceneIndex
                continue
            }

            guard let currentSceneIndex else { continue }
            let current = scenes[currentSceneIndex]
            scenes[currentSceneIndex] = SceneAnalysis(
                summary: SceneHealthSummary(
                    sceneID: current.summary.sceneID,
                    heading: current.summary.heading,
                    elementCount: current.summary.elementCount + 1
                ),
                hasDialogue: current.hasDialogue || element.kind == .dialogue
            )
        }

        let ratio: Double
        if dialogueCount == 0, actionCount == 0 {
            ratio = 0
        } else {
            ratio = Double(dialogueCount) / Double(max(actionCount, 1))
        }
        return (ratio, scenes)
    }
}

public enum ReviewFindingBuilder {
    public static func findings(
        for project: DreamJotterProject,
        unresolvedCharacters: [DetectedCharacter]? = nil,
        unresolvedLocations: [DetectedLocation]? = nil,
        todos: [ProjectNote]? = nil,
        formattingWarnings: [ReviewFinding]? = nil,
        generatedAt: Date = Date()
    ) -> [ReviewFinding] {
        let characters = unresolvedCharacters ?? CharacterManager.unresolvedDetectedCharacters(for: project)
        let locations = unresolvedLocations ?? LocationManager.unresolvedDetectedLocations(for: project)
        let scriptTodos = todos ?? NotesIndex.detectedScriptTodos(in: project, now: generatedAt)
        let formatting = formattingWarnings ?? formattingFindings(for: project, generatedAt: generatedAt)

        return characters.enumerated().map { index, character in
            ReviewFinding(
                id: "finding-unresolved-character-\(index + 1)-\(character.normalizedName)",
                severity: .warning,
                title: "Unresolved character",
                message: "\(character.name) appears in the script but is not a character profile yet.",
                source: .unresolvedCharacter,
                linkedEntityType: .screenplayElement,
                linkedEntityID: character.firstElementID,
                suggestedAction: "Convert this detected character into a profile or ignore it.",
                generatedAt: generatedAt
            )
        } + locations.enumerated().map { index, location in
            ReviewFinding(
                id: "finding-unresolved-location-\(index + 1)-\(location.normalizedName)",
                severity: .warning,
                title: "Unresolved location",
                message: "\(location.name) appears in scene headings but is not a location profile yet.",
                source: .unresolvedLocation,
                linkedEntityType: .scene,
                linkedEntityID: location.firstSceneID,
                suggestedAction: "Convert this detected location into a profile or ignore it.",
                generatedAt: generatedAt
            )
        } + scriptTodos.enumerated().map { index, note in
            ReviewFinding(
                id: "finding-script-todo-\(index + 1)",
                severity: .info,
                title: "Open script TODO",
                message: note.body,
                source: .todo,
                linkedEntityType: note.links.first?.targetKind.reviewLinkedEntityType,
                linkedEntityID: note.links.first?.targetID,
                suggestedAction: "Resolve this TODO before sharing the script if it is no longer needed.",
                generatedAt: generatedAt
            )
        } + formatting
    }

    public static func formattingFindings(for project: DreamJotterProject, generatedAt: Date = Date()) -> [ReviewFinding] {
        var findings: [ReviewFinding] = []
        findings.append(contentsOf: sceneHeadingFindings(for: project.screenplay, generatedAt: generatedAt))
        findings.append(contentsOf: duplicateSceneHeadingFindings(for: project.screenplay, generatedAt: generatedAt))
        findings.append(contentsOf: characterDialogueFindings(for: project.screenplay, generatedAt: generatedAt))
        return findings
    }

    private static func sceneHeadingFindings(for document: ScreenplayDocument, generatedAt: Date) -> [ReviewFinding] {
        document.scenes.enumerated().flatMap { index, scene in
            var findings: [ReviewFinding] = []
            let sceneID = "scene-\(index + 1)"
            if scene.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                findings.append(ReviewFinding(
                    id: "finding-scene-missing-location-\(index + 1)",
                    severity: .warning,
                    title: "Scene heading missing location",
                    message: "\(scene.heading) does not include a clear location.",
                    source: .formatting,
                    linkedEntityType: .scene,
                    linkedEntityID: sceneID,
                    suggestedAction: "Add a location after the scene prefix.",
                    generatedAt: generatedAt
                ))
            }
            if scene.timeOfDay == nil {
                findings.append(ReviewFinding(
                    id: "finding-scene-missing-time-\(index + 1)",
                    severity: .warning,
                    title: "Scene heading missing time of day",
                    message: "\(scene.heading) does not include a time of day.",
                    source: .formatting,
                    linkedEntityType: .scene,
                    linkedEntityID: sceneID,
                    suggestedAction: "Add a time of day such as DAY or NIGHT.",
                    generatedAt: generatedAt
                ))
            }
            return findings
        }
    }

    private static func duplicateSceneHeadingFindings(for document: ScreenplayDocument, generatedAt: Date) -> [ReviewFinding] {
        var counts: [String: Int] = [:]
        for scene in document.scenes {
            counts[TextNormalization.key(for: scene.heading), default: 0] += 1
        }

        return document.scenes.enumerated().compactMap { index, scene in
            let key = TextNormalization.key(for: scene.heading)
            guard (counts[key] ?? 0) > 1 else { return nil }
            return ReviewFinding(
                id: "finding-duplicate-scene-heading-\(index + 1)",
                severity: .info,
                title: "Duplicate scene heading",
                message: "\(scene.heading) appears more than once.",
                source: .formatting,
                linkedEntityType: .scene,
                linkedEntityID: "scene-\(index + 1)",
                suggestedAction: "Confirm the repeated heading is intentional.",
                generatedAt: generatedAt
            )
        }
    }

    private static func characterDialogueFindings(for document: ScreenplayDocument, generatedAt: Date) -> [ReviewFinding] {
        var findings: [ReviewFinding] = []
        for (index, element) in document.elements.enumerated() {
            switch element.kind {
            case .characterCue:
                if !hasFollowingDialogue(after: index, in: document.elements) {
                    findings.append(ReviewFinding(
                        id: "finding-character-without-dialogue-\(index + 1)",
                        severity: .warning,
                        title: "Character cue without dialogue",
                        message: "\(element.text) is not followed by dialogue.",
                        source: .formatting,
                        linkedEntityType: .screenplayElement,
                        linkedEntityID: "element-\(index + 1)",
                        suggestedAction: "Add dialogue or change the line type.",
                        generatedAt: generatedAt
                    ))
                }
            case .dialogue:
                if !hasPreviousCharacterCue(before: index, in: document.elements) {
                    findings.append(ReviewFinding(
                        id: "finding-dialogue-without-character-\(index + 1)",
                        severity: .warning,
                        title: "Dialogue without a character cue",
                        message: "A dialogue line appears without a clear speaker.",
                        source: .formatting,
                        linkedEntityType: .screenplayElement,
                        linkedEntityID: "element-\(index + 1)",
                        suggestedAction: "Add a character cue before this dialogue.",
                        generatedAt: generatedAt
                    ))
                }
            default:
                break
            }
        }
        return findings
    }

    private static func hasFollowingDialogue(after index: Int, in elements: [ScriptElement]) -> Bool {
        var nextIndex = index + 1
        while nextIndex < elements.count {
            let kind = elements[nextIndex].kind
            if kind == .parenthetical {
                nextIndex += 1
                continue
            }
            return kind == .dialogue
        }
        return false
    }

    private static func hasPreviousCharacterCue(before index: Int, in elements: [ScriptElement]) -> Bool {
        var previousIndex = index - 1
        while previousIndex >= 0 {
            let kind = elements[previousIndex].kind
            if kind == .parenthetical || kind == .dialogue {
                previousIndex -= 1
                continue
            }
            return kind == .characterCue
        }
        return false
    }
}

private extension NoteTargetKind {
    var reviewLinkedEntityType: ReviewLinkedEntityType {
        switch self {
        case .project:
            return .project
        case .scene:
            return .scene
        case .character:
            return .character
        case .location:
            return .location
        case .screenplayElement:
            return .screenplayElement
        }
    }
}
