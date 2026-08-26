import Foundation

public enum IOSProductConfiguration {
    public static let bundleIdentifier = "org.garaged.DreamJotter"
    public static let iCloudContainerIdentifier = "iCloud.org.garaged.DreamJotter"
    public static let documentTypeIdentifier = "org.garaged.dreamjotter.project"
    public static let documentFilenameExtension = "dreamjotter"
    public static let minimumOSMajorVersion = 26
    public static let minimumOSVersion = "26.0"
    public static let performanceBaselineDevice = "iPhone 14 Plus"

    /// App Store archives must be signed, but the repository must not hard-code
    /// a personal or organization development-team identifier. Xcode resolves the
    /// selected Apple Developer team through automatic signing at archive time.
    public static let usesAutomaticSigning = true
    public static let commitsDevelopmentTeamIdentifier = false

    public static let supportsOpenInPlaceDocuments = true
    public static let supportsLocalFiles = true
    public static let supportsICloudDocuments = true
}
