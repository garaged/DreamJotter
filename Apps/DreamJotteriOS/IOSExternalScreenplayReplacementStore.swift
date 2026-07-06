@MainActor
public enum IOSExternalScreenplayReplacementStore {
    public private(set) static var pendingText: String?

    public static func stage(_ text: String) {
        pendingText = text
    }
}
