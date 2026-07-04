import Foundation
import Testing
@testable import DreamJotterMac

@Suite("Runtime localization bundle")
struct RuntimeLocalizationBundleTests {
    @Test("Resolves an exact regional localization")
    func resolvesExactRegionalLocalization() throws {
        let bundle = try #require(
            RuntimeLocalizationBundle.findBundle(localeIdentifiers: ["es-MX"])
        )

        #expect(
            ["es-MX.lproj", "es.lproj"]
                .contains(bundle.bundleURL.lastPathComponent)
        )
    }

    @Test("Resolves generic Spanish to a shipped regional localization")
    func resolvesGenericSpanish() throws {
        let bundle = try #require(
            RuntimeLocalizationBundle.findBundle(localeIdentifiers: ["es"])
        )

        #expect(
            ["es-419.lproj", "es-MX.lproj", "es.lproj"]
                .contains(bundle.bundleURL.lastPathComponent)
        )
    }

    @Test("Falls back to the concrete development localization")
    func fallsBackToDevelopmentLocalization() throws {
        let bundle = try #require(
            RuntimeLocalizationBundle.findBundle(localeIdentifiers: ["fr-CA"])
        )

        #expect(bundle.bundleURL.lastPathComponent == "en.lproj")
    }

    @Test("Locale spelling variants do not cause a fatal lookup")
    func acceptsLocaleSpellingVariants() throws {
        let bundle = try #require(
            RuntimeLocalizationBundle.findBundle(localeIdentifiers: ["es_MX"])
        )

        #expect(
            ["es-MX.lproj", "es.lproj"]
                .contains(bundle.bundleURL.lastPathComponent)
        )
    }
}
