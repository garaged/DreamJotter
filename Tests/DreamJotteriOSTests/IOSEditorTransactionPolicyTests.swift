import DreamJotteriOS
import Testing

@Suite("iOS editor transaction policy")
struct IOSEditorTransactionPolicyTests {
    @Test("typing may coalesce while semantic commands remain isolated")
    func transactionBoundaries() {
        #expect(IOSEditorTransactionPolicy.transaction(for: .typing).groupsWithTyping)
        #expect(!IOSEditorTransactionPolicy.transaction(for: .paste).groupsWithTyping)
        #expect(!IOSEditorTransactionPolicy.transaction(for: .smartEnter).groupsWithTyping)
        #expect(!IOSEditorTransactionPolicy.transaction(for: .elementFormatting).groupsWithTyping)
        #expect(!IOSEditorTransactionPolicy.transaction(for: .suggestionAcceptance).groupsWithTyping)
    }

    @Test("semantic actions have stable user-facing names")
    func actionNames() {
        #expect(IOSEditorTransactionPolicy.transaction(for: .smartEnter).actionName == "Smart Enter")
        #expect(IOSEditorTransactionPolicy.transaction(for: .elementFormatting).actionName == "Format Element")
        #expect(IOSEditorTransactionPolicy.transaction(for: .suggestionAcceptance).actionName == "Accept Suggestion")
    }
}
