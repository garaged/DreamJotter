import DreamJotterCore
import Foundation
import Testing

@Suite("PDF Layout Planner Executable Specs")
struct PDFLayoutPlannerExecutableSpecs {
    @Test("PDF layout planner creates a simple deterministic plan")
    func pdfLayoutPlannerCreatesSimpleDeterministicPlan() throws {
        let now = Date(timeIntervalSince1970: 1_783_814_400)
        let preset = try #require(ExportPresetCatalog.builtInPresets().first { $0.id == "reader-copy" })
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "project-pdf-layout",
                title: "PDF Layout Test",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay-pdf-layout"
            ),
            screenplay: ScreenplayParser.parse("INT. ROOM - DAY")
        )

        let firstPlan = PDFLayoutPlanner.plan(for: project, preset: preset)
        let secondPlan = PDFLayoutPlanner.plan(for: project, preset: preset)

        #expect(firstPlan == secondPlan)
        #expect(firstPlan.documentTitle == "PDF Layout Test")
        #expect(firstPlan.pages.first?.isTitlePage == true)
        #expect(firstPlan.contentPages.first?.blocks.first?.role == .sceneHeading)
    }
}
