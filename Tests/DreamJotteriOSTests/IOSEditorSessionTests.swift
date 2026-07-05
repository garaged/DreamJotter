import DreamJotterCore
import DreamJotteriOS
import Foundation
import Testing

@Suite("iOS editor session")
struct IOSEditorSessionTests {
    @Test("text changes advance revision and schedule parse and autosave")
    func changesScheduleDerivedWork() {
        var session = IOSEditorSession(text: "INT. ROOM - DAY")

        let revision = session.applyTextChange(
            replacementText: "INT. ROOM - DAY\n\nAction.",
            selection: IOSEditorSelection(location: 24, length: 0),
            kind: .typing
        )

        #expect(revision.value == 1)
        #expect(session.isDirty)
        #expect(session.parseRevisionPending == revision)
        #expect(session.autosaveRevisionPending == revision)
        #expect(session.lastMutationKind == .typing)
        #expect(session.selection.location == 24)
    }

    @Test("stale parse completion cannot clear newer work")
    func staleParseCompletionIsIgnored() {
        var session = IOSEditorSession(text: "A")
        let first = session.applyTextChange(
            replacementText: "AB",
            selection: IOSEditorSelection(location: 2, length: 0),
            kind: .typing
        )
        let second = session.applyTextChange(
            replacementText: "ABC",
            selection: IOSEditorSelection(location: 3, length: 0),
            kind: .typing
        )

        session.markParseCompleted(revision: first)
        #expect(session.parseRevisionPending == second)
        session.markParseCompleted(revision: second)
        #expect(session.parseRevisionPending == nil)
    }

    @Test("stale save cannot mark a newer revision clean")
    func staleSaveCannotClearDirtyState() {
        var session = IOSEditorSession(text: "A")
        let first = session.applyTextChange(
            replacementText: "AB",
            selection: IOSEditorSelection(location: 2, length: 0),
            kind: .typing
        )
        let second = session.applyTextChange(
            replacementText: "ABC",
            selection: IOSEditorSelection(location: 3, length: 0),
            kind: .typing
        )

        session.markSaveCompleted(revision: first)
        #expect(session.isDirty)
        #expect(session.autosaveRevisionPending == second)
        session.markSaveCompleted(revision: second)
        #expect(!session.isDirty)
        #expect(session.autosaveRevisionPending == nil)
    }

    @Test("selection is clamped in UTF-16 space")
    func selectionIsClamped() {
        let text = "SOFÍA 👩🏽‍💻"
        let length = (text as NSString).length
        let selection = IOSEditorSelection(location: length + 100, length: 50).clamped(to: text)

        #expect(selection.location == length)
        #expect(selection.length == 0)
    }

    @Test("formatting window is bounded around visible text")
    func formattingWindowIsBounded() {
        let text = String(repeating: "A", count: 50_000)
        let window = IOSEditorFormattingPolicy.formattingWindow(
            visibleRange: EditorTextRange(location: 20_000, length: 1_000),
            text: text,
            overscanUTF16Length: 2_000
        )

        #expect(window.range.location == 18_000)
        #expect(window.range.length == 5_000)
        #expect(window.range.length < (text as NSString).length)
    }

    @Test("device policy drives parse and autosave debounce")
    func debounceUsesWorkspacePolicy() {
        let phone = IOSEditorDebouncePolicy(
            workspacePolicy: IOSWorkspacePolicy.policy(for: .phoneCompact)
        )

        #expect(phone.parseDelayMilliseconds == 140)
        #expect(phone.autosaveDelayMilliseconds == 1_500)
    }
}
