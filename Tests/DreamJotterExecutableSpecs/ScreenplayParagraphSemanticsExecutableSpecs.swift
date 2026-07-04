import DreamJotterCore
import Foundation
import Testing

@Suite("Screenplay Paragraph Semantics Executable Specs")
struct ScreenplayParagraphSemanticsExecutableSpecs {
    @Test("Blank paragraph terminates dialogue context")
    func blankParagraphTerminatesDialogueContext() {
        let document = ScreenplayParser.parse("SOFÍA\nHola.\n\nLa puerta se abre lentamente.")

        #expect(document.elements.map(\.paragraphType) == [
            .characterCue,
            .dialogue,
            .action
        ])
    }

    @Test("Explicit action after a character cue remains action")
    func explicitActionOverridesDialogueInference() {
        let document = ScreenplayParser.parse("SOFÍA\n! La puerta se abre lentamente.")

        #expect(document.elements.map(\.paragraphType) == [
            .characterCue,
            .action
        ])
    }

    @Test("Explicit paragraph types round trip")
    func explicitParagraphTypesRoundTrip() {
        let source = """
        . INT. HOUSE - DAY

        ! Rain crosses the window.

        + SOFÍA, 30s, enters carrying a red umbrella.

        @SOFÍA

        (quietly)

        : We should leave.

        > CUT TO:

        !! CLOSE ON: THE KEY

        # ACT TWO

        = The investigation continues.

        %% MONTAGE - SEARCHING THE CITY

        [[Tighten this sequence]]

        ===
        """

        let first = ScreenplayParser.parse(source)
        let exported = FountainIO.exportScreenplay(first)
        let second = ScreenplayParser.parse(exported)

        #expect(first.elements.map(\.paragraphType) == second.elements.map(\.paragraphType))
        #expect(first.elements.map(\.text) == second.elements.map(\.text))
        #expect(first.elements.map(\.paragraphType) == [
            .sceneHeading,
            .action,
            .characterIntroduction,
            .characterCue,
            .parenthetical,
            .dialogue,
            .transition,
            .shot,
            .section,
            .synopsis,
            .montage,
            .note,
            .pageBreak
        ])
    }

    @Test("Paragraph type control rewrites only the selected paragraph")
    func paragraphTypeControlRewritesSelection() {
        let source = "SOFÍA\n\nThe door opens.\n\nCUT TO:"
        let cursor = (source as NSString).range(of: "The door opens.").location
        let result = ScreenplayParagraphTypeControl.replacingCurrentParagraph(
            in: source,
            cursorLocation: cursor,
            with: .dialogue
        )

        #expect(result.text == "SOFÍA\n\n: The door opens.\n\nCUT TO:")
        #expect(ScreenplayParagraphTypeControl.selection(
            in: result.text,
            cursorLocation: result.cursorLocation
        ).type == .dialogue)
    }

    @Test("PDF layout follows explicit paragraph semantics")
    func pdfLayoutFollowsExplicitSemantics() throws {
        let preset = try #require(
            ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" }
        )
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "paragraph-semantics",
                title: "Paragraph Semantics",
                createdAt: .distantPast,
                modifiedAt: .distantPast,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay"
            ),
            screenplay: ScreenplayDocument(elements: [
                ScriptElement(
                    kind: .dialogue,
                    text: "This is explicitly action-width prose.",
                    paragraphType: .action
                ),
                ScriptElement(
                    kind: .action,
                    text: "This is explicitly dialogue.",
                    paragraphType: .dialogue
                )
            ])
        )

        let plan = PDFLayoutPlanner.plan(
            for: project,
            preset: preset,
            settings: PDFLayoutSettings(
                charactersPerBodyLine: 40,
                includeTitlePage: false,
                includePageNumbers: true,
                includeParagraphNumbers: true,
                includeLineNumbers: false
            )
        )
        let blocks = try #require(plan.contentPages.first?.blocks)

        #expect(blocks.map(\.role) == [.action, .dialogue])
        #expect(blocks[0].lines.contains { $0.text.count > 16 })
        #expect(blocks[1].lines.allSatisfy { $0.text.count <= 24 })
    }
}
