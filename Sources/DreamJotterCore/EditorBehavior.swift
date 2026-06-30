import Foundation

public enum EditorMode: String, Equatable, Sendable {
    case simple
    case pro
}

public enum EditorBehavior {
    public static let tabCycle: [ScriptElementKind] = [
        .action,
        .sceneHeading,
        .characterCue,
        .dialogue,
        .parenthetical,
        .transition,
        .shot,
        .noteReference
    ]

    public static func nextKindAfterReturn(from currentKind: ScriptElementKind?, mode: EditorMode = .simple) -> ScriptElementKind {
        switch currentKind {
        case nil:
            return .sceneHeading
        case .sceneHeading:
            return .action
        case .characterCue:
            return .dialogue
        case .parenthetical:
            return .dialogue
        case .dialogue:
            return mode == .pro ? .characterCue : .action
        case .transition:
            return .sceneHeading
        case .noteReference:
            return .action
        case .titlePage,
             .action,
             .shot,
             .section,
             .synopsis,
             .pageBreak,
             .unknown:
            return .action
        }
    }

    public static func cycleKindAfterTab(from currentKind: ScriptElementKind) -> ScriptElementKind {
        guard let index = tabCycle.firstIndex(of: currentKind) else {
            return tabCycle[0]
        }

        let nextIndex = tabCycle.index(after: index)
        return tabCycle[nextIndex == tabCycle.endIndex ? tabCycle.startIndex : nextIndex]
    }

    public static func isSceneHeadingPrefix(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.range(of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.)$"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    public static func todoNotes(in document: ScreenplayDocument) -> [String] {
        document.elements.compactMap { element in
            switch element.kind {
            case .noteReference where element.text.range(of: #"(^|\b)TODO:"#, options: [.regularExpression, .caseInsensitive]) != nil:
                return element.text
            case .action where element.text.range(of: #"(^|\b)TODO:"#, options: [.regularExpression, .caseInsensitive]) != nil:
                return element.text
            default:
                return nil
            }
        }
    }
}
