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

    private func request(format: ExportFormat, presetID: String) -> ExportRequest {
        ExportRequest(
            id: "export-\(format.rawValue)",
            projectID: "project-m9",
            presetID: presetID,
            format: format,
            destinationPath: "/tmp/export.\(format.rawValue)",
            includeNotes: false,
            includeMetadata: false,
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
}
