import DreamJotterCore
import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Review Layout Numbering Tests")
struct ReviewLayoutNumberingTests {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("Review numbering defaults favor low-noise coordinates")
    func reviewNumberingDefaultsFavorLowNoiseCoordinates() {
        let options = ReviewLayoutNumberingOptions()

        #expect(options.showPage)
        #expect(options.showParagraph)
        #expect(options.showBlock == false)
        #expect(options.showSourceElement == false)
        #expect(options.showLine == false)
    }

    @Test("Review numbering exposes hierarchical addresses without dirtying clean project")
    func reviewNumberingPreservesCleanState() throws {
        let project = DreamJotterProject(
            metadata: metadata(),
            screenplay: ScreenplayDocument(elements: [
                ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
                ScriptElement(kind: .action, text: "Elena crosses the room."),
                ScriptElement(kind: .characterCue, text: "ELENA"),
                ScriptElement(kind: .dialogue, text: "We go now.")
            ])
        )
        let document = ProjectDocumentViewModel(project: project, isDirty: false)

        let plan = try #require(document.reviewPDFLayoutPlan)
        let lines = document.reviewLayoutLines

        #expect(document.isDirty == false)
        #expect(plan.contentPages.first?.screenplayPageNumber == 1)
        #expect(lines.first?.screenplayPageNumber == 1)
        #expect(lines.first?.paragraphNumber == 1)
        #expect(lines.first?.blockNumber == 1)
        #expect(lines.first?.lineNumber == 1)
        #expect(lines.first?.sourceElementIndex == 0)
        #expect(lines.first?.addressLabel == "Page 1 · Paragraph 1 · Block 1 · Source 0")
    }

    @Test("Review numbering preserves existing dirty state")
    func reviewNumberingPreservesDirtyState() {
        let project = DreamJotterProject(
            metadata: metadata(),
            screenplay: ScreenplayDocument(elements: [
                ScriptElement(kind: .action, text: "Visible action.")
            ])
        )
        let document = ProjectDocumentViewModel(project: project, isDirty: true)

        _ = document.reviewPDFLayoutPlan
        _ = document.reviewLayoutLines

        #expect(document.isDirty)
    }

    private func metadata() -> ProjectMetadata {
        ProjectMetadata(
            id: "project-review-numbering",
            title: "Review Numbering",
            createdAt: now,
            modifiedAt: now,
            schemaVersion: ProjectFactory.currentSchemaVersion,
            primaryScreenplayID: "screenplay-review-numbering"
        )
    }
}
