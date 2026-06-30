import Foundation

public struct SceneListItem: Equatable, Sendable {
    public let index: Int
    public let heading: String
    public let displayTitle: String
    public let location: String
    public let timeOfDay: String?

    public init(index: Int, heading: String, displayTitle: String, location: String, timeOfDay: String?) {
        self.index = index
        self.heading = heading
        self.displayTitle = displayTitle
        self.location = location
        self.timeOfDay = timeOfDay
    }
}

public struct AutocompleteSuggestion: Equatable, Sendable {
    public let displayText: String
    public let normalizedKey: String
    public let sourceCount: Int

    public init(displayText: String, normalizedKey: String, sourceCount: Int) {
        self.displayText = displayText
        self.normalizedKey = normalizedKey
        self.sourceCount = sourceCount
    }
}

public enum ScreenplayDerivedData {
    public static func sceneList(from document: ScreenplayDocument) -> [SceneListItem] {
        document.scenes.enumerated().map { index, scene in
            SceneListItem(
                index: index,
                heading: scene.heading,
                displayTitle: scene.heading,
                location: scene.location,
                timeOfDay: scene.timeOfDay
            )
        }
    }

    public static func characterSuggestions(from document: ScreenplayDocument) -> [AutocompleteSuggestion] {
        collapsedSuggestions(from: document.characters)
    }

    public static func locationSuggestions(from document: ScreenplayDocument) -> [AutocompleteSuggestion] {
        collapsedSuggestions(from: document.scenes.map(\.location))
    }

    private static func collapsedSuggestions(from values: [String]) -> [AutocompleteSuggestion] {
        var orderedKeys: [String] = []
        var buckets: [String: (displayText: String, count: Int)] = [:]

        for value in values {
            let displayText = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !displayText.isEmpty else {
                continue
            }

            let key = normalizedKey(for: displayText)
            if let existing = buckets[key] {
                buckets[key] = (existing.displayText, existing.count + 1)
            } else {
                orderedKeys.append(key)
                buckets[key] = (displayText, 1)
            }
        }

        return orderedKeys.compactMap { key in
            guard let bucket = buckets[key] else {
                return nil
            }
            return AutocompleteSuggestion(
                displayText: bucket.displayText,
                normalizedKey: key,
                sourceCount: bucket.count
            )
        }
    }

    private static func normalizedKey(for value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .uppercased()
    }
}
