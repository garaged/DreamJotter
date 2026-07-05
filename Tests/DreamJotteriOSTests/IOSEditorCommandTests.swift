import DreamJotterCore
import DreamJotteriOS
import Foundation
import Testing

@Suite("iOS editor commands")
struct IOSEditorCommandTests {
    @Test("Smart Enter inserts the next semantic paragraph and preserves cursor")
    func smartEnterUsesCoreSemantics() {
        var session = IOSEditorSession(
            text: "INT. ROOM - DAY",
            selection: IOSEditorSelection(location: 15, length: 0)
        )

        let revision = IOSEditorCommandService.performSmartEnter(session: &session)

        #expect(revision.value == 1)
        #expect(session.text == "INT. ROOM - DAY\n\n")
        #expect(session.selection.location == 17)
        #expect(session.lastMutationKind == .smartEnter)
    }

    @Test("element cycling reuses core formatting behavior")
    func tabCycleUsesCoreSemantics() {
        var session = IOSEditorSession(
            text: "Action line",
            selection: IOSEditorSelection(location: 11, length: 0)
        )

        _ = IOSEditorCommandService.cycleCurrentElementKind(session: &session)

        #expect(session.lastMutationKind == .elementFormatting)
        #expect(session.isDirty)
        #expect(session.selection.location == (session.text as NSString).length)
    }

    @Test("suggestion acceptance updates text and cursor as one mutation")
    func suggestionAcceptanceIsAtomic() {
        var session = IOSEditorSession(
            text: "EL",
            selection: IOSEditorSelection(location: 2, length: 0)
        )
        let suggestion = EditorSuggestion(
            id: "character-elena",
            type: .character,
            displayText: "ELENA",
            replacementText: "ELENA",
            textRange: EditorTextRange(location: 0, length: 2),
            source: .projectCharacters
        )

        _ = IOSEditorCommandService.acceptSuggestion(suggestion, session: &session)

        #expect(session.text == "ELENA")
        #expect(session.selection.location == 5)
        #expect(session.lastMutationKind == .suggestionAcceptance)
    }
}
