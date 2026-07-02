import DreamJotterCore
import Foundation
import Testing

@Suite("PDF Regression Executable Specs")
struct PDFRegressionExecutableSpecs {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("Representative screenplay layout matches stable structural snapshot")
    func representativeLayoutMatchesStructuralSnapshot() throws {
        let project = makeProject(
            title: "Snapshot Script",
            elements: [
                ScriptElement(kind: .sceneHeading, text: "INT. LAB - NIGHT"),
                ScriptElement(kind: .action, text: "Mara studies the flickering console."),
                ScriptElement(kind: .characterCue, text: "MARA"),
                ScriptElement(kind: .parenthetical, text: "(under her breath)"),
                ScriptElement(kind: .dialogue, text: "Please hold together."),
                ScriptElement(kind: .transition, text: "CUT TO:")
            ]
        )
        let preset = try preset("print-script")
        let plan = PDFLayoutPlanner.plan(for: project, preset: preset)

        #expect(structuralSnapshot(plan) == """
        title=Snapshot Script
        pages=2
        page[1]:document=1,screenplay=-,title=true,blocks=1
          block=1,paragraph=-,source=-,role=title,lines=Snapshot Script
        page[2]:document=2,screenplay=1,title=false,blocks=6
          block=1,paragraph=1,source=0,role=sceneHeading,lines=INT. LAB - NIGHT
          block=2,paragraph=2,source=1,role=action,lines=Mara studies the flickering console.
          block=3,paragraph=3,source=2,role=characterCue,lines=MARA
          block=4,paragraph=4,source=3,role=parenthetical,lines=(under her breath)
          block=5,paragraph=5,source=4,role=dialogue,lines=Please hold together.
          block=6,paragraph=6,source=5,role=transition,lines=CUT TO:
        """)
    }

    @Test("Empty project produces a valid PDF")
    func emptyProjectProducesValidPDF() throws {
        let output = ProductionPDFRenderer.renderOutput(
            project: makeProject(title: "Empty Script", elements: []),
            preset: try preset("reader-copy")
        )
        let pdf = String(decoding: output.data, as: UTF8.self)

        #expect(pdf.hasPrefix("%PDF-1.4"))
        #expect(pdf.contains("/Type /Pages"))
        #expect(pdf.contains("/Count 2"))
        #expect(pdf.contains("Empty Script"))
        #expect(pdf.hasSuffix("%%EOF\n"))
    }

    @Test("Very long screenplay paginates deterministically")
    func veryLongScreenplayPaginatesDeterministically() throws {
        var elements: [ScriptElement] = []
        for scene in 1...120 {
            elements.append(ScriptElement(kind: .sceneHeading, text: "INT. LOCATION \(scene) - DAY"))
            elements.append(ScriptElement(
                kind: .action,
                text: "A deliberately long action paragraph for scene \(scene) repeats enough words to exercise wrapping and pagination without relying on explicit page breaks."
            ))
            elements.append(ScriptElement(kind: .characterCue, text: "WRITER"))
            elements.append(ScriptElement(kind: .dialogue, text: "This is dialogue number \(scene), and it must remain in the dialogue column."))
        }

        let project = makeProject(title: "Long Script", elements: elements)
        let preset = try preset("print-script")
        let firstPlan = PDFLayoutPlanner.plan(for: project, preset: preset)
        let secondPlan = PDFLayoutPlanner.plan(for: project, preset: preset)
        let pdf = String(decoding: ProductionPDFRenderer.render(plan: firstPlan), as: UTF8.self)

        #expect(firstPlan == secondPlan)
        #expect(firstPlan.contentPages.count >= 10)
        #expect(firstPlan.contentPages.map(\.screenplayPageNumber) == Array(1...firstPlan.contentPages.count).map(Optional.some))
        #expect(pdf.contains("/Count \(firstPlan.pages.count)"))
        #expect(pdf.contains("INT. LOCATION 120 - DAY"))
        #expect(pdf.contains("This is dialogue number 120"))
    }

    private func structuralSnapshot(_ plan: PDFLayoutPlan) -> String {
        var lines = ["title=\(plan.documentTitle)", "pages=\(plan.pages.count)"]
        for page in plan.pages {
            lines.append(
                "page[\(page.documentPageNumber)]:document=\(page.documentPageNumber),screenplay=\(page.screenplayPageNumber.map(String.init) ?? "-"),title=\(page.isTitlePage),blocks=\(page.blocks.count)"
            )
            for block in page.blocks {
                lines.append(
                    "  block=\(block.blockNumber),paragraph=\(block.paragraphNumber.map(String.init) ?? "-"),source=\(block.sourceElementIndex.map(String.init) ?? "-"),role=\(block.role.rawValue),lines=\(block.lines.map(\.text).joined(separator: " | "))"
                )
            }
        }
        return lines.joined(separator: "\n")
    }

    private func preset(_ id: String) throws -> ExportPreset {
        try #require(ExportPresetCatalog.builtInPresets().first { $0.id == id })
    }

    private func makeProject(title: String, elements: [ScriptElement]) -> DreamJotterProject {
        DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-pdf-regression",
                title: title,
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-pdf-regression"
            ),
            screenplay: ScreenplayDocument(elements: elements)
        )
    }
}
