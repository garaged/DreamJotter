import DreamJotterCore
import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Screenplay Paragraph Inspector")
struct ScreenplayParagraphInspectorTests {
    private let now = Date(timeIntervalSince1970: 1_783_814_400)

    @Test("Inspector reports action after a completed dialogue block")
    func inspectorReportsActionAfterDialogue() {
        let text = "@SOFÍA\n\n: Hola.\n\n! La puerta se abre."
        let cursor = (text as NSString).range(of: "La puerta").location
        let document = makeDocument(text: text)

        #expect(document.paragraphSelection(at: cursor).type == .action)
    }

    @Test("Changing paragraph type updates source and parsed model")
    func changingParagraphTypeUpdatesSourceAndModel() {
        let text = "@SOFÍA\n\n: Hola.\n\nLa puerta se abre."
        let cursor = (text as NSString).range(of: "La puerta").location
        var document = makeDocument(text: text)

        document.setParagraphType(.characterIntroduction, at: cursor)

        #expect(document.scriptText.contains("+ La puerta se abre."))
        #expect(document.project.screenplay.elements.last?.paragraphType == .characterIntroduction)
        #expect(document.project.screenplay.elements.last?.kind == .action)
    }

    private func makeDocument(text: String) -> ProjectDocumentViewModel {
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "paragraph-inspector",
                title: "Paragraph Inspector",
                createdAt: now,
                modifiedAt: now,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay"
            ),
            screenplay: ScreenplayParser.parse(text)
        )
        return ProjectDocumentViewModel(project: project, scriptText: text)
    }
}
