import DreamJotterCore
import Foundation
import Testing

@Suite("M13 Paragraph Type Engine Regressions")
struct M13ParagraphTypeEngineRegressionSpecs {
    @Test("Completed dialogue cannot capture the following action paragraph")
    func dialogueContextStopsBeforeAction() {
        let source = """
        INT. ROOM - DAY

        CHARLES POSSE
        was waiting...

        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ullamcorper, elit nec interdum porttitor, nisl mi ultrices nibh, sit amet ultricies quam odio id libero.

        TOM
        Looking at infinity.

        Donec turpis nisl, sodales a fringilla in, rutrum posuere augue.
        """

        let document = ScreenplayParser.parse(source)
        #expect(document.elements.map(\.paragraphType) == [
            .sceneHeading,
            .characterCue,
            .dialogue,
            .action,
            .characterCue,
            .dialogue,
            .action
        ])
        #expect(document.elements[3].text.hasPrefix("Lorem ipsum"))
        #expect(document.elements[6].text.hasPrefix("Donec turpis"))
    }

    @Test("Parser-only action markers are inserted only after completed dialogue")
    func parserSafeSourceIsConservative() {
        let source = """
        INT. ROOM - DAY

        Rain moves across the glass.

        SOFÍA
        We should go.

        The door opens.

        Another action paragraph.
        """

        let safe = ScreenplayParagraphTypeEngine.parserSafeSource(source)
        #expect(!safe.contains("! Rain moves"))
        #expect(safe.contains("! The door opens."))
        #expect(!safe.contains("! Another action paragraph."))
    }

    @Test("Paragraph boundaries normalize mixed separators and blank-line runs")
    func paragraphBoundaryNormalization() {
        let source = "INT. ROOM - DAY\r\n\r\n\r\n! Action\u{2029}\u{2029}: Dialogue"
        let paragraphs = ScreenplayParagraphTypeEngine.paragraphs(in: source)

        #expect(paragraphs.map(\.type) == [.sceneHeading, .action, .dialogue])
        #expect(paragraphs.allSatisfy { $0.textRange.length > 0 })
    }

    @Test("Explicit markers have deterministic precedence")
    func explicitMarkersWin() {
        let cases: [(String, ScreenplayParagraphType)] = [
            (". INT. HOUSE - DAY", .sceneHeading),
            ("! SOFÍA", .action),
            ("+ SOFÍA enters.", .characterIntroduction),
            ("@SOFÍA", .characterCue),
            (": Hello.", .dialogue),
            ("> CUT TO:", .transition),
            ("!! CLOSE ON: KEY", .shot),
            ("# ACT TWO", .section),
            ("= Summary", .synopsis),
            ("%% MONTAGE", .montage),
            ("[[Fix this]]", .note),
            ("===", .pageBreak)
        ]

        for (source, expected) in cases {
            #expect(ScreenplayParagraphTypeEngine.type(for: source) == expected)
        }
    }

    @Test("Editor selection and style runs use identical paragraph boundaries")
    func editorSelectionMatchesStyling() throws {
        let source = ". INT. HOUSE - DAY\n\n! The door opens.\n\n@SOFÍA\n: Hello."
        let cursor = (source as NSString).range(of: "door").location
        let selection = ScreenplayParagraphTypeControl.selection(in: source, cursorLocation: cursor)
        let matchingRun = try #require(
            ScreenplayParagraphTypeControl.styleRuns(in: source).first {
                $0.textRange == selection.textRange
            }
        )

        #expect(selection.type == .action)
        #expect(matchingRun.kind == .action)
    }

    @Test("Print layout keeps post-dialogue prose at body width")
    func printLayoutUsesResolvedActionRole() throws {
        let screenplay = ScreenplayParser.parse("""
        INT. ROOM - DAY

        SOFÍA
        A short reply.

        This paragraph must use the full action width even though it follows dialogue.
        """)
        let project = DreamJotterProject(
            metadata: ProjectMetadata(
                id: "m13-pdf-regression",
                title: "M13 PDF Regression",
                createdAt: .distantPast,
                modifiedAt: .distantPast,
                schemaVersion: ProjectFactory.currentSchemaVersion,
                primaryScreenplayID: "screenplay"
            ),
            screenplay: screenplay
        )
        let preset = try #require(
            ExportPresetCatalog.builtInPresets().first { $0.id == "print-script" }
        )
        let plan = PDFLayoutPlanner.plan(
            for: project,
            preset: preset,
            settings: PDFLayoutSettings(
                charactersPerBodyLine: 60,
                includeTitlePage: false,
                includePageNumbers: true,
                includeParagraphNumbers: true,
                includeLineNumbers: false
            )
        )
        let blocks = try #require(plan.contentPages.first?.blocks)

        #expect(blocks.map(\.role) == [.sceneHeading, .characterCue, .dialogue, .action])
        #expect(blocks.last?.lines.first?.text.count ?? 0 > 24)
    }

    @Test("Formatting guide covers every editable paragraph type exactly once")
    func formattingGuideCoverage() {
        #expect(ScreenplayFormattingGuide.entries.map(\.type) == ScreenplayParagraphTypeControl.editableTypes)
        #expect(Set(ScreenplayFormattingGuide.entries.map(\.type)).count == ScreenplayFormattingGuide.entries.count)
        #expect(ScreenplayFormattingGuide.entries.allSatisfy {
            !$0.marker.isEmpty && !$0.example.isEmpty && !$0.guidance.isEmpty
        })
    }
}
