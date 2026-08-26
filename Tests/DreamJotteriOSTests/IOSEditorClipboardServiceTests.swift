import DreamJotteriOS
import Testing

@Suite("iOS editor clipboard service")
struct IOSEditorClipboardServiceTests {
    @Test("selection expands to composed grapheme boundaries")
    func graphemeSafeSelection() {
        let text = "A👨‍👩‍👧‍👦B"
        let unsafe = IOSEditorSelection(location: 2, length: 1)
        let safe = IOSEditorClipboardService.graphemeSafeSelection(unsafe, in: text)

        #expect(safe.location == 1)
        #expect(safe.length > 1)
    }

    @Test("semantic copy expands partial selection to complete lines")
    func semanticCopy() {
        let text = "INT. ROOM - DAY\n\nAction line.\n\nCHARACTER\nDialogue.\n"
        let session = IOSEditorSession(
            text: text,
            selection: IOSEditorSelection(location: 2, length: 3)
        )
        let payload = IOSEditorClipboardService.copyPayload(from: session)

        #expect(payload?.plainText == "INT. ROOM - DAY\n")
        #expect(payload?.selection.location == 0)
    }

    @Test("cut removes complete semantic lines and keeps cursor stable")
    func semanticCut() {
        var session = IOSEditorSession(
            text: "INT. ROOM - DAY\nAction.\n",
            selection: IOSEditorSelection(location: 1, length: 2)
        )
        let payload = IOSEditorClipboardService.cut(session: &session)

        #expect(payload?.plainText == "INT. ROOM - DAY\n")
        #expect(session.text == "Action.\n")
        #expect(session.selection == IOSEditorSelection(location: 0, length: 0))
        #expect(session.lastMutationKind == .cut)
    }
}
