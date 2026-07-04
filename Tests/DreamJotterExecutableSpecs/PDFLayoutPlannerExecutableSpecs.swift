import DreamJotterCore
import Foundation
import Testing

@Suite("PDF Layout Planner Executable Specs")
struct PDFLayoutPlannerExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("PDF layout planner creates deterministic hierarchical numbering")
    func pdfLayoutPlannerCreatesDeterministicHierarchicalNumbering() throws {
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "reader-copy" })
        let project = project(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
            ScriptElement(kind: .action, text: "One two three four five"),
            ScriptElement(kind: .characterCue, text: "ELENA"),
            ScriptElement(kind: .dialogue, text: "We go now.")
        ])
        let settings = PDFLayoutSettings(charactersPerBodyLine: 12, contentLinesPerPage: 20)

        let firstPlan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)
        let secondPlan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)

        #expect(firstPlan == secondPlan)
        #expect(firstPlan.pages[0].documentPageNumber == 1)
        #expect(firstPlan.pages[0].screenplayPageNumber == nil)
        #expect(firstPlan.pages[1].documentPageNumber == 2)
        #expect(firstPlan.pages[1].screenplayPageNumber == 1)
        #expect(firstPlan.pages[1].blocks.map(\.blockNumber) == [1, 2, 3, 4])
        #expect(firstPlan.pages[1].blocks.map(\.paragraphNumber) == [1, 2, 3, 4])
        #expect(firstPlan.pages[1].blocks.map(\.sourceElementIndex) == [0, 1, 2, 3])
        #expect(firstPlan.pages[1].blocks[1].lines.map(\.lineNumber) == [1, 2, 3])
        #expect(firstPlan.pages[1].blocks[2].keepWithNext)

        let address = try #require(firstPlan.address(pageIndex: 1, blockIndex: 1, lineIndex: 1))
        #expect(address.documentPageNumber == 2)
        #expect(address.screenplayPageNumber == 1)
        #expect(address.blockNumber == 2)
        #expect(address.paragraphNumber == 2)
        #expect(address.lineNumber == 2)
        #expect(address.sourceElementIndex == 1)
    }

    @Test("Page breaks reset block numbering without consuming paragraph numbers")
    func pageBreaksResetBlocksWithoutConsumingParagraphNumbers() throws {
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" })
        let project = project(elements: [
            ScriptElement(kind: .action, text: "First paragraph."),
            ScriptElement(kind: .pageBreak, text: ""),
            ScriptElement(kind: .action, text: "Second paragraph.")
        ])
        let settings = PDFLayoutSettings(includeTitlePage: false, includePageNumbers: true)

        let plan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)

        #expect(plan.pages.count == 2)
        #expect(plan.pages.map(\.documentPageNumber) == [1, 2])
        #expect(plan.pages.map(\.screenplayPageNumber) == [1, 2])
        #expect(plan.pages.map { $0.blocks.first?.blockNumber } == [1, 1])
        #expect(plan.pages.map { $0.blocks.first?.paragraphNumber } == [1, 2])
        #expect(plan.pages.map { $0.blocks.first?.sourceElementIndex } == [0, 2])
    }

    @Test("Omitted notes do not consume paragraph numbering")
    func omittedNotesDoNotConsumeParagraphNumbering() throws {
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "reader-copy" })
        let project = project(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
            ScriptElement(kind: .noteReference, text: "TODO: private note"),
            ScriptElement(kind: .action, text: "Visible action.")
        ])

        let plan = PDFLayoutPlanner.plan(for: project, preset: preset)
        let blocks = try #require(plan.contentPages.first?.blocks)

        #expect(blocks.map(\.paragraphNumber) == [1, 2])
        #expect(blocks.map(\.sourceElementIndex) == [0, 2])
        #expect(plan.warnings.contains { $0.code == .notesOmitted })
        #expect(!blocks.flatMap(\.lines).contains { $0.text.contains("private note") })
    }

    @Test("Print Script suppresses stale line-number settings")
    func printScriptSuppressesStaleLineNumberSettings() throws {
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" })
        let settings = PDFLayoutSettings(
            includeTitlePage: false,
            includePageNumbers: true,
            includeParagraphNumbers: true,
            includeLineNumbers: true
        )

        let plan = PDFLayoutPlanner.plan(
            for: project(elements: [ScriptElement(kind: .action, text: "One paragraph.")]),
            preset: preset,
            settings: settings
        )

        #expect(plan.settings.includePageNumbers)
        #expect(plan.settings.includeParagraphNumbers)
        #expect(!plan.settings.includeLineNumbers)
    }

    @Test("Canonical paragraph semantics control PDF roles")
    func canonicalParagraphSemanticsControlPDFRoles() throws {
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" })
        let project = project(elements: [
            ScriptElement(
                kind: .dialogue,
                text: "Explicit action-width prose.",
                paragraphType: .action
            ),
            ScriptElement(kind: .characterCue, text: "TOM"),
            ScriptElement(kind: .action, text: "Explicit dialogue.", paragraphType: .dialogue),
            ScriptElement(kind: .section, text: "SEARCHING THE CITY", paragraphType: .montage)
        ])
        let settings = PDFLayoutSettings(
            charactersPerBodyLine: 40,
            includeTitlePage: false,
            includePageNumbers: true,
            includeParagraphNumbers: true,
            includeLineNumbers: false
        )

        let plan = PDFLayoutPlanner.plan(for: project, preset: preset, settings: settings)
        let blocks = try #require(plan.contentPages.first?.blocks)

        #expect(blocks.map(\.role) == [.action, .characterCue, .dialogue, .action])
        #expect(blocks[0].lines.contains { $0.text.count > 16 })
        #expect(blocks[2].lines.allSatisfy { $0.text.count <= 24 })
        #expect(blocks[3].lines.contains { $0.text.count > 16 })
    }

    private func project(elements: [ScriptElement]) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-pdf-layout",
                title: "PDF Layout Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-pdf-layout"
            ),
            screenplay: ScreenplayDocument(elements: elements)
        )
    }
}
