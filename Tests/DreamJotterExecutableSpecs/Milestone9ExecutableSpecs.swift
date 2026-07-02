import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 9 Executable Specs")
struct Milestone9ExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_783_728_000)

    @Test("Required export review health specs exist")
    func requiredExportReviewHealthSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-9-export-review-health.md",
            "docs/acceptance/milestone-9-acceptance.md",
            "docs/specs/export/export-presets-v1.spec.md",
            "docs/specs/export/export-workflow-v1.spec.md",
            "docs/specs/export/basic-pdf-export-adapter.spec.md",
            "docs/specs/export/backup-restore-workflow.spec.md",
            "docs/specs/review/review-mode-v1.spec.md",
            "docs/specs/analysis/script-health-report-v1.spec.md",
            "docs/specs/analysis/formatting-warning-v1.spec.md",
            "docs/specs/analysis/review-findings.spec.md",
            "docs/data-contracts/export-preset.md",
            "docs/data-contracts/export-request.md",
            "docs/data-contracts/export-result.md",
            "docs/data-contracts/backup-archive.md",
            "docs/data-contracts/restore-result.md",
            "docs/data-contracts/script-health-report.md",
            "docs/data-contracts/review-finding.md",
            "docs/data-contracts/review-mode-state.md",
            "docs/adr/0005-review-export-health-before-ios.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Export presets expose M9 user goals and privacy defaults")
    func exportPresetsExposeM9UserGoalsAndPrivacyDefaults() throws {
        let presets = ExportPresetCatalog.builtInPresets()
        let readerCopy = try #require(presets.first { $0.id == "reader-copy" })
        let contest = try #require(presets.first { $0.id == "contest-submission" })
        let backup = try #require(presets.first { $0.id == "writer-backup" })

        #expect(presets.map(\.id) == ["reader-copy", "contest-submission", "print-script", "writer-backup", "plain-text-archive"])
        #expect(readerCopy.allowedFormats.contains(.markdown))
        #expect(!readerCopy.includesNotes)
        #expect(!contest.includesInternalIDs)
        #expect(backup.includesInternalIDs)
        #expect(backup.includesNotes)
        #expect(backup.privacyWarning != nil)
    }

    @Test("Fountain plain text and Markdown exports are read-only text projections")
    func textExportsAreReadOnlyProjections() throws {
        let project = projectWithScript("""
        INT. ROOM - DAY

        ELENA
        We go now.
        """)
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "reader-copy" })

        let fountain = ExportWorkflow.exportText(
            for: project,
            request: request(format: .fountain, presetID: preset.id),
            preset: preset,
            generatedAt: now
        )
        let plain = ExportWorkflow.exportText(
            for: project,
            request: request(format: .plainText, presetID: preset.id),
            preset: preset,
            generatedAt: now
        )
        let markdown = ExportWorkflow.exportText(
            for: project,
            request: request(format: .markdown, presetID: preset.id),
            preset: preset,
            generatedAt: now
        )

        #expect(fountain.text == "INT. ROOM - DAY\n\nELENA\n\nWe go now.")
        #expect(plain.text == fountain.text)
        #expect(markdown.text?.contains("# M9 Export Test") == true)
        #expect(markdown.text?.contains("```fountain") == true)
        #expect(fountain.result.dirtyStateChanged == false)
        #expect(plain.result.dirtyStateChanged == false)
        #expect(markdown.result.dirtyStateChanged == false)
    }

    @Test("Unsupported preset format returns friendly failure")
    func unsupportedPresetFormatReturnsFriendlyFailure() throws {
        let project = projectWithScript("INT. ROOM - DAY")
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "plain-text-archive" })

        let export = ExportWorkflow.exportText(
            for: project,
            request: request(format: .markdown, presetID: preset.id),
            preset: preset,
            generatedAt: now
        )

        #expect(export.text == nil)
        #expect(export.result.status == .failed)
        #expect(export.result.userMessage == "This preset does not support the selected export format.")
        #expect(export.result.dirtyStateChanged == false)
    }

    @Test("JSON backup export creates a restorable archive with project metadata")
    func jsonBackupExportCreatesRestorableArchive() throws {
        let project = projectWithWorkspaceMetadata()
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "writer-backup" })

        let export = ExportWorkflow.exportText(
            for: project,
            request: request(format: .jsonBackup, presetID: preset.id, includeMetadata: true),
            preset: preset,
            generatedAt: now
        )

        let text = try #require(export.text)
        let archive = try BackupRestoreWorkflow.decode(Data(text.utf8))
        #expect(export.result.status == .success)
        #expect(export.result.dirtyStateChanged == false)
        #expect(archive.projectID == project.metadata.id)
        #expect(archive.containsCharacters)
        #expect(archive.containsLocations)
        #expect(archive.containsNotes)
        #expect(archive.containsSceneMetadata)
        #expect(archive.project.characters.first?.displayName == "ELENA")
        #expect(archive.project.locations.first?.displayName == "COFFEE SHOP")
        #expect(archive.project.notes.first?.body == "Resolve ending.")
        #expect(archive.project.sceneCards.first?.status == .needsRewrite)
    }

    @Test("Restore validation loads valid backup and preserves dirty current project protection")
    func restoreValidationLoadsValidBackupAndProtectsDirtyProject() throws {
        let project = projectWithWorkspaceMetadata()
        let archive = BackupRestoreWorkflow.makeArchive(for: project, createdAt: now)
        let data = try BackupRestoreWorkflow.encode(archive)

        let cleanRestore = BackupRestoreWorkflow.validateRestore(
            from: data,
            currentProjectIsDirty: false,
            completedAt: now
        )
        let dirtyRestore = BackupRestoreWorkflow.validateRestore(
            from: data,
            currentProjectIsDirty: true,
            completedAt: now
        )

        #expect(cleanRestore.project == project)
        #expect(cleanRestore.result.status == .restored)
        #expect(cleanRestore.result.dirtyStateChanged == false)
        #expect(dirtyRestore.project == nil)
        #expect(dirtyRestore.result.status == .confirmationRequired)
        #expect(dirtyRestore.result.userMessage == "Save or discard your current changes before restoring this backup.")
    }

    @Test("Restore validation returns friendly failure for invalid backup")
    func restoreValidationReturnsFriendlyFailureForInvalidBackup() {
        let restore = BackupRestoreWorkflow.validateRestore(
            from: Data("not-json".utf8),
            currentProjectIsDirty: false,
            completedAt: now
        )

        #expect(restore.project == nil)
        #expect(restore.result.status == .failed)
        #expect(restore.result.userMessage == "This backup could not be read.")
        #expect(restore.result.dirtyStateChanged == false)
    }

    @Test("Script health report counts project structure without mutating project")
    func scriptHealthReportCountsProjectStructureWithoutMutatingProject() throws {
        let project = projectWithScript("""
        INT. COFFEE SHOP - DAY

        ELENA
        We go now.

        [[TODO: improve the goodbye]]
        """)

        let report = ScriptHealthReportBuilder.report(for: project, generatedAt: now, lastSavedAt: now)

        #expect(report.sceneCount == 1)
        #expect(report.elementCount == project.screenplay.elements.count)
        #expect(report.unresolvedDetectedCharacterCount == 1)
        #expect(report.unresolvedDetectedLocationCount == 1)
        #expect(report.todoCount == 1)
        #expect(report.findings.contains { $0.source == .unresolvedCharacter && $0.message.contains("ELENA") })
        #expect(report.findings.contains { $0.source == .unresolvedLocation && $0.message.contains("COFFEE SHOP") })
        #expect(report.findings.contains { $0.source == .todo && $0.message.contains("improve the goodbye") })
        #expect(report.lastSavedAt == now)
        #expect(project.metadata.modifiedAt == now)
    }

    @Test("Health report identifies formatting warnings")
    func healthReportIdentifiesFormattingWarnings() {
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-m9",
                title: "M9 Export Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-m9"
            ),
            screenplay: ScreenplayDocument(
                elements: [
                    ScriptElement(kind: .sceneHeading, text: "INT. ROOM"),
                    ScriptElement(kind: .characterCue, text: "ELENA"),
                    ScriptElement(kind: .sceneHeading, text: "INT. ROOM")
                ],
                scenes: [
                    Scene(heading: "INT. ROOM", location: "ROOM", timeOfDay: nil),
                    Scene(heading: "INT. ROOM", location: "ROOM", timeOfDay: nil)
                ],
                characters: ["ELENA"]
            )
        )

        let report = ScriptHealthReportBuilder.report(for: project, generatedAt: now)

        #expect(report.formattingWarnings.contains { $0.title == "Scene heading missing time of day" })
        #expect(report.formattingWarnings.contains { $0.title == "Duplicate scene heading" })
        #expect(report.formattingWarnings.contains { $0.title == "Character cue without dialogue" })
        #expect(report.findings.contains { $0.source == .formatting })
        #expect(report.scenesWithoutDialogue.count == 2)
    }

    private func request(format: ExportFormat, presetID: String, includeMetadata: Bool = false) -> ExportRequest {
        ExportRequest(
            id: "export-\(format.rawValue)",
            projectID: "project-m9",
            presetID: presetID,
            format: format,
            destinationPath: "/tmp/export.\(format.rawValue)",
            includeNotes: false,
            includeMetadata: includeMetadata,
            createdAt: now
        )
    }

    private func projectWithScript(_ text: String) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-m9",
                title: "M9 Export Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-m9"
            ),
            screenplay: ScreenplayParser.parse(text)
        )
    }

    private func projectWithWorkspaceMetadata() -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-m9",
                title: "M9 Export Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-m9"
            ),
            screenplay: ScreenplayParser.parse("""
            INT. COFFEE SHOP - DAY

            ELENA
            We go now.
            """),
            characters: [
                CharacterRecord(id: "character-elena", displayName: "ELENA", createdAt: now, updatedAt: now)
            ],
            locations: [
                LocationRecord(id: "location-coffee-shop", displayName: "COFFEE SHOP", createdAt: now, updatedAt: now)
            ],
            notes: [
                ProjectNote(id: "note-ending", body: "Resolve ending.", createdAt: now, updatedAt: now)
            ],
            sceneCards: [
                SceneCard(
                    id: "scene-card-1",
                    sourceSceneHeading: "INT. COFFEE SHOP - DAY",
                    title: "Coffee Shop",
                    location: "COFFEE SHOP",
                    timeOfDay: "DAY",
                    status: .needsRewrite,
                    order: 0
                )
            ]
        )
    }
}
