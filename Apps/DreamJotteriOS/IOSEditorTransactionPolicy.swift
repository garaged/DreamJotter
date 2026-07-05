import Foundation

public struct IOSEditorTransaction: Equatable, Sendable {
    public let actionName: String
    public let groupsWithTyping: Bool

    public init(actionName: String, groupsWithTyping: Bool) {
        self.actionName = actionName
        self.groupsWithTyping = groupsWithTyping
    }
}

public enum IOSEditorTransactionPolicy {
    public static func transaction(for kind: IOSEditorMutationKind) -> IOSEditorTransaction {
        switch kind {
        case .typing:
            return IOSEditorTransaction(actionName: "Typing", groupsWithTyping: true)
        case .paste:
            return IOSEditorTransaction(actionName: "Paste", groupsWithTyping: false)
        case .cut:
            return IOSEditorTransaction(actionName: "Cut", groupsWithTyping: false)
        case .smartEnter:
            return IOSEditorTransaction(actionName: "Smart Enter", groupsWithTyping: false)
        case .elementFormatting:
            return IOSEditorTransaction(actionName: "Format Element", groupsWithTyping: false)
        case .suggestionAcceptance:
            return IOSEditorTransaction(actionName: "Accept Suggestion", groupsWithTyping: false)
        case .undo:
            return IOSEditorTransaction(actionName: "Undo", groupsWithTyping: false)
        case .redo:
            return IOSEditorTransaction(actionName: "Redo", groupsWithTyping: false)
        }
    }
}
