import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 3 Executable Specs")
struct Milestone3ExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("Milestone 3 friendly writer tool specs exist")
    func milestoneThreeSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-3-friendly-writer-tools.md",
            "docs/acceptance/milestone-3-acceptance.md",
            "docs/ai/ai-abstraction-spec.md",
            "docs/specs/continuity-analysis-spec.md",
            "docs/specs/table-read-spec.md",
            "docs/ux/writing-experience-principles.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Guided setup, manual logline, synopsis, and beat sheet work without AI")
    func storyDevelopmentToolsWorkWithoutAI() {
        let setup = GuidedStorySetup.createManualSetup(
            workingTitle: "Night Market",
            formatIntent: "Short film",
            protagonist: "Mara",
            goal: "find her missing brother",
            obstacle: "the market closes at dawn",
            now: now
        )
        let logline = LoglineBuilder.composeManualLogline(
            protagonist: setup.protagonist,
            goal: setup.goal,
            obstacle: setup.obstacle,
            stakes: "before the city forgets him",
            now: now
        )
        let synopsis = SynopsisBuilder.buildSynopsis(
            setup: setup,
            beginning: "Mara enters the market.",
            middle: "The clues turn against her.",
            ending: "She chooses memory over safety.",
            now: now
        )
        let beatSheet = BeatSheetFactory.beginningMiddleEnd(now: now)

        #expect(setup.workingTitle == "Night Market")
        #expect(logline.source == .manual)
        #expect(logline.text.contains("Mara"))
        #expect(synopsis.findings.isEmpty)
        #expect(synopsis.record.text.contains("The clues turn against her."))
        #expect(beatSheet.beats.map(\.title) == ["Beginning", "Middle", "End"])
    }

    @Test("Synopsis builder reports missing setup context without blocking draft text")
    func synopsisReportsMissingSetupContext() {
        let synopsis = SynopsisBuilder.buildSynopsis(
            setup: nil,
            beginning: "A person starts over.",
            middle: "The old life returns.",
            ending: "A new choice sticks.",
            now: now
        )

        #expect(synopsis.record.text.contains("A person starts over."))
        #expect(synopsis.findings.contains { $0.ruleID == "missing-setup-context" })
    }

    @Test("Fake AI can preview a scene starter and disabled AI produces no suggestions")
    func fakeAIRespectsDisabledState() {
        let request = AIRequest(
            id: "scene-starter-1",
            kind: .sceneStarter,
            projectID: "project-1",
            targetReference: "scene-card-1",
            context: "Mara enters the night market.",
            createdAt: now
        )
        let provider = FakeAIProvider(cannedText: "INT. NIGHT MARKET - NIGHT\nMara stops at the first closed stall.")

        let enabled = AIService.requestSuggestion(request, aiEnabled: true, provider: provider, now: now)
        let disabled = AIService.requestSuggestion(request, aiEnabled: false, provider: provider, now: now)

        #expect(enabled.status == .success)
        #expect(enabled.suggestions.first?.status == .pending)
        #expect(enabled.suggestions.first?.proposedText.contains("NIGHT MARKET") == true)
        #expect(disabled.status == .disabled)
        #expect(disabled.providerID == "disabled")
        #expect(disabled.suggestions.isEmpty)
    }

    @Test("Rejecting an AI suggestion leaves the project unchanged")
    func rejectingAISuggestionLeavesProjectUnchanged() {
        let project = makeProject(source: "INT. ROOM - DAY\n\nMARA\nWe stay.")
        let suggestion = AISuggestion(
            id: "suggestion-1",
            requestID: "request-1",
            kind: .rewrite,
            targetReference: "screenplay",
            proposedText: "INT. ROOM - DAY\n\nMARA\nWe run.",
            createdAt: now
        )

        let result = AISuggestionWorkflow.reject(suggestion, in: project)

        #expect(result.project == project)
        #expect(result.suggestion.status == .rejected)
        #expect(!result.snapshotCreated)
    }

    @Test("Accepted AI rewrite creates a snapshot before mutating screenplay text")
    func acceptedRewriteCreatesSnapshotFirst() {
        let project = makeProject(source: "INT. ROOM - DAY\n\nMARA\nWe stay.")
        let suggestion = AISuggestion(
            id: "suggestion-2",
            requestID: "request-2",
            kind: .rewrite,
            targetReference: "screenplay",
            proposedText: "INT. ROOM - DAY\n\nMARA\nWe run.",
            createdAt: now
        )

        let result = AISuggestionWorkflow.acceptRewrite(suggestion, in: project, snapshotID: "snapshot-before-ai", now: now)

        #expect(result.snapshotCreated)
        #expect(result.suggestion.status == .accepted)
        #expect(result.project.snapshots.count == project.snapshots.count + 1)
        #expect(result.project.snapshots.last?.project.screenplay == project.screenplay)
        #expect(result.project.screenplay.elements.contains { $0.text == "We run." })
    }

    @Test("Snapshot failure prevents an AI rewrite")
    func snapshotFailurePreventsRewrite() {
        let project = makeProject(source: "INT. ROOM - DAY\n\nMARA\nWe stay.")
        let suggestion = AISuggestion(
            id: "suggestion-3",
            requestID: "request-3",
            kind: .rewrite,
            targetReference: "screenplay",
            proposedText: "INT. ROOM - DAY\n\nMARA\nWe run.",
            createdAt: now
        )

        let result = AISuggestionWorkflow.acceptRewrite(
            suggestion,
            in: project,
            snapshotID: "snapshot-before-ai",
            now: now,
            canCreateSnapshot: false
        )

        #expect(!result.snapshotCreated)
        #expect(result.project == project)
        #expect(result.suggestion.status == .failed)
    }

    @Test("Continuity analysis reports advisory findings without mutating project data")
    func continuityAnalysisIsReadOnlyAndFriendly() {
        let project = DreamJotterProject(
            metadata: metadata(),
            screenplay: ScreenplayParser.parse("INT. ROOM - DAY\n\nMARA\nWe wait."),
            characters: [
                CharacterRecord(id: "character-jose", displayName: "JOSE", normalizedKey: "JOSE", createdAt: now, updatedAt: now),
                CharacterRecord(id: "character-jose-accented", displayName: "JOSÉ", normalizedKey: "JOSE", createdAt: now, updatedAt: now),
                CharacterRecord(id: "character-mara", displayName: "MARA", normalizedKey: "MARA", createdAt: now, updatedAt: now)
            ],
            notes: [
                ProjectNote(id: "note-1", body: "TODO: decide whether the photo is real.", createdAt: now, updatedAt: now)
            ],
            sceneCards: [
                SceneCard(id: "scene-card-1", sourceSceneHeading: "INT. ROOM - DAY", title: "room", summary: "Victor watches from the hall.", order: 0)
            ]
        )
        let before = project

        let findings = ContinuityAnalyzer.findings(
            for: project,
            sceneMetadata: [
                SceneMetadataCheck(sceneHeading: "INT. ROOM - DAY", key: "timeOfDay", value: "DAY"),
                SceneMetadataCheck(sceneHeading: "INT. ROOM - DAY", key: "timeOfDay", value: "NIGHT")
            ]
        )

        #expect(project == before)
        #expect(findings.contains { $0.ruleID == "possible-character-spelling-mismatch" })
        #expect(findings.contains { $0.ruleID == "unknown-character-reference" && $0.evidence.contains("Victor") })
        #expect(findings.contains { $0.ruleID == "unresolved-todo-note" })
        #expect(findings.contains { $0.ruleID == "conflicting-scene-metadata" })
        #expect(findings.allSatisfy { !$0.message.contains("wrong") && !$0.message.contains("error") })
        #expect(FriendlyWarningLanguage.text(for: findings[0]).title == "Needs review")
    }

    @Test("Incomplete continuity inputs do not crash or invent findings")
    func incompleteContinuityInputsAreSafe() {
        let project = makeProject(source: "")

        let findings = ContinuityAnalyzer.findings(for: project)

        #expect(findings.isEmpty)
    }

    @Test("Table-read planner derives ordered scene items and speaking parts")
    func tableReadPlannerBuildsReadSequence() {
        let project = makeProject(source: """
        INT. ROOM - DAY

        MARA
        We stay.

        JO
        Then we listen.

        CUT TO:
        """)

        let plan = TableReadPlanner.plan(for: project, generatedAt: now)

        #expect(plan.projectID == project.metadata.id)
        #expect(plan.scenes.count == 1)
        #expect(plan.scenes[0].heading == "INT. ROOM - DAY")
        #expect(plan.scenes[0].items.contains { $0.kind == .dialogue && $0.speaker == "MARA" })
        #expect(plan.speakingParts.map(\.name) == ["MARA", "JO"])
    }

    @Test("Story development state persists through dreamjotter package save and load")
    func storyDevelopmentPersistsThroughPackageStorage() throws {
        let story = StoryDevelopmentState(
            setup: GuidedStorySetup.createManualSetup(workingTitle: "Night Market", formatIntent: "Short", now: now),
            logline: LoglineBuilder.composeManualLogline(protagonist: "Mara", goal: "find the door", obstacle: "the map lies", stakes: "before dawn", now: now),
            beatSheets: [BeatSheetFactory.beginningMiddleEnd(now: now)]
        )
        let project = DreamJotterProject(metadata: metadata(), screenplay: ScreenplayParser.parse("INT. MARKET - NIGHT"), story: story)
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterM3-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageURL = DreamJotterPackageStore.packageURL(for: project, in: root)
        try DreamJotterPackageStore.save(project, to: packageURL, updatedAt: now)
        let loadResult = DreamJotterPackageStore.load(from: packageURL)

        #expect(loadResult.diagnostics.isEmpty)
        #expect(loadResult.project?.story == story)
    }

    private func makeProject(source: String) -> DreamJotterProject {
        DreamJotterProject(metadata: metadata(), screenplay: ScreenplayParser.parse(source))
    }

    private func metadata() -> ProjectMetadata {
        ProjectMetadata(
            id: "project-1",
            title: "Test Project",
            createdAt: now,
            modifiedAt: now,
            schemaVersion: ProjectFactory.currentSchemaVersion,
            primaryScreenplayID: "screenplay-1"
        )
    }
}
