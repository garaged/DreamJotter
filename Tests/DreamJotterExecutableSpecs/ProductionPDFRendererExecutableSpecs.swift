import DreamJotterCore
import Foundation
import Testing

@Suite("Production PDF Renderer Executable Specs")
struct ProductionPDFRendererExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("Production renderer writes valid multi-page PDF structure")
    func rendererWritesMultiPageStructure() throws {
        let preset = try preset("print-script")
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "First page."),
            ScriptElement(kind: .pageBreak, text: ""),
            ScriptElement(kind: .action, text: "Second page.")
        ])
        let settings = PDFLayoutSettings(
            contentLinesPerPage: 20,
            includeTitlePage: true,
            includePageNumbers: true
        )
        let plan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)

        let pdf = pdfString(ProductionPDFRenderer.render(plan: plan))

        #expect(pdf.hasPrefix("%PDF-1.4"))
        #expect(pdf.contains("/Type /Pages"))
        #expect(pdf.contains("/Count 3"))
        #expect(pdf.contains("First page."))
        #expect(pdf.contains("Second page."))
        #expect(pdf.hasSuffix("%%EOF\n"))
    }

    @Test("Renderer uses role-specific fonts and horizontal positions")
    func rendererUsesRoleSpecificStyles() throws {
        let preset = try preset("reader-copy")
        let project = makeProject(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
            ScriptElement(kind: .action, text: "Elena crosses the room."),
            ScriptElement(kind: .characterCue, text: "ELENA"),
            ScriptElement(kind: .parenthetical, text: "(quietly)"),
            ScriptElement(kind: .dialogue, text: "We go now."),
            ScriptElement(kind: .transition, text: "CUT TO:")
        ])

        let pdf = pdfString(ProductionPDFRenderer.render(project: project, preset: preset))

        #expect(pdf.contains("/F2 12 Tf 90"))
        #expect(pdf.contains("/F2 12 Tf 270"))
        #expect(pdf.contains("/F1 12 Tf 235"))
        #expect(pdf.contains("/F1 12 Tf 195"))
        #expect(pdf.contains("CUT TO:"))
    }

    @Test("Preset controls visible screenplay page numbers")
    func presetControlsVisiblePageNumbers() throws {
        let project = makeProject(elements: [ScriptElement(kind: .action, text: "Visible body.")])
        let readerPDF = pdfString(ProductionPDFRenderer.render(project: project, preset: try preset("reader-copy")))
        let printPDF = pdfString(ProductionPDFRenderer.render(project: project, preset: try preset("print-script")))

        #expect(!readerPDF.contains("(1.) Tj"))
        #expect(printPDF.contains("(1.) Tj"))
    }

    @Test("Print Script renders page paragraph and line numbering")
    func printScriptRendersFullNumbering() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
            ScriptElement(kind: .action, text: "A visible action paragraph.")
        ])

        let printPDF = pdfString(ProductionPDFRenderer.render(
            project: project,
            preset: try preset("print-script")
        ))
        let readerPDF = pdfString(ProductionPDFRenderer.render(
            project: project,
            preset: try preset("reader-copy")
        ))

        #expect(printPDF.contains("(1.) Tj"))
        #expect(printPDF.contains("(P1 \\267 L1) Tj"))
        #expect(printPDF.contains("(P2 \\267 L1) Tj"))
        #expect(!readerPDF.contains("(P1 \\267 L1) Tj"))
    }

    @Test("Line numbering remains sequential within a wrapped paragraph")
    func wrappedParagraphLineNumbersAreSequential() throws {
        let text = Array(repeating: "This action continues across a deliberately narrow body line.", count: 5)
            .joined(separator: " ")
        let project = makeProject(elements: [ScriptElement(kind: .action, text: text)])
        let preset = try preset("print-script")
        let defaults = PDFLayoutSettings.defaults(for: preset)
        let settings = PDFLayoutSettings(
            pageSize: defaults.pageSize,
            margins: defaults.margins,
            lineHeight: defaults.lineHeight,
            charactersPerBodyLine: 24,
            contentLinesPerPage: defaults.contentLinesPerPage,
            includeTitlePage: false,
            includePageNumbers: true,
            includeParagraphNumbers: true,
            includeLineNumbers: true,
            suppressIdentifyingMetadata: defaults.suppressIdentifyingMetadata
        )
        let plan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)
        let pdf = pdfString(ProductionPDFRenderer.render(plan: plan))

        #expect(pdf.contains("(P1 \\267 L1) Tj"))
        #expect(pdf.contains("(L2) Tj"))
    }

    @Test("Built-in screenplay presets produce distinct deterministic PDF artifacts")
    func builtInPDFPresetsProduceDistinctArtifacts() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
            ScriptElement(kind: .action, text: "Distinct screenplay body.")
        ])
        let presets = try [preset("reader-copy"), preset("print-script"), preset("contest-submission")]
        let artifacts = presets.map { ProductionPDFRenderer.render(project: project, preset: $0) }

        #expect(artifacts.count == 3)
        #expect(Set(artifacts).count == 3)

        let rendered = artifacts.map(pdfString)
        #expect(rendered.filter { $0.contains("/Count 2") }.count == 2)
        #expect(rendered.filter { $0.contains("/Count 1") }.count == 1)
    }

    @Test("Renderer escapes PDF strings and preserves Windows-1252 text")
    func rendererEscapesPDFStrings() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Path \\tmp (draft) café")
        ])

        let pdf = pdfString(ProductionPDFRenderer.render(project: project, preset: try preset("reader-copy")))

        #expect(pdf.contains("Path \\\\tmp \\(draft\\) caf\\351"))
    }

    @Test("Reader-facing PDF omits TODO elements")
    func readerFacingPDFOmitsTODOElements() throws {
        let project = makeProject(elements: [
            ScriptElement(kind: .action, text: "Visible screenplay text."),
            ScriptElement(kind: .noteReference, text: "TODO secret rewrite")
        ])

        let pdf = pdfString(ProductionPDFRenderer.render(project: project, preset: try preset("reader-copy")))

        #expect(pdf.contains("Visible screenplay text."))
        #expect(!pdf.contains("TODO secret rewrite"))
    }

    @Test("Existing export workflow produces numbered production PDF without dirty-state change")
    func exportWorkflowProducesProductionPDF() throws {
        let preset = try preset("print-script")
        let project = makeProject(elements: [ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY")])
        let request = ExportRequest(
            id: "request-production-pdf",
            projectID: project.metadata.id,
            presetID: preset.id,
            format: .pdf,
            destinationPath: "/tmp/Production.pdf",
            includeNotes: false,
            includeMetadata: false,
            createdAt: now
        )

        let export = ExportWorkflow.exportData(for: project, request: request, preset: preset, generatedAt: now)
        let pdf = try #require(export.data).withUnsafeBytes { rawBuffer in
            String(decoding: rawBuffer, as: UTF8.self)
        }

        #expect(export.result.status == .success)
        #expect(export.result.dirtyStateChanged == false)
        #expect(pdf.contains("/Count 2"))
        #expect(pdf.contains("/Courier-Bold"))
        #expect(pdf.contains("(P1 \\267 L1) Tj"))
    }

    private func preset(_ id: String) throws -> ExportPreset {
        try #require(ExportPresetCatalog.builtInPresets().first { $0.id == id })
    }

    private func makeProject(elements: [ScriptElement]) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-production-pdf",
                title: "Production PDF Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-production-pdf"
            ),
            screenplay: ScreenplayDocument(elements: elements)
        )
    }

    private func pdfString(_ data: Data) -> String {
        String(decoding: data, as: UTF8.self)
    }
}
