import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 4 Executable Specs")
struct Milestone4ExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_700_100_000)

    @Test("Milestone 4 pro foundation specs exist")
    func milestoneFourSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/acceptance/milestone-4-acceptance.md",
            "docs/routines/routine-system-v1-spec.md",
            "docs/architecture/command-engine-spec.md",
            "docs/plugins/future-plugin-extension-points.md",
            "docs/plugins/future-plugin-model.md",
            "docs/export/export-system-spec.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Revision colors and draft records are portable project metadata")
    func revisionsAndDraftsArePortableMetadata() {
        #expect(RevisionColorKind.allCases.map(\.rawValue) == ["blue", "pink", "yellow", "green", "goldenrod", "cherry", "custom"])
        let custom = RevisionColor(kind: .custom, displayName: "Studio Purple", portableValue: "#663399")
        let revision = RevisionSet(id: "revision-blue", label: "Blue pages", color: RevisionColor(kind: .blue), linkedElementIDs: ["element-1"], isActive: true, createdAt: now)
        let draft = DraftVersion(id: "draft-2", name: "Draft 2", sourceSnapshotID: "snapshot-001", revisionSetIDs: [revision.id], createdAt: now)

        #expect(custom.isValid)
        #expect(revision.color.kind == .blue)
        #expect(draft.sourceSnapshotID == "snapshot-001")
    }

    @Test("Draft comparison is read-only and reports semantic additions removals and moves")
    func draftComparisonIsReadOnly() {
        let left = ScreenplayParser.parse("INT. ROOM - DAY\n\nMARA\nStay.")
        let right = ScreenplayParser.parse("MARA\nStay.\n\nINT. ROOM - DAY\n\nJO\nRun.")

        let result = DraftComparer.compare(left: left, leftDraftID: "draft-1", right: right, rightDraftID: "draft-2")

        #expect(result.leftDraftID == "draft-1")
        #expect(result.changes.contains { $0.kind == .added && $0.elementText == "JO" })
        #expect(result.changes.contains { $0.kind == .moved && $0.elementText == "INT. ROOM - DAY" })
        #expect(left.elements.contains { $0.text == "INT. ROOM - DAY" })
    }

    @Test("Production breakdown categories validate and orphaned entries are advisory")
    func productionBreakdownCategoriesValidate() {
        #expect(ProductionBreakdownCategory.allCases.count == 13)
        let prop = ProductionBreakdownEntry(id: "breakdown-prop", sceneReference: "INT. ROOM - DAY", category: .props, title: "Key", createdAt: now)
        let orphan = ProductionBreakdownEntry(id: "breakdown-orphan", sceneReference: "EXT. PARK - DAY", category: .vehicles, title: "Van", createdAt: now)

        let orphaned = BreakdownValidator.orphanedEntries([prop, orphan], sceneReferences: ["INT. ROOM - DAY"])

        #expect(orphaned == [orphan])
    }

    @Test("Advanced export preset validation is structured and side-effect free")
    func advancedExportPresetValidationIsStructured() {
        let preset = AdvancedExportPreset(id: "production-pdf", title: "Production PDF", format: .pdf, scope: .project, options: ["includeRevisionColors": "true"], createdAt: now)

        let diagnostics = AdvancedExportPresetValidator.diagnostics(for: preset, supportedFormats: [.fountain])

        #expect(diagnostics == ["Export format is unavailable."])
        #expect(preset.options["includeRevisionColors"] == "true")
    }

    @Test("Custom field definitions validate typed values without coercion")
    func customFieldsValidateTypedValues() {
        let definition = CustomFieldDefinition(id: "field-status", name: "Status", type: .singleSelect, allowedTargets: [.scene], selectOptions: ["draft", "final"])
        let valid = CustomFieldValue(id: "value-1", definitionID: definition.id, targetKind: .scene, targetID: "scene-1", value: .singleSelect("draft"))
        let invalid = CustomFieldValue(id: "value-2", definitionID: definition.id, targetKind: .scene, targetID: "scene-1", value: .singleSelect("locked"))
        let typedBoolean = CustomFieldValue(id: "value-3", definitionID: "field-bool", targetKind: .scene, targetID: "scene-1", value: .boolean(true))

        #expect(CustomFieldType.allCases.map(\.rawValue) == ["text", "number", "boolean", "date", "singleSelect", "multiSelect"])
        #expect(CustomFieldValidator.validate(valid, against: definition).isEmpty)
        #expect(!CustomFieldValidator.validate(invalid, against: definition).isEmpty)
        if case .boolean(true) = typedBoolean.value {
            #expect(true)
        } else {
            Issue.record("Expected typed boolean value")
        }
    }

    @Test("Manual routines compile to CommandEngine requests in order")
    func manualRoutinesExecuteCommandsInOrder() {
        let project = makeProject()
        let routine = RoutineDefinition(
            id: "routine-1",
            title: "Snapshot and note",
            enabled: true,
            trigger: .manual,
            actions: [
                RoutineAction(kind: .createSnapshot),
                RoutineAction(kind: .addNote, payload: ["body": "Review the ending."])
            ],
            createdAt: now,
            updatedAt: now
        )

        let run = RoutineRunner.run(routine, project: project, trigger: .manual, runID: "run-1", now: now)

        #expect(run.log.status == .succeeded)
        #expect(run.log.commandRequests.map(\.type) == [.createSnapshot, .addNote])
        #expect(run.project.snapshots.count == 1)
        #expect(run.project.notes.contains { $0.body == "Review the ending." })
    }

    @Test("Disabled routines and failed snapshot policies do not mutate project state")
    func disabledAndSnapshotFailedRoutinesDoNotMutate() {
        let project = makeProject()
        let disabled = RoutineDefinition(id: "routine-disabled", title: "Disabled", enabled: false, trigger: .manual, actions: [RoutineAction(kind: .addNote, payload: ["body": "Nope"])], createdAt: now, updatedAt: now)
        let destructive = RoutineDefinition(id: "routine-destructive", title: "Destructive", enabled: true, trigger: .manual, actions: [RoutineAction(kind: .updateSceneStatus, payload: ["scene": "scene-1"], requiresSnapshot: true)], createdAt: now, updatedAt: now)

        let skipped = RoutineRunner.run(disabled, project: project, trigger: .manual, runID: "run-disabled", now: now)
        let failed = RoutineRunner.run(destructive, project: project, trigger: .manual, runID: "run-failed", now: now, canCreateSnapshot: false)

        #expect(skipped.log.status == .skipped)
        #expect(skipped.project == project)
        #expect(failed.log.status == .failed)
        #expect(failed.project == project)
        #expect(failed.log.commandRequests.first?.origin == .routine)
    }

    @Test("Pro Mode visibility hides authoring controls in Simple Mode and preserves metadata")
    func proModeVisibilityPreservesMetadata() {
        let pro = ProProjectState(
            revisionSets: [RevisionSet(id: "revision-1", label: "Blue", color: RevisionColor(kind: .blue), createdAt: now)],
            productionBreakdown: [ProductionBreakdownEntry(id: "breakdown-1", sceneReference: "scene-1", category: .props, title: "Key", createdAt: now)],
            customFieldDefinitions: [CustomFieldDefinition(id: "field-1", name: "Status", type: .text, allowedTargets: [.scene])],
            routines: [RoutineDefinition(id: "routine-1", title: "Routine", enabled: true, trigger: .manual, actions: [RoutineAction(kind: .runAnalysis)], createdAt: now, updatedAt: now)]
        )
        let project = DreamJotterProject(metadata: metadata(), screenplay: ScreenplayDocument(), mode: .simple, pro: pro)

        #expect(!ProModeVisibility.authoringControlsVisible(feature: "routines", mode: project.mode))
        #expect(ProModeVisibility.authoringControlsVisible(feature: "routines", mode: .pro))
        #expect(project.pro == pro)
    }

    @Test("Future plugin runtime and arbitrary scripting remain deferred")
    func milestoneFourDoesNotScopeArbitraryPluginScripting() throws {
        let milestoneFourCorpus = try [
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/plugins/future-plugin-extension-points.md",
            "docs/plugins/future-plugin-model.md",
            "docs/routines/routine-system-v1-spec.md"
        ]
        .map { try SpecRepository.read($0) }
        .joined(separator: "\n")

        #expect(FuturePluginPolicy.isDeferred(requiresRuntime: true, requiresArbitraryScripting: true))
        #expect(SpecRepository.contains(milestoneFourCorpus, "No arbitrary scripting"))
        #expect(SpecRepository.contains(milestoneFourCorpus, "plugin runtime"))
        #expect(SpecRepository.contains(milestoneFourCorpus, "deferred"))
        #expect(!SpecRepository.contains(milestoneFourCorpus, "Milestone 4 allows arbitrary scripting"))
    }

    @Test("Pro metadata persists through dreamjotter package save and load")
    func proMetadataPersistsThroughPackageStorage() throws {
        let pro = ProProjectState(
            draftVersions: [DraftVersion(id: "draft-2", name: "Draft 2", sourceSnapshotID: "snapshot-001", createdAt: now)],
            customFieldValues: [CustomFieldValue(id: "value-1", definitionID: "field-1", targetKind: .scene, targetID: "scene-1", value: .text("final"))]
        )
        let project = DreamJotterProject(metadata: metadata(), screenplay: ScreenplayParser.parse("INT. ROOM - DAY"), pro: pro)
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DreamJotterM4-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageURL = DreamJotterPackageStore.packageURL(for: project, in: root)
        try DreamJotterPackageStore.save(project, to: packageURL, updatedAt: now)
        let loadResult = DreamJotterPackageStore.load(from: packageURL)

        #expect(loadResult.diagnostics.isEmpty)
        #expect(loadResult.project?.pro == pro)
    }

    private func makeProject() -> DreamJotterProject {
        DreamJotterProject(metadata: metadata(), screenplay: ScreenplayParser.parse("INT. ROOM - DAY"))
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
