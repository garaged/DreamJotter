import Foundation

public enum IOSAdaptiveLayoutClass: String, Codable, Sendable {
    case compactPhone
    case regularPhone
    case compactPad
    case regularPad
}

public enum IOSAdaptiveNavigationMode: String, Codable, Sendable {
    case singlePane
    case collapsibleSplit
    case persistentSplit
}

public enum IOSAdaptiveAutocompleteMode: String, Codable, Sendable {
    case compactFloatingCard
    case regularFloatingCard
}

public struct IOSAdaptiveLayoutMetrics: Equatable, Sendable {
    public let layoutClass: IOSAdaptiveLayoutClass
    public let navigationMode: IOSAdaptiveNavigationMode
    public let horizontalEditorInset: Double
    public let maximumReadableEditorWidth: Double
    public let autocompleteMode: IOSAdaptiveAutocompleteMode
    public let autocompleteMaximumWidth: Double
    public let showsCommandLabels: Bool
    public let showsKeyboardHelp: Bool
    public let preferredSidebarWidth: Double

    public static func resolve(
        availableWidth: Double,
        horizontalSizeClassIsCompact: Bool,
        idiomIsPad: Bool
    ) -> IOSAdaptiveLayoutMetrics {
        let layoutClass: IOSAdaptiveLayoutClass
        if idiomIsPad {
            layoutClass = horizontalSizeClassIsCompact || availableWidth < 700
                ? .compactPad
                : .regularPad
        } else {
            layoutClass = availableWidth < 390 ? .compactPhone : .regularPhone
        }

        return metrics(for: layoutClass)
    }

    public static func metrics(for layoutClass: IOSAdaptiveLayoutClass) -> IOSAdaptiveLayoutMetrics {
        switch layoutClass {
        case .compactPhone:
            return IOSAdaptiveLayoutMetrics(
                layoutClass: layoutClass,
                navigationMode: .singlePane,
                horizontalEditorInset: 8,
                maximumReadableEditorWidth: 540,
                autocompleteMode: .compactFloatingCard,
                autocompleteMaximumWidth: 520,
                showsCommandLabels: false,
                showsKeyboardHelp: false,
                preferredSidebarWidth: 0
            )
        case .regularPhone:
            return IOSAdaptiveLayoutMetrics(
                layoutClass: layoutClass,
                navigationMode: .singlePane,
                horizontalEditorInset: 12,
                maximumReadableEditorWidth: 600,
                autocompleteMode: .compactFloatingCard,
                autocompleteMaximumWidth: 560,
                showsCommandLabels: false,
                showsKeyboardHelp: false,
                preferredSidebarWidth: 0
            )
        case .compactPad:
            return IOSAdaptiveLayoutMetrics(
                layoutClass: layoutClass,
                navigationMode: .collapsibleSplit,
                horizontalEditorInset: 24,
                maximumReadableEditorWidth: 760,
                autocompleteMode: .regularFloatingCard,
                autocompleteMaximumWidth: 680,
                showsCommandLabels: true,
                showsKeyboardHelp: true,
                preferredSidebarWidth: 260
            )
        case .regularPad:
            return IOSAdaptiveLayoutMetrics(
                layoutClass: layoutClass,
                navigationMode: .persistentSplit,
                horizontalEditorInset: 36,
                maximumReadableEditorWidth: 820,
                autocompleteMode: .regularFloatingCard,
                autocompleteMaximumWidth: 720,
                showsCommandLabels: true,
                showsKeyboardHelp: true,
                preferredSidebarWidth: 280
            )
        }
    }
}
