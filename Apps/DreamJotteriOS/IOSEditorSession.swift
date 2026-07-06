import DreamJotterCore
import Foundation

public struct IOSEditorSelection: Equatable, Codable, Sendable {
    public let location: Int
    public let length: Int

    public init(location: Int, length: Int) {
        self.location = max(0, location)
        self.length = max(0, length)
    }

    public func clamped(to text: String) -> IOSEditorSelection {
        let textLength = (text as NSString).length
        let safeLocation = min(location, textLength)
        return IOSEditorSelection(
            location: safeLocation,
            length: min(length, textLength - safeLocation)
        )
    }

    public var textRange: EditorTextRange {
        EditorTextRange(location: location, length: length)
    }
}

public enum IOSEditorMutationKind: String, Codable, Sendable {
    case typing
    case paste
    case cut
    case smartEnter
    case elementFormatting
    case suggestionAcceptance
    case externalReplacement
    case undo
    case redo
}

public struct IOSEditorRevision: Equatable, Codable, Sendable {
    public let value: UInt64

    public init(value: UInt64 = 0) {
        self.value = value
    }

    public func advanced() -> IOSEditorRevision {
        IOSEditorRevision(value: value &+ 1)
    }
}

public struct IOSEditorSession: Equatable, Sendable {
    public private(set) var text: String
    public private(set) var selection: IOSEditorSelection
    public private(set) var revision: IOSEditorRevision
    public private(set) var lastMutationKind: IOSEditorMutationKind?
    public private(set) var isDirty: Bool
    public private(set) var parseRevisionPending: IOSEditorRevision?
    public private(set) var autosaveRevisionPending: IOSEditorRevision?

    public init(
        text: String,
        selection: IOSEditorSelection = IOSEditorSelection(location: 0, length: 0),
        revision: IOSEditorRevision = IOSEditorRevision(),
        isDirty: Bool = false
    ) {
        self.text = text
        self.selection = selection.clamped(to: text)
        self.revision = revision
        self.lastMutationKind = nil
        self.isDirty = isDirty
        self.parseRevisionPending = nil
        self.autosaveRevisionPending = nil
    }

    @discardableResult
    public mutating func applyTextChange(
        replacementText: String,
        selection: IOSEditorSelection,
        kind: IOSEditorMutationKind
    ) -> IOSEditorRevision {
        text = replacementText
        self.selection = selection.clamped(to: replacementText)
        revision = revision.advanced()
        lastMutationKind = kind
        isDirty = true
        parseRevisionPending = revision
        autosaveRevisionPending = revision
        return revision
    }

    public mutating func updateSelection(_ selection: IOSEditorSelection) {
        self.selection = selection.clamped(to: text)
    }

    public mutating func markParseCompleted(revision completedRevision: IOSEditorRevision) {
        guard parseRevisionPending == completedRevision else { return }
        parseRevisionPending = nil
    }

    public mutating func markSaveCompleted(revision savedRevision: IOSEditorRevision) {
        guard autosaveRevisionPending == savedRevision,
              revision == savedRevision else { return }
        autosaveRevisionPending = nil
        isDirty = false
    }

    public mutating func markSaveFailed(revision failedRevision: IOSEditorRevision) {
        guard autosaveRevisionPending == failedRevision else { return }
        isDirty = true
    }
}
