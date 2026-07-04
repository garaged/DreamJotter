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

    @Test("Review numbering controls default to page and paragraph only")
    func reviewNumberingViewDefaultsMatchOptions() throws {
        let source = try simplifiedReviewNumberingViewSource()

        #expect(source.contains("@State private var showPage = true"))
        #expect(source.contains("@State private var showParagraph = true"))
        #expect(source.contains("@State private var showLine = false"))
        #expect(!source.contains("@State private var showLine = true"))
    }

    @Test("Review uses the print PDF preset with visible page numbers")
    func reviewUsesNumberedPrintPreset() throws {
        let document = ProjectDocumentViewModel(project: project(), isDirty: false)
        let plan = try #require(document.reviewPDFLayoutPlan)

        #expect(ProjectDocumentViewModel.reviewNumberedPDFPresetID == "print-script")
        #expect(plan.settings.includePageNumbers)
        #expect(plan.settings.includeParagraphNumbers)
        #expect(!plan.settings.includeLineNumbers)
        #expect(plan.settings.includeTitlePage)
        #expect(plan.settings.suppressIdentifyingMetadata == false)
        #expect(plan.contentPages.first?.screenplayPageNumber == 1)
    }

    @Test("Review numbering exposes page paragraph and line coordinates without dirtying clean project")
    func reviewNumberingPreservesCleanState() throws {
        let document = ProjectDocumentViewModel(project: project(), isDirty: false)

        let plan = try #require(document.reviewPDFLayoutPlan)
        let lines = document.reviewLayoutLines

        #expect(document.isDirty == false)
        #expect(plan.settings.includePageNumbers)
        #expect(plan.settings.includeParagraphNumbers)
        #expect(!plan.settings.includeLineNumbers)
        #expect(plan.contentPages.first?.screenplayPageNumber == 1)
        #expect(lines.first?.screenplayPageNumber == 1)
        #expect(lines.first?.paragraphNumber == 1)
        #expect(lines.first?.blockNumber == 1)
        #expect(lines.first?.lineNumber == 1)
        #expect(lines.first?.sourceElementIndex == 0)
        #expect(lines.first?.addressLabel == "Page 1 · Paragraph 1 · Block 1 · Source 0")
    }

    @Test("Wrapped screenplay paragraphs retain sequential line numbering")
    func wrappedParagraphLineNumbering() throws {
        let longAction = Array(repeating: "A measured action continues across the page.", count: 8)
            .joined(separator: " ")
        let project = DreamJotterProject(
            metadata: metadata(),
            screenplay: ScreenplayDocument(elements: [
                ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
                ScriptElement(kind: .action, text: longAction)
            ])
        )
        let document = ProjectDocumentViewModel(project: project, isDirty: false)
        let actionLines = document.reviewLayoutLines.filter { $0.role == .action }

        #expect(actionLines.count > 1)
        #expect(actionLines.map(\.paragraphNumber).allSatisfy { $0 == actionLines.first?.paragraphNumber })
        #expect(actionLines.map(\.lineNumber) == Array(1...actionLines.count))
    }

    @Test("Review numbering preserves existing dirty state")
    func reviewNumberingPreservesDirtyState() {
        let document = ProjectDocumentViewModel(project: project(), isDirty: true)

        _ = document.reviewPDFLayoutPlan
        _ = document.reviewLayoutLines

        #expect(document.isDirty)
    }

    private func simplifiedReviewNumberingViewSource() throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot
            .appendingPathComponent("Apps")
            .appendingPathComponent("DreamJotterMac")
            .appendingPathComponent("Views")
            .appendingPathComponent("SimplifiedReviewLayoutNumberingView.swift")

        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func project() -> DreamJotterProject {
        DreamJotterProject(
            metadata: metadata(),
            screenplay: ScreenplayDocument(elements: [
                ScriptElement(kind: .sceneHeading, text: "INT. ROOM - DAY"),
                ScriptElement(kind: .action, text: "Elena crosses the room."),
                ScriptElement(kind: .characterCue, text: "ELENA"),
                ScriptElement(kind: .dialogue, text: "We go now.")
            ])
        )
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
