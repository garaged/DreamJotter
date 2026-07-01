import Foundation

public struct StoryDevelopmentState: Codable, Equatable, Sendable {
    public let setup: StorySetupRecord?
    public let logline: LoglineRecord?
    public let synopsis: SynopsisRecord?
    public let beatSheets: [BeatSheet]
    public let suggestions: [AISuggestion]

    public init(
        setup: StorySetupRecord? = nil,
        logline: LoglineRecord? = nil,
        synopsis: SynopsisRecord? = nil,
        beatSheets: [BeatSheet] = [],
        suggestions: [AISuggestion] = []
    ) {
        self.setup = setup
        self.logline = logline
        self.synopsis = synopsis
        self.beatSheets = beatSheets
        self.suggestions = suggestions
    }
}

public struct StorySetupRecord: Codable, Equatable, Sendable {
    public let id: String
    public let workingTitle: String
    public let formatIntent: String
    public let genreTone: String
    public let protagonist: String
    public let goal: String
    public let obstacle: String
    public let audience: String
    public let notes: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        workingTitle: String,
        formatIntent: String,
        genreTone: String = "",
        protagonist: String = "",
        goal: String = "",
        obstacle: String = "",
        audience: String = "",
        notes: String = "",
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.workingTitle = workingTitle
        self.formatIntent = formatIntent
        self.genreTone = genreTone
        self.protagonist = protagonist
        self.goal = goal
        self.obstacle = obstacle
        self.audience = audience
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum DevelopmentTextSource: String, Codable, Equatable, Sendable {
    case manual
    case localComposition
    case acceptedAISuggestion
}

public struct LoglineRecord: Codable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let protagonist: String
    public let goal: String
    public let obstacle: String
    public let stakes: String
    public let source: DevelopmentTextSource
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        text: String,
        protagonist: String = "",
        goal: String = "",
        obstacle: String = "",
        stakes: String = "",
        source: DevelopmentTextSource = .manual,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.text = text
        self.protagonist = protagonist
        self.goal = goal
        self.obstacle = obstacle
        self.stakes = stakes
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct SynopsisRecord: Codable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let beginning: String
    public let middle: String
    public let ending: String
    public let source: DevelopmentTextSource
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        text: String,
        beginning: String = "",
        middle: String = "",
        ending: String = "",
        source: DevelopmentTextSource = .manual,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.text = text
        self.beginning = beginning
        self.middle = middle
        self.ending = ending
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct BeatSheet: Codable, Equatable, Sendable {
    public let id: String
    public let templateID: String
    public let title: String
    public let beats: [BeatRecord]
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: String, templateID: String, title: String, beats: [BeatRecord], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.templateID = templateID
        self.title = title
        self.beats = beats
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct BeatRecord: Codable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let order: Int
    public let linkedSceneHeading: String?

    public init(id: String, title: String, summary: String = "", order: Int, linkedSceneHeading: String? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.order = order
        self.linkedSceneHeading = linkedSceneHeading
    }
}

public enum GuidedStorySetup {
    public static func createManualSetup(
        workingTitle: String,
        formatIntent: String,
        genreTone: String = "",
        protagonist: String = "",
        goal: String = "",
        obstacle: String = "",
        audience: String = "",
        notes: String = "",
        id: String = "story-setup",
        now: Date
    ) -> StorySetupRecord {
        StorySetupRecord(
            id: id,
            workingTitle: workingTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            formatIntent: formatIntent.trimmingCharacters(in: .whitespacesAndNewlines),
            genreTone: genreTone,
            protagonist: protagonist,
            goal: goal,
            obstacle: obstacle,
            audience: audience,
            notes: notes,
            createdAt: now,
            updatedAt: now
        )
    }
}

public enum LoglineBuilder {
    public static func composeManualLogline(
        protagonist: String,
        goal: String,
        obstacle: String,
        stakes: String,
        id: String = "logline",
        now: Date
    ) -> LoglineRecord {
        let parts = [
            protagonist.isEmpty ? "Someone" : protagonist,
            goal.isEmpty ? "wants something important" : goal,
            obstacle.isEmpty ? "but faces a serious obstacle" : "but \(obstacle)",
            stakes.isEmpty ? "before time runs out" : stakes
        ]
        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return LoglineRecord(
            id: id,
            text: text,
            protagonist: protagonist,
            goal: goal,
            obstacle: obstacle,
            stakes: stakes,
            source: .manual,
            createdAt: now,
            updatedAt: now
        )
    }
}

public enum SynopsisBuilder {
    public static func buildSynopsis(
        setup: StorySetupRecord?,
        beginning: String,
        middle: String,
        ending: String,
        id: String = "synopsis",
        now: Date
    ) -> (record: SynopsisRecord, findings: [ContinuityFinding]) {
        var findings: [ContinuityFinding] = []
        if setup == nil || setup?.protagonist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            findings.append(ContinuityFinding(
                id: "synopsis-missing-setup-context",
                ruleID: "missing-setup-context",
                severity: .info,
                confidence: .high,
                message: "Some story setup details are missing, so this synopsis may need another pass.",
                evidence: [],
                suggestedAction: "Add the protagonist, goal, and obstacle when you know them."
            ))
        }
        let text = [beginning, middle, ending]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        return (SynopsisRecord(id: id, text: text, beginning: beginning, middle: middle, ending: ending, createdAt: now, updatedAt: now), findings)
    }
}

public enum BeatSheetFactory {
    public static func beginningMiddleEnd(id: String = "beat-sheet-bme", now: Date) -> BeatSheet {
        BeatSheet(
            id: id,
            templateID: "beginning-middle-end",
            title: "Beginning, Middle, End",
            beats: [
                BeatRecord(id: "beat-beginning", title: "Beginning", order: 0),
                BeatRecord(id: "beat-middle", title: "Middle", order: 1),
                BeatRecord(id: "beat-end", title: "End", order: 2)
            ],
            createdAt: now,
            updatedAt: now
        )
    }
}

public enum AIRequestKind: String, Codable, Equatable, Sendable {
    case logline
    case synopsis
    case sceneStarter
    case rewrite
    case continuityWording
}

public struct AIRequest: Codable, Equatable, Sendable {
    public let id: String
    public let kind: AIRequestKind
    public let projectID: String
    public let targetReference: String?
    public let context: String
    public let instructions: String
    public let createdAt: Date

    public init(id: String, kind: AIRequestKind, projectID: String, targetReference: String? = nil, context: String, instructions: String = "", createdAt: Date) {
        self.id = id
        self.kind = kind
        self.projectID = projectID
        self.targetReference = targetReference
        self.context = context
        self.instructions = instructions
        self.createdAt = createdAt
    }
}

public enum AIResponseStatus: String, Codable, Equatable, Sendable {
    case success
    case disabled
    case failed
}

public enum AISuggestionStatus: String, Codable, Equatable, Sendable {
    case pending
    case accepted
    case rejected
    case failed
}

public struct AISuggestion: Codable, Equatable, Sendable {
    public let id: String
    public let requestID: String
    public let kind: AIRequestKind
    public let targetReference: String?
    public let proposedText: String
    public let status: AISuggestionStatus
    public let diagnostics: [String]
    public let createdAt: Date

    public init(
        id: String,
        requestID: String,
        kind: AIRequestKind,
        targetReference: String?,
        proposedText: String,
        status: AISuggestionStatus = .pending,
        diagnostics: [String] = [],
        createdAt: Date
    ) {
        self.id = id
        self.requestID = requestID
        self.kind = kind
        self.targetReference = targetReference
        self.proposedText = proposedText
        self.status = status
        self.diagnostics = diagnostics
        self.createdAt = createdAt
    }

    public func withStatus(_ status: AISuggestionStatus, diagnostics: [String] = []) -> AISuggestion {
        AISuggestion(
            id: id,
            requestID: requestID,
            kind: kind,
            targetReference: targetReference,
            proposedText: proposedText,
            status: status,
            diagnostics: diagnostics,
            createdAt: createdAt
        )
    }
}

public struct AIResponse: Codable, Equatable, Sendable {
    public let id: String
    public let requestID: String
    public let providerID: String
    public let status: AIResponseStatus
    public let suggestions: [AISuggestion]
    public let diagnostics: [String]
    public let completedAt: Date

    public init(id: String, requestID: String, providerID: String, status: AIResponseStatus, suggestions: [AISuggestion], diagnostics: [String] = [], completedAt: Date) {
        self.id = id
        self.requestID = requestID
        self.providerID = providerID
        self.status = status
        self.suggestions = suggestions
        self.diagnostics = diagnostics
        self.completedAt = completedAt
    }
}

public struct FakeAIProvider: Codable, Equatable, Sendable {
    public let providerID: String
    public let cannedText: String
    public let shouldFail: Bool

    public init(providerID: String = "fake-ai-provider", cannedText: String, shouldFail: Bool = false) {
        self.providerID = providerID
        self.cannedText = cannedText
        self.shouldFail = shouldFail
    }

    public func response(for request: AIRequest, now: Date) -> AIResponse {
        if shouldFail {
            return AIResponse(
                id: "response-\(request.id)",
                requestID: request.id,
                providerID: providerID,
                status: .failed,
                suggestions: [],
                diagnostics: ["The fake provider was configured to fail."],
                completedAt: now
            )
        }

        let suggestion = AISuggestion(
            id: "suggestion-\(request.id)",
            requestID: request.id,
            kind: request.kind,
            targetReference: request.targetReference,
            proposedText: cannedText,
            createdAt: now
        )
        return AIResponse(id: "response-\(request.id)", requestID: request.id, providerID: providerID, status: .success, suggestions: [suggestion], completedAt: now)
    }
}

public enum AIService {
    public static func requestSuggestion(_ request: AIRequest, aiEnabled: Bool, provider: FakeAIProvider, now: Date) -> AIResponse {
        guard aiEnabled else {
            return AIResponse(
                id: "response-\(request.id)",
                requestID: request.id,
                providerID: "disabled",
                status: .disabled,
                suggestions: [],
                diagnostics: ["AI is disabled for this project."],
                completedAt: now
            )
        }
        return provider.response(for: request, now: now)
    }
}

public struct AIRewriteApplicationResult: Equatable, Sendable {
    public let project: DreamJotterProject
    public let suggestion: AISuggestion
    public let snapshotCreated: Bool
    public let diagnostics: [String]

    public init(project: DreamJotterProject, suggestion: AISuggestion, snapshotCreated: Bool, diagnostics: [String] = []) {
        self.project = project
        self.suggestion = suggestion
        self.snapshotCreated = snapshotCreated
        self.diagnostics = diagnostics
    }
}

public enum AISuggestionWorkflow {
    public static func reject(_ suggestion: AISuggestion, in project: DreamJotterProject) -> AIRewriteApplicationResult {
        AIRewriteApplicationResult(project: project, suggestion: suggestion.withStatus(.rejected), snapshotCreated: false)
    }

    public static func acceptRewrite(
        _ suggestion: AISuggestion,
        in project: DreamJotterProject,
        snapshotID: String,
        now: Date,
        canCreateSnapshot: Bool = true
    ) -> AIRewriteApplicationResult {
        guard suggestion.kind == .rewrite else {
            let message = "Only rewrite suggestions can change screenplay text."
            return AIRewriteApplicationResult(project: project, suggestion: suggestion.withStatus(.failed, diagnostics: [message]), snapshotCreated: false, diagnostics: [message])
        }
        guard canCreateSnapshot else {
            let message = "A snapshot could not be created, so the rewrite was not applied."
            return AIRewriteApplicationResult(project: project, suggestion: suggestion.withStatus(.failed, diagnostics: [message]), snapshotCreated: false, diagnostics: [message])
        }

        let snapshot = SnapshotManager.createSnapshot(id: snapshotID, name: "Before AI rewrite", project: project, createdAt: now)
        let rewrittenScreenplay = ScreenplayParser.parse(suggestion.proposedText)
        let updatedProject = DreamJotterProject(
            metadata: project.metadata,
            screenplay: rewrittenScreenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots + [snapshot],
            exportPresets: project.exportPresets,
            story: StoryDevelopmentState(
                setup: project.story.setup,
                logline: project.story.logline,
                synopsis: project.story.synopsis,
                beatSheets: project.story.beatSheets,
                suggestions: project.story.suggestions + [suggestion.withStatus(.accepted)]
            )
        )
        return AIRewriteApplicationResult(project: updatedProject, suggestion: suggestion.withStatus(.accepted), snapshotCreated: true)
    }
}

public enum ContinuitySeverity: String, Codable, Equatable, Sendable {
    case info
    case warning
    case needsReview
}

public enum ContinuityConfidence: String, Codable, Equatable, Sendable {
    case low
    case medium
    case high
}

public struct ContinuityFinding: Codable, Equatable, Sendable {
    public let id: String
    public let ruleID: String
    public let severity: ContinuitySeverity
    public let confidence: ContinuityConfidence
    public let message: String
    public let evidence: [String]
    public let suggestedAction: String?

    public init(
        id: String,
        ruleID: String,
        severity: ContinuitySeverity,
        confidence: ContinuityConfidence,
        message: String,
        evidence: [String],
        suggestedAction: String? = nil
    ) {
        self.id = id
        self.ruleID = ruleID
        self.severity = severity
        self.confidence = confidence
        self.message = message
        self.evidence = evidence
        self.suggestedAction = suggestedAction
    }
}

public struct SceneMetadataCheck: Codable, Equatable, Sendable {
    public let sceneHeading: String
    public let key: String
    public let value: String

    public init(sceneHeading: String, key: String, value: String) {
        self.sceneHeading = sceneHeading
        self.key = key
        self.value = value
    }
}

public enum ContinuityAnalyzer {
    public static func findings(for project: DreamJotterProject, sceneMetadata: [SceneMetadataCheck] = []) -> [ContinuityFinding] {
        var findings: [ContinuityFinding] = []
        findings.append(contentsOf: characterVariantFindings(in: CharacterManager.records(for: project, now: project.metadata.modifiedAt)))
        findings.append(contentsOf: unknownCharacterFindings(in: project))
        findings.append(contentsOf: todoFindings(in: project))
        findings.append(contentsOf: conflictingMetadataFindings(in: sceneMetadata))
        return findings
    }

    private static func characterVariantFindings(in characters: [CharacterRecord]) -> [ContinuityFinding] {
        var byKey: [String: [CharacterRecord]] = [:]
        for character in characters {
            byKey[character.normalizedKey, default: []].append(character)
        }
        return byKey.values.compactMap { group in
            guard group.count > 1, let first = group.first, group.contains(where: { $0.displayName != first.displayName }) else {
                return nil
            }
            return ContinuityFinding(
                id: "character-variant-\(first.normalizedKey)",
                ruleID: "possible-character-spelling-mismatch",
                severity: .info,
                confidence: .medium,
                message: "These character names might be spelling variants: \(group.map(\.displayName).joined(separator: ", ")).",
                evidence: group.map(\.displayName),
                suggestedAction: "Keep both names if intentional, or merge them later."
            )
        }
    }

    private static func unknownCharacterFindings(in project: DreamJotterProject) -> [ContinuityFinding] {
        let knownKeys = Set(CharacterManager.records(for: project, now: project.metadata.modifiedAt).map(\.normalizedKey))
        guard !knownKeys.isEmpty else { return [] }
        var findings: [ContinuityFinding] = []
        var reported = Set<String>()
        let stopwords = Set(["A", "AN", "AND", "BUT", "DAY", "EXT", "INT", "NIGHT", "THE", "TODO"])

        for card in project.sceneCards {
            let text = [card.title, card.summary, card.note].joined(separator: " ")
            for token in candidateNames(in: text) {
                let key = TextNormalization.key(for: token)
                guard !knownKeys.contains(key), !stopwords.contains(key), reported.insert(key).inserted else { continue }
                findings.append(ContinuityFinding(
                    id: "unknown-character-\(key)",
                    ruleID: "unknown-character-reference",
                    severity: .needsReview,
                    confidence: .medium,
                    message: "\(token) is mentioned in planning, but is not in the character list yet.",
                    evidence: [card.id, token],
                    suggestedAction: "Add the character if they belong in the story, or revise the scene card."
                ))
            }
        }
        return findings
    }

    private static func todoFindings(in project: DreamJotterProject) -> [ContinuityFinding] {
        project.notes.compactMap { note in
            guard note.body.range(of: #"(^|\b)TODO:"#, options: [.regularExpression, .caseInsensitive]) != nil else { return nil }
            return ContinuityFinding(
                id: "todo-note-\(note.id)",
                ruleID: "unresolved-todo-note",
                severity: .info,
                confidence: .high,
                message: "A note still has a TODO marker.",
                evidence: [note.id],
                suggestedAction: "Resolve or rewrite the note when the decision is made."
            )
        }
    }

    private static func conflictingMetadataFindings(in metadata: [SceneMetadataCheck]) -> [ContinuityFinding] {
        var groups: [String: [SceneMetadataCheck]] = [:]
        for item in metadata {
            groups["\(item.sceneHeading)|\(item.key)", default: []].append(item)
        }
        return groups.values.compactMap { group in
            let values = Set(group.map { TextNormalization.key(for: $0.value) })
            guard values.count > 1, let first = group.first else { return nil }
            return ContinuityFinding(
                id: "metadata-conflict-\(TextNormalization.key(for: first.sceneHeading))-\(TextNormalization.key(for: first.key))",
                ruleID: "conflicting-scene-metadata",
                severity: .warning,
                confidence: .high,
                message: "\(first.sceneHeading) has conflicting \(first.key) details.",
                evidence: group.map { $0.value },
                suggestedAction: "Choose the intended value before exporting production notes."
            )
        }
    }

    private static func candidateNames(in text: String) -> [String] {
        text.components(separatedBy: CharacterSet.letters.inverted)
            .filter { token in
                guard let first = token.unicodeScalars.first else { return false }
                return CharacterSet.uppercaseLetters.contains(first) && token.count > 2
            }
    }
}

public struct FriendlyWarningText: Codable, Equatable, Sendable {
    public let title: String
    public let message: String
}

public enum FriendlyWarningLanguage {
    public static func text(for finding: ContinuityFinding) -> FriendlyWarningText {
        FriendlyWarningText(title: "Needs review", message: finding.message)
    }
}

public struct TableReadPlan: Codable, Equatable, Sendable {
    public let projectID: String
    public let scenes: [TableReadScene]
    public let speakingParts: [SpeakingPart]
    public let generatedAt: Date

    public init(projectID: String, scenes: [TableReadScene], speakingParts: [SpeakingPart], generatedAt: Date) {
        self.projectID = projectID
        self.scenes = scenes
        self.speakingParts = speakingParts
        self.generatedAt = generatedAt
    }
}

public struct TableReadScene: Codable, Equatable, Sendable {
    public let heading: String
    public let order: Int
    public let items: [TableReadItem]

    public init(heading: String, order: Int, items: [TableReadItem]) {
        self.heading = heading
        self.order = order
        self.items = items
    }
}

public enum TableReadItemKind: String, Codable, Equatable, Sendable {
    case sceneHeading
    case action
    case characterCue
    case parenthetical
    case dialogue
    case transition
}

public struct TableReadItem: Codable, Equatable, Sendable {
    public let kind: TableReadItemKind
    public let text: String
    public let speaker: String?
    public let order: Int

    public init(kind: TableReadItemKind, text: String, speaker: String?, order: Int) {
        self.kind = kind
        self.text = text
        self.speaker = speaker
        self.order = order
    }
}

public struct SpeakingPart: Codable, Equatable, Sendable {
    public let name: String
    public let normalizedKey: String
    public let firstOrder: Int

    public init(name: String, normalizedKey: String? = nil, firstOrder: Int) {
        self.name = name
        self.normalizedKey = normalizedKey ?? TextNormalization.key(for: name)
        self.firstOrder = firstOrder
    }
}

public enum TableReadPlanner {
    public static func plan(for project: DreamJotterProject, generatedAt: Date) -> TableReadPlan {
        var scenes: [TableReadScene] = []
        var currentHeading = "Unassigned"
        var currentItems: [TableReadItem] = []
        var currentSceneOrder = 0
        var itemOrder = 0
        var speakingParts: [SpeakingPart] = []
        var knownSpeakingKeys = Set<String>()

        func flushScene() {
            guard !currentItems.isEmpty else { return }
            scenes.append(TableReadScene(heading: currentHeading, order: currentSceneOrder, items: currentItems))
            currentItems = []
            currentSceneOrder += 1
        }

        for element in project.screenplay.elements {
            if element.kind == .sceneHeading {
                flushScene()
                currentHeading = element.text
            }

            guard let kind = tableReadKind(for: element.kind) else { continue }
            let speaker = element.kind == .dialogue ? element.characterName : (element.kind == .characterCue ? element.text : nil)
            if element.kind == .characterCue {
                let key = TextNormalization.key(for: element.text)
                if knownSpeakingKeys.insert(key).inserted {
                    speakingParts.append(SpeakingPart(name: element.text, normalizedKey: key, firstOrder: itemOrder))
                }
            }
            currentItems.append(TableReadItem(kind: kind, text: element.text, speaker: speaker, order: itemOrder))
            itemOrder += 1
        }
        flushScene()

        return TableReadPlan(projectID: project.metadata.id, scenes: scenes, speakingParts: speakingParts, generatedAt: generatedAt)
    }

    private static func tableReadKind(for kind: ScriptElementKind) -> TableReadItemKind? {
        switch kind {
        case .sceneHeading:
            return .sceneHeading
        case .action, .shot:
            return .action
        case .characterCue:
            return .characterCue
        case .parenthetical:
            return .parenthetical
        case .dialogue:
            return .dialogue
        case .transition:
            return .transition
        case .titlePage, .section, .synopsis, .noteReference, .pageBreak, .unknown:
            return nil
        }
    }
}
