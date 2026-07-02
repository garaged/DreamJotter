import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M11 FDX Interoperability")
struct FDXInterchangeExecutableSpecs {
    @Test("FDX export maps screenplay roles and escapes XML")
    func exportMapsRolesAndEscapesXML() throws {
        let document = ScreenplayDocument(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. CAFÉ & BAR - NIGHT"),
            ScriptElement(kind: .action, text: "Mara looks <inside>."),
            ScriptElement(kind: .characterCue, text: "MARA", characterName: "MARA"),
            ScriptElement(kind: .parenthetical, text: "(quietly)"),
            ScriptElement(kind: .dialogue, text: "We aren't leaving."),
            ScriptElement(kind: .transition, text: "CUT TO:")
        ])

        let result = FDXInterchange.export(document)
        let xml = try #require(String(data: result.data, encoding: .utf8))

        #expect(result.diagnostics.isEmpty)
        #expect(xml.contains("<FinalDraft DocumentType=\"Script\""))
        #expect(xml.contains("<Paragraph Type=\"Scene Heading\"><Text>INT. CAFÉ &amp; BAR - NIGHT</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Action\"><Text>Mara looks &lt;inside&gt;.</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Character\"><Text>MARA</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Dialogue\"><Text>We aren&apos;t leaving.</Text>"))
        #expect(xml.contains("<Paragraph Type=\"Transition\"><Text>CUT TO:</Text>"))
    }

    @Test("FDX import preserves supported paragraph order and derives scenes and characters")
    func importPreservesOrderAndDerivesData() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <FinalDraft DocumentType="Script" Template="No" Version="3">
          <Content>
            <Paragraph Type="Scene Heading"><Text>EXT. PLAZA - DAY</Text></Paragraph>
            <Paragraph Type="Action"><Text>People cross the square.</Text></Paragraph>
            <Paragraph Type="Character"><Text>SOFÍA</Text></Paragraph>
            <Paragraph Type="Parenthetical"><Text>(smiling)</Text></Paragraph>
            <Paragraph Type="Dialogue"><Text>Estamos listas.</Text></Paragraph>
          </Content>
        </FinalDraft>
        """

        let result = FDXInterchange.importDocument(from: Data(xml.utf8))
        let document = try #require(result.document)

        #expect(result.diagnostics.isEmpty)
        #expect(document.elements.map(\.kind) == [.sceneHeading, .action, .characterCue, .parenthetical, .dialogue])
        #expect(document.elements.map(\.text) == [
            "EXT. PLAZA - DAY",
            "People cross the square.",
            "SOFÍA",
            "(smiling)",
            "Estamos listas."
        ])
        #expect(document.characters == ["SOFÍA"])
        #expect(document.scenes == [Scene(heading: "EXT. PLAZA - DAY", location: "PLAZA", timeOfDay: "DAY")])
    }

    @Test("FDX round trip retains the supported semantic subset")
    func roundTripRetainsSupportedSubset() throws {
        let original = ScreenplayDocument(elements: [
            ScriptElement(kind: .sceneHeading, text: "INT. ROOM - NIGHT"),
            ScriptElement(kind: .action, text: "Rain taps the glass."),
            ScriptElement(kind: .characterCue, text: "ELENA", characterName: "ELENA"),
            ScriptElement(kind: .dialogue, text: "Listen."),
            ScriptElement(kind: .shot, text: "CLOSE ON THE WINDOW")
        ])

        let exported = FDXInterchange.export(original)
        let imported = FDXInterchange.importDocument(from: exported.data)
        let document = try #require(imported.document)

        #expect(exported.diagnostics.isEmpty)
        #expect(imported.diagnostics.isEmpty)
        #expect(document.elements.map(\.kind) == original.elements.map(\.kind))
        #expect(document.elements.map(\.text) == original.elements.map(\.text))
    }

    @Test("Unsupported DreamJotter elements are omitted with deterministic warnings")
    func unsupportedExportElementsProduceWarnings() {
        let document = ScreenplayDocument(elements: [
            ScriptElement(kind: .noteReference, text: "private note"),
            ScriptElement(kind: .pageBreak, text: "===")
        ])

        let result = FDXInterchange.export(document)

        #expect(result.diagnostics.map(\.code) == [
            "fdx.export.omittedElement",
            "fdx.export.omittedElement"
        ])
        #expect(result.diagnostics.map(\.paragraphIndex) == [0, 1])
        #expect(!String(decoding: result.data, as: UTF8.self).contains("private note"))
    }

    @Test("Unknown FDX paragraph types remain visible as unknown elements")
    func unknownParagraphTypeIsPreservedWithWarning() throws {
        let xml = """
        <FinalDraft DocumentType="Script" Version="3">
          <Content><Paragraph Type="Lyrics"><Text>Sing this line</Text></Paragraph></Content>
        </FinalDraft>
        """

        let result = FDXInterchange.importDocument(from: Data(xml.utf8))
        let document = try #require(result.document)

        #expect(document.elements == [ScriptElement(kind: .unknown, text: "Sing this line")])
        #expect(result.diagnostics.map(\.code) == ["fdx.import.unknownParagraphType"])
    }

    @Test("Malformed XML fails without producing a partial screenplay")
    func malformedXMLFailsSafely() {
        let result = FDXInterchange.importDocument(from: Data("<FinalDraft><Content>".utf8))

        #expect(result.document == nil)
        #expect(result.diagnostics.last?.severity == .error)
        #expect(result.diagnostics.last?.code == "fdx.import.invalidXML")
    }
}
