import Foundation

public enum IOSApplicationLifecycleState: String, Codable, Sendable {
    case active
    case inactive
    case background
}

public enum IOSDocumentSaveReason: String, Codable, Sendable {
    case autosaveDebounce
    case sceneTransition
    case explicitSave
    case applicationBackgrounding
    case documentClose
}

public enum IOSDocumentSaveUrgency: Int, Comparable, Codable, Sendable {
    case deferred
    case normal
    case immediate

    public static func < (lhs: IOSDocumentSaveUrgency, rhs: IOSDocumentSaveUrgency) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct IOSDocumentSessionPolicy: Equatable, Sendable {
    public let reason: IOSDocumentSaveReason
    public let urgency: IOSDocumentSaveUrgency
    public let requiresBackgroundTask: Bool
    public let mustCheckExternalGeneration: Bool

    public static func saveDecision(
        reason: IOSDocumentSaveReason,
        lifecycleState: IOSApplicationLifecycleState
    ) -> IOSDocumentSessionPolicy {
        switch reason {
        case .autosaveDebounce:
            return IOSDocumentSessionPolicy(
                reason: reason,
                urgency: lifecycleState == .active ? .deferred : .immediate,
                requiresBackgroundTask: lifecycleState == .background,
                mustCheckExternalGeneration: true
            )
        case .sceneTransition:
            return IOSDocumentSessionPolicy(
                reason: reason,
                urgency: .normal,
                requiresBackgroundTask: lifecycleState == .background,
                mustCheckExternalGeneration: true
            )
        case .explicitSave:
            return IOSDocumentSessionPolicy(
                reason: reason,
                urgency: .immediate,
                requiresBackgroundTask: lifecycleState != .active,
                mustCheckExternalGeneration: true
            )
        case .applicationBackgrounding, .documentClose:
            return IOSDocumentSessionPolicy(
                reason: reason,
                urgency: .immediate,
                requiresBackgroundTask: true,
                mustCheckExternalGeneration: true
            )
        }
    }
}
