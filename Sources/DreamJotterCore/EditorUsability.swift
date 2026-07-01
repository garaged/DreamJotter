import Foundation

public struct EditorTextRange: Codable, Equatable, Sendable {
    public let location: Int
    public let length: Int

    public init(location: Int, length: Int) {
        self.location = max(0, location)
        self.length = max(0, length)
    }
}

public enum EditorSuggestionType: String, Codable, Equatable, Sendable {
    case character
    case location
    case sceneHeading
    case timeOfDay
    case elementKind
}

public enum EditorSuggestionSource: String, Codable, Equatable, Sendable {
    case projectCharacters
    case parsedLocations
    case screenplaySyntax
    case recentUsage
}

public struct EditorSuggestion: Codable, Equatable, Sendable {
    public let id: String
    public let type: EditorSuggestionType
    public let displayText: String
    public let replacementText: String
    public let textRange: EditorTextRange
    public let priority: Double?
    public let source: EditorSuggestionSource

    public init(
        id: String,
        type: EditorSuggestionType,
        displayText: String,
        replacementText: String,
        textRange: EditorTextRange,
        priority: Double? = nil,
        source: EditorSuggestionSource
    ) {
        self.id = id
        self.type = type
        self.displayText = displayText
        self.replacementText = replacementText
        self.textRange = textRange
        self.priority = priority
        self.source = source
    }
}

public enum EditorNavigationSyncStatus: String, Codable, Equatable, Sendable {
    case idle
    case pendingEditorToScene
    case pendingSceneToEditor
    case resolved
    case unresolved
}

public enum EditorScrollTargetKind: String, Codable, Equatable, Sendable {
    case scene
    case element
    case textRange
}

public struct EditorScrollTarget: Codable, Equatable, Sendable {
    public let kind: EditorScrollTargetKind
    public let id: String?
    public let textRange: EditorTextRange?

    public init(kind: EditorScrollTargetKind, id: String? = nil, textRange: EditorTextRange? = nil) {
        self.kind = kind
        self.id = id
        self.textRange = textRange
    }
}

public struct EditorNavigationState: Codable, Equatable, Sendable {
    public let selectedSceneID: String?
    public let selectedScriptElementID: String?
    public let cursorTextRange: EditorTextRange?
    public let scrollTarget: EditorScrollTarget?
    public let lastKnownParseRevision: Int?
    public let syncStatus: EditorNavigationSyncStatus

    public init(
        selectedSceneID: String? = nil,
        selectedScriptElementID: String? = nil,
        cursorTextRange: EditorTextRange? = nil,
        scrollTarget: EditorScrollTarget? = nil,
        lastKnownParseRevision: Int? = nil,
        syncStatus: EditorNavigationSyncStatus = .idle
    ) {
        self.selectedSceneID = selectedSceneID
        self.selectedScriptElementID = selectedScriptElementID
        self.cursorTextRange = cursorTextRange
        self.scrollTarget = scrollTarget
        self.lastKnownParseRevision = lastKnownParseRevision
        self.syncStatus = syncStatus
    }
}

public struct EditorParseState: Codable, Equatable, Sendable {
    public let currentTextRevision: Int
    public let lastParsedTextRevision: Int?
    public let isParsing: Bool
    public let lastParseDate: Date?
    public let parseWarnings: [String]
    public let parseErrors: [String]
    public let sceneCount: Int
    public let elementCount: Int

    public init(
        currentTextRevision: Int = 0,
        lastParsedTextRevision: Int? = nil,
        isParsing: Bool = false,
        lastParseDate: Date? = nil,
        parseWarnings: [String] = [],
        parseErrors: [String] = [],
        sceneCount: Int = 0,
        elementCount: Int = 0
    ) {
        self.currentTextRevision = currentTextRevision
        self.lastParsedTextRevision = lastParsedTextRevision
        self.isParsing = isParsing
        self.lastParseDate = lastParseDate
        self.parseWarnings = parseWarnings
        self.parseErrors = parseErrors
        self.sceneCount = sceneCount
        self.elementCount = elementCount
    }
}

public struct EditorLineCycleResult: Codable, Equatable, Sendable {
    public let text: String
    public let previousKind: ScriptElementKind
    public let nextKind: ScriptElementKind

    public init(text: String, previousKind: ScriptElementKind, nextKind: ScriptElementKind) {
        self.text = text
        self.previousKind = previousKind
        self.nextKind = nextKind
    }
}

public struct EditorLineStyleRun: Codable, Equatable, Sendable {
    public let kind: ScriptElementKind
    public let textRange: EditorTextRange

    public init(kind: ScriptElementKind, textRange: EditorTextRange) {
        self.kind = kind
        self.textRange = textRange
    }
}

public enum EditorUsabilityService {
    public static let debounceInterval: TimeInterval = 0.35
    public static let commonTimesOfDay = [
        "DAY",
        "NIGHT",
        "MORNING",
        "EVENING",
        "CONTINUOUS",
        "LATER"
    ]

    public static func nextKindAfterEnter(from currentKind: ScriptElementKind?, mode: EditorMode = .simple) -> ScriptElementKind {
        EditorBehavior.nextKindAfterReturn(from: currentKind, mode: mode)
    }

    public static func cycleKindAfterTab(from currentKind: ScriptElementKind) -> ScriptElementKind {
        EditorBehavior.cycleKindAfterTab(from: currentKind)
    }

    public static func cycleLineKind(text: String, currentKind: ScriptElementKind) -> EditorLineCycleResult {
        EditorLineCycleResult(
            text: text,
            previousKind: currentKind,
            nextKind: cycleKindAfterTab(from: currentKind)
        )
    }

    public static func smartEnterInsertion(after currentKind: ScriptElementKind?, mode: EditorMode = .simple) -> String {
        switch nextKindAfterEnter(from: currentKind, mode: mode) {
        case .sceneHeading:
            return "\n\nINT. "
        case .action:
            return "\n\n"
        case .dialogue:
            return "\n"
        default:
            return "\n"
        }
    }

    public static func lineKind(for lineText: String, previousKind: ScriptElementKind? = nil) -> ScriptElementKind {
        let trimmed = lineText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unknown }

        if trimmed.hasPrefix("[["), trimmed.hasSuffix("]]") {
            return .noteReference
        }
        if trimmed.hasPrefix("@") {
            return .characterCue
        }
        if trimmed.hasPrefix(">") {
            return .transition
        }
        if trimmed.hasPrefix("!") {
            return .action
        }
        if trimmed.hasPrefix("("), trimmed.hasSuffix(")") {
            return .parenthetical
        }
        if isSceneHeading(trimmed)
            || (trimmed.hasPrefix(".") && isSceneHeading(String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces))) {
            return .sceneHeading
        }
        if isTransition(trimmed) {
            return .transition
        }
        if isShot(trimmed) {
            return .shot
        }
        if previousKind == .characterCue || previousKind == .parenthetical {
            return .dialogue
        }
        if isUppercaseLike(trimmed), trimmed.split(whereSeparator: \.isWhitespace).count <= 3 {
            return .characterCue
        }
        return .action
    }

    public static func tabCycledLineText(_ lineText: String, currentKind: ScriptElementKind) -> EditorLineCycleResult {
        let nextKind = cycleKindAfterTab(from: currentKind)
        return EditorLineCycleResult(
            text: plainLineText(lineText, as: nextKind),
            previousKind: currentKind,
            nextKind: nextKind
        )
    }

    public static func styleRuns(in text: String) -> [EditorLineStyleRun] {
        lineContexts(in: text).compactMap { context in
            let kind = lineKind(for: context.text, previousKind: context.previousKind)
            switch kind {
            case .sceneHeading, .characterCue, .transition, .noteReference:
                return EditorLineStyleRun(kind: kind, textRange: context.range)
            default:
                return nil
            }
        }
    }

    public static func parseStateAfterTextChange(_ state: EditorParseState) -> EditorParseState {
        EditorParseState(
            currentTextRevision: state.currentTextRevision + 1,
            lastParsedTextRevision: state.lastParsedTextRevision,
            isParsing: false,
            lastParseDate: state.lastParseDate,
            parseWarnings: state.parseWarnings,
            parseErrors: state.parseErrors,
            sceneCount: state.sceneCount,
            elementCount: state.elementCount
        )
    }

    public static func shouldParse(now: Date, lastEditAt: Date, minimumDelay: TimeInterval = debounceInterval) -> Bool {
        now.timeIntervalSince(lastEditAt) >= minimumDelay
    }

    public static func refreshedParseState(
        textRevision: Int,
        document: ScreenplayDocument,
        date: Date
    ) -> EditorParseState {
        EditorParseState(
            currentTextRevision: textRevision,
            lastParsedTextRevision: textRevision,
            isParsing: false,
            lastParseDate: date,
            parseWarnings: document.diagnostics.map(\.message),
            parseErrors: [],
            sceneCount: document.scenes.count,
            elementCount: document.elements.count
        )
    }

    public static func characterSuggestions(
        prefix: String,
        characters: [String],
        replacementRange: EditorTextRange
    ) -> [EditorSuggestion] {
        suggestions(
            prefix: prefix,
            values: characters,
            type: .character,
            source: .projectCharacters,
            replacementRange: replacementRange
        )
    }

    public static func locationSuggestions(
        prefix: String,
        scenes: [Scene],
        replacementRange: EditorTextRange
    ) -> [EditorSuggestion] {
        suggestions(
            prefix: locationQuery(from: prefix),
            values: scenes.map(\.location),
            type: .location,
            source: .parsedLocations,
            replacementRange: replacementRange
        )
    }

    public static func sceneHeadingSuggestions(
        prefix: String,
        scenes: [Scene],
        replacementRange: EditorTextRange
    ) -> [EditorSuggestion] {
        let trimmed = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        var results: [EditorSuggestion] = []

        if EditorBehavior.isSceneHeadingPrefix(trimmed) {
            let replacement = "\(trimmed.uppercased()) "
            results.append(EditorSuggestion(
                id: "scene-heading-\(normalizedKey(for: trimmed))",
                type: .sceneHeading,
                displayText: replacement,
                replacementText: replacement,
                textRange: replacementRange,
                priority: 1.0,
                source: .screenplaySyntax
            ))
        }

        results.append(contentsOf: locationSuggestions(
            prefix: prefix,
            scenes: scenes,
            replacementRange: replacementRange
        ))

        results.append(contentsOf: timeOfDaySuggestions(
            prefix: timeOfDayQuery(from: prefix),
            replacementRange: replacementRange
        ))

        return collapsedByID(results)
    }

    public static func timeOfDaySuggestions(
        prefix: String,
        replacementRange: EditorTextRange
    ) -> [EditorSuggestion] {
        suggestions(
            prefix: prefix,
            values: commonTimesOfDay,
            type: .timeOfDay,
            source: .screenplaySyntax,
            replacementRange: replacementRange
        )
    }

    public static func currentLine(in text: String, cursorLocation: Int) -> (text: String, range: EditorTextRange) {
        let nsText = text as NSString
        let safeLocation = min(max(0, cursorLocation), nsText.length)
        let fullRange = NSRange(location: 0, length: nsText.length)
        let lineRange = nsText.lineRange(for: NSRange(location: safeLocation, length: 0))
        let clampedRange = NSIntersectionRange(lineRange, fullRange)
        let line = nsText.substring(with: clampedRange).trimmingCharacters(in: .newlines)
        return (line, EditorTextRange(location: clampedRange.location, length: clampedRange.length))
    }

    public static func replacing(range: EditorTextRange, in text: String, with replacement: String) -> String {
        let mutableText = NSMutableString(string: text)
        let maxLocation = mutableText.length
        let location = min(range.location, maxLocation)
        let length = min(range.length, maxLocation - location)
        mutableText.replaceCharacters(in: NSRange(location: location, length: length), with: replacement)
        return mutableText as String
    }

    public static func navigationStateForScene(
        at index: Int,
        text: String,
        scenes: [Scene],
        parseRevision: Int
    ) -> EditorNavigationState {
        let ranges = sceneHeadingRanges(in: text, scenes: scenes)
        guard ranges.indices.contains(index) else {
            return EditorNavigationState(lastKnownParseRevision: parseRevision, syncStatus: .unresolved)
        }

        let match = ranges[index]
        return EditorNavigationState(
            selectedSceneID: match.id,
            cursorTextRange: match.range,
            scrollTarget: EditorScrollTarget(kind: .scene, id: match.id, textRange: match.range),
            lastKnownParseRevision: parseRevision,
            syncStatus: .resolved
        )
    }

    public static func navigationStateForCursor(
        location: Int,
        text: String,
        scenes: [Scene],
        parseRevision: Int
    ) -> EditorNavigationState {
        let ranges = sceneHeadingRanges(in: text, scenes: scenes)
        let safeLocation = min(max(0, location), (text as NSString).length)
        guard let match = ranges.last(where: { $0.range.location <= safeLocation }) else {
            return EditorNavigationState(
                cursorTextRange: EditorTextRange(location: safeLocation, length: 0),
                lastKnownParseRevision: parseRevision,
                syncStatus: .unresolved
            )
        }

        return EditorNavigationState(
            selectedSceneID: match.id,
            cursorTextRange: EditorTextRange(location: safeLocation, length: 0),
            lastKnownParseRevision: parseRevision,
            syncStatus: .resolved
        )
    }

    private static func suggestions(
        prefix: String,
        values: [String],
        type: EditorSuggestionType,
        source: EditorSuggestionSource,
        replacementRange: EditorTextRange
    ) -> [EditorSuggestion] {
        let query = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        var orderedKeys: [String] = []
        var buckets: [String: String] = [:]

        for value in values {
            let displayText = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !displayText.isEmpty else { continue }

            let key = normalizedKey(for: displayText)
            if buckets[key] == nil {
                orderedKeys.append(key)
                buckets[key] = displayText
            }
        }

        let queryKey = normalizedKey(for: query)
        return orderedKeys.compactMap { key in
            guard key.hasPrefix(queryKey), let displayText = buckets[key] else { return nil }
            return EditorSuggestion(
                id: "\(type.rawValue)-\(key)",
                type: type,
                displayText: displayText,
                replacementText: displayText,
                textRange: replacementRange,
                priority: key == queryKey ? 1.0 : 0.75,
                source: source
            )
        }
    }

    private struct LineContext {
        let text: String
        let range: EditorTextRange
        let previousKind: ScriptElementKind?
    }

    private static func lineContexts(in text: String) -> [LineContext] {
        let nsText = text as NSString
        var contexts: [LineContext] = []
        var previousKind: ScriptElementKind?
        var location = 0

        while location < nsText.length {
            let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
            let line = nsText.substring(with: lineRange).trimmingCharacters(in: .newlines)
            let kind = lineKind(for: line, previousKind: previousKind)
            contexts.append(LineContext(
                text: line,
                range: EditorTextRange(location: lineRange.location, length: lineRange.length),
                previousKind: previousKind
            ))
            if kind != .unknown {
                previousKind = kind
            }
            location = lineRange.location + max(lineRange.length, 1)
        }

        if nsText.length == 0 {
            contexts.append(LineContext(text: "", range: EditorTextRange(location: 0, length: 0), previousKind: nil))
        }

        return contexts
    }

    private static func plainLineText(_ lineText: String, as kind: ScriptElementKind) -> String {
        let content = strippedControlSyntax(from: lineText).trimmingCharacters(in: .whitespacesAndNewlines)

        switch kind {
        case .action:
            return content.isEmpty ? "!" : "! \(content)"
        case .characterCue:
            return content.uppercased()
        case .dialogue:
            return content
        case .parenthetical:
            let inner = content.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
            return inner.isEmpty ? "()" : "(\(inner))"
        case .transition:
            let uppercased = content.uppercased()
            return uppercased.hasSuffix(" TO:") || uppercased.hasSuffix(":") ? uppercased : "\(uppercased) TO:"
        case .shot:
            let uppercased = content.uppercased()
            return uppercased.hasSuffix(":") ? uppercased : "\(uppercased):"
        case .noteReference:
            return "[[\(content)]]"
        default:
            return lineText
        }
    }

    private static func strippedControlSyntax(from lineText: String) -> String {
        let trimmed = lineText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("@") || trimmed.hasPrefix(">") || trimmed.hasPrefix("!") {
            return String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        if trimmed.hasPrefix("[["), trimmed.hasSuffix("]]") {
            return String(trimmed.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
        }
        return trimmed
    }

    private static func collapsedByID(_ suggestions: [EditorSuggestion]) -> [EditorSuggestion] {
        var seen: Set<String> = []
        var results: [EditorSuggestion] = []
        for suggestion in suggestions where !seen.contains(suggestion.id) {
            seen.insert(suggestion.id)
            results.append(suggestion)
        }
        return results
    }

    private static func locationQuery(from prefix: String) -> String {
        var query = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        let uppercased = query.uppercased()
        for scenePrefix in ["INT./EXT.", "EXT./INT.", "INT.", "EXT."] where uppercased.hasPrefix(scenePrefix) {
            query = String(query.dropFirst(scenePrefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            break
        }

        if let dashIndex = query.firstIndex(of: "-") {
            query = String(query[..<dashIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return query
    }

    private static func timeOfDayQuery(from prefix: String) -> String {
        guard let dashIndex = prefix.lastIndex(of: "-") else { return "" }
        return String(prefix[prefix.index(after: dashIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isSceneHeading(_ line: String) -> Bool {
        line.range(of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.)\s+.+"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private static func isTransition(_ line: String) -> Bool {
        let uppercaseLine = line.uppercased()
        return uppercaseLine.hasSuffix(" TO:")
            || uppercaseLine == "CUT TO:"
            || uppercaseLine == "CORTE A:"
            || uppercaseLine == "FADE OUT."
    }

    private static func isShot(_ line: String) -> Bool {
        let uppercaseLine = line.uppercased()
        return uppercaseLine.hasSuffix(":")
            && [
                "CLOSE ON:",
                "ANGLE ON:",
                "WIDE SHOT:",
                "INSERT:"
            ].contains(uppercaseLine)
    }

    private static func isUppercaseLike(_ line: String) -> Bool {
        let letters = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard !letters.isEmpty else {
            return false
        }
        return line == line.uppercased()
    }

    private static func sceneHeadingRanges(
        in text: String,
        scenes: [Scene]
    ) -> [(id: String, scene: Scene, range: EditorTextRange)] {
        let nsText = text as NSString
        var searchLocation = 0
        var results: [(id: String, scene: Scene, range: EditorTextRange)] = []

        for (index, scene) in scenes.enumerated() {
            guard searchLocation <= nsText.length else { break }
            let searchRange = NSRange(location: searchLocation, length: nsText.length - searchLocation)
            let foundRange = nsText.range(of: scene.heading, options: [], range: searchRange)
            guard foundRange.location != NSNotFound else { continue }

            let id = "scene-\(index + 1)"
            results.append((id, scene, EditorTextRange(location: foundRange.location, length: foundRange.length)))
            searchLocation = foundRange.location + foundRange.length
        }

        return results
    }

    private static func normalizedKey(for value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .uppercased()
    }
}
