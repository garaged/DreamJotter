import Foundation

public enum IOSDeviceClass: String, Codable, Sendable {
    case phoneCompact
    case phoneRegular
    case padCompact
    case padRegular
}

public enum IOSWorkspacePresentation: String, Codable, Sendable {
    case singlePane
    case collapsibleSidebar
    case persistentSidebar
}

public enum IOSEditorHydrationMode: String, Codable, Sendable {
    case visibleWindow
    case completeDocument
}

public struct IOSWorkspacePolicy: Equatable, Sendable {
    public let presentation: IOSWorkspacePresentation
    public let editorHydration: IOSEditorHydrationMode
    public let maximumCachedDerivedViews: Int
    public let maximumPreviewElements: Int
    public let parseDebounceMilliseconds: Int
    public let autosaveDebounceMilliseconds: Int

    public static func policy(for deviceClass: IOSDeviceClass) -> IOSWorkspacePolicy {
        switch deviceClass {
        case .phoneCompact:
            return IOSWorkspacePolicy(
                presentation: .singlePane,
                editorHydration: .visibleWindow,
                maximumCachedDerivedViews: 2,
                maximumPreviewElements: 80,
                parseDebounceMilliseconds: 140,
                autosaveDebounceMilliseconds: 1_500
            )
        case .phoneRegular:
            return IOSWorkspacePolicy(
                presentation: .singlePane,
                editorHydration: .visibleWindow,
                maximumCachedDerivedViews: 3,
                maximumPreviewElements: 120,
                parseDebounceMilliseconds: 120,
                autosaveDebounceMilliseconds: 1_500
            )
        case .padCompact:
            return IOSWorkspacePolicy(
                presentation: .collapsibleSidebar,
                editorHydration: .visibleWindow,
                maximumCachedDerivedViews: 4,
                maximumPreviewElements: 180,
                parseDebounceMilliseconds: 100,
                autosaveDebounceMilliseconds: 1_250
            )
        case .padRegular:
            return IOSWorkspacePolicy(
                presentation: .persistentSidebar,
                editorHydration: .visibleWindow,
                maximumCachedDerivedViews: 6,
                maximumPreviewElements: 240,
                parseDebounceMilliseconds: 90,
                autosaveDebounceMilliseconds: 1_250
            )
        }
    }
}

public enum IOSPerformanceBudget {
    public static let editorInputP95Milliseconds = 16
    public static let navigationP95Milliseconds = 100
    public static let initialDocumentPresentationMilliseconds = 750
    public static let backgroundSaveMilliseconds = 2_000
    public static let memoryWarningCacheRetentionCount = 1
}
