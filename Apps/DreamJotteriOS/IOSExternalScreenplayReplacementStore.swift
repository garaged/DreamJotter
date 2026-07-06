public enum IOSExternalScreenplayReplacementStore {
    nonisolated(unsafe) private static var pendingText: String?

    public static func stage(_ text: String) {
        pendingText = text
    }

    public static func current() -> String? {
        pendingText
    }

    public static func consume() -> String? {
        defer { pendingText = nil }
        return pendingText
    }
}
