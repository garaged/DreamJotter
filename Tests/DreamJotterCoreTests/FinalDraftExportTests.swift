import DreamJotterCore
import Testing

@Suite("Final Draft XML export")
struct FinalDraftExportTests {
    @Test("maps screenplay elements to FDX paragraph types")
    func paragraphTypes() {
        let document = ScreenplayParser.parse("""
        INT. ROOM - DAY

        A door opens.

        ALEX
        (quietly)
        Hello.

        CUT TO:
        """)

        let xml = FinalDraftExport.xml(for: document, title: "Sample")

        #expect(xml.contains("<FinalDraft DocumentType=\"Script\""))
        #expect(xml.contains("<Paragraph Type=\"Scene Heading\"><Text>INT. ROOM - DAY</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Action\"><Text>A door opens.</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Character\"><Text>ALEX</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Parenthetical\"><Text>(quietly)</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Dialogue\"><Text>Hello.</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Transition\"><Text>CUT TO:</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Title\"><Text>Sample</Text>"))
    }

    @Test("escapes XML-sensitive text")
    func escapesXML() {
        let document = ScreenplayParser.parse("INT. LAB - DAY\n\nA < B & C > D.")
        let xml = FinalDraftExport.xml(for: document, title: "A & B")

        #expect(xml.contains("A &lt; B &amp; C &gt; D."))
        #expect(xml.contains("A &amp; B"))
    }
}
