import DreamJotterCore
import Foundation
import Testing

@Suite("PDF Renderer Hardening Executable Specs")
struct PDFRendererHardeningExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("Windows-1252 characters use PDF octal escapes without warnings")
    func windows1252CharactersArePreserved() throws {
        let project = makeProject(
            title: "Café — Señor",
            elements: [
                ScriptElement(kind: .action, text: "Café — señor said “hello”.")
            ]
        )

        let output = ProductionPDFRenderer.renderOutput(
            project: project,
            preset: try preset("reader-copy")
        )
        let pdf = String(decoding: output.data, as: UTF8.self)

        #expect(pdf.contains("Caf\\351"))
        #expect(pdf.contains("\\227"))
        #expect(pdf.contains("se\\361or"))
        #expect(pdf.contains("\\223hello\\224"))
        #expect(output.diagnostics.contains { $0.code == .unsupportedCharacter } == false)
    }

    @Test("Unsupported characters are replaced and de-duplicated in diagnostics")
    func unsupportedCharactersAreReportedOnce() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Signal 🚀 then 🚀 again.")
        ])

        let output = ProductionPDFRenderer.renderOutput(
            project: project,
            preset: try preset("reader-copy")
        )
        let pdf = String(decoding: output.data, as: UTF8.self)
        let unsupported = output.diagnostics.filter { $0.code == .unsupportedCharacter }

        #expect(pdf.contains("Signal ? then ? again."))
        #expect(unsupported.count == 1)
        #expect(unsupported.first?.message.contains("🚀") == true)
    }

    @Test("Planner warnings are forwarded by detailed renderer output")
    func plannerWarningsAreForwarded() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Visible text."),
            ScriptElement(kind: .noteReference, text: "TODO private note")
        ])

        let output = ProductionPDFRenderer.renderOutput(
            project: project,
            preset: try preset("reader-copy")
        )

        #expect(output.diagnostics.contains { diagnostic in
            diagnostic.code == .layoutWarning && diagnostic.message.contains("omitted")
        })
    }

    @Test("PDF export succeeds with warnings and preserves dirty-state contract")
    func exportWorkflowSurfacesWarnings() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Launch 🚀")
        ])
        let preset = try preset("reader-copy")
        let request = ExportRequest(
            id: "request-hardening-warning",
            projectID: project.metadata.id,
            presetID: preset.id,
            format: .pdf,
            destinationPath: "/tmp/Hardening.pdf",
            includeNotes: false,
            includeMetadata: false,
            createdAt: now
        )

        let export = ExportWorkflow.exportData(
            for: project,
            request: request,
            preset: preset,
            generatedAt: now
        )

        #expect(export.data != nil)
        #expect(export.result.status == .success)
        #expect(export.result.userMessage == "Export complete with warnings.")
        #expect(export.result.technicalDetail?.contains("🚀") == true)
        #expect(export.result.dirtyStateChanged == false)
    }

    @Test("Detailed renderer output is deterministic")
    func detailedRendererOutputIsDeterministic() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Café 🚀")
        ])
        let preset = try preset("reader-copy")

        let first = ProductionPDFRenderer.renderOutput(project: project, preset: preset)
        let second = ProductionPDFRenderer.renderOutput(project: project, preset: preset)

        #expect(first == second)
    }

    private func preset(_ id: String) throws -> ExportPreset {
        try #require(ExportPresetCatalog.builtInPresets().first { $0.id == id })
    }

    private func makeProject(
        title: String = "Renderer Hardening",
        elements: [ScriptElement]
    ) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-renderer-hardening",
                title: title,
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-renderer-hardening"
            ),
            screenplay: ScreenplayDocument(elements: elements)
        )
    }
}
