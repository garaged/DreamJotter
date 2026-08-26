import DreamJotteriOS
import Testing

@Suite("iOS product configuration")
struct IOSProductConfigurationTests {
    @Test("bundle and iCloud identifiers use reverse-DNS naming")
    func identifiersAreStable() {
        #expect(IOSProductConfiguration.bundleIdentifier == "org.garaged.DreamJotter")
        #expect(IOSProductConfiguration.iCloudContainerIdentifier == "iCloud.org.garaged.DreamJotter")
        #expect(IOSProductConfiguration.documentTypeIdentifier == "org.garaged.dreamjotter.project")
    }

    @Test("distribution configuration does not commit a personal team")
    func signingIsAutomaticButTeamIsExternal() {
        #expect(IOSProductConfiguration.usesAutomaticSigning)
        #expect(!IOSProductConfiguration.commitsDevelopmentTeamIdentifier)
    }

    @Test("Files and iCloud document storage are both required")
    func storageSurfacesAreEnabled() {
        #expect(IOSProductConfiguration.supportsOpenInPlaceDocuments)
        #expect(IOSProductConfiguration.supportsLocalFiles)
        #expect(IOSProductConfiguration.supportsICloudDocuments)
    }

    @Test("release and performance baselines are explicit")
    func baselinesAreExplicit() {
        #expect(IOSProductConfiguration.minimumOSVersion == "26.0")
        #expect(IOSProductConfiguration.performanceBaselineDevice == "iPhone 14 Plus")
    }
}
