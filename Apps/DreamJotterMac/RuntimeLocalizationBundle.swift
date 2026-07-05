import Foundation
import ObjectiveC.runtime

private final class DreamJotterLanguageBundle: Bundle, @unchecked Sendable {
    nonisolated(unsafe) static var activeLocalizationBundle: Bundle?

    override func localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        guard let activeLocalizationBundle = Self.activeLocalizationBundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        let correction = activeLocalizationBundle.localizedString(
            forKey: key,
            value: key,
            table: "SpanishCorrections"
        )

        if correction != key {
            return correction
        }

        return activeLocalizationBundle.localizedString(
            forKey: key,
            value: value,
            table: tableName
        )
    }
}

enum RuntimeLocalizationBundle {
    static func apply(localeIdentifiers: [String]?) {
        DreamJotterLanguageBundle.activeLocalizationBundle = localeIdentifiers.flatMap(findBundle)

        if object_getClass(Bundle.main) != DreamJotterLanguageBundle.self {
            object_setClass(Bundle.main, DreamJotterLanguageBundle.self)
        }
    }

    static func findBundle(localeIdentifiers: [String]) -> Bundle? {
        let parents = candidateResourceBundles()
        let available = availableLocalizations(in: parents)

        for identifier in localizationCandidates(
            for: localeIdentifiers,
            availableLocalizations: available
        ) {
            for parent in parents {
                if let bundle = bundle(in: parent, identifier: identifier) {
                    return bundle
                }
            }
        }

        return nil
    }

    private static func candidateResourceBundles() -> [Bundle] {
        var bundles: [Bundle] = [
            DreamJotterResourceBundle.bundle,
            Bundle(for: DreamJotterLanguageBundle.self),
            Bundle.main
        ]
        bundles.append(contentsOf: Bundle.allBundles)
        bundles.append(contentsOf: Bundle.allFrameworks)

        let sourceResourcesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources", isDirectory: true)
        if let sourceResourcesBundle = Bundle(url: sourceResourcesURL) {
            bundles.append(sourceResourcesBundle)
        }

        var unique: [Bundle] = []
        var seenURLs = Set<URL>()
        for bundle in bundles {
            let url = bundle.bundleURL.standardizedFileURL
            if seenURLs.insert(url).inserted {
                unique.append(bundle)
            }
        }

        return unique
    }

    private static func availableLocalizations(in bundles: [Bundle]) -> [String] {
        var result: [String] = []
        var seen = Set<String>()

        for bundle in bundles {
            for localization in bundle.localizations {
                let canonical = canonicalIdentifier(localization)
                if seen.insert(canonical).inserted {
                    result.append(canonical)
                }
            }
        }

        return result
    }

    private static func localizationCandidates(
        for requested: [String],
        availableLocalizations: [String]
    ) -> [String] {
        var result: [String] = []
        var seen = Set<String>()
        let supportedLanguages: Set<String> = ["en", "es"]

        func append(_ identifier: String) {
            let canonical = canonicalIdentifier(identifier)
            guard !canonical.isEmpty, seen.insert(canonical).inserted else {
                return
            }
            result.append(canonical)
        }

        for identifier in requested {
            let canonical = canonicalIdentifier(identifier)
            let language = Locale(identifier: canonical).language.languageCode?.identifier
                ?? canonical.split(separator: "-").first.map(String.init)

            guard let language, supportedLanguages.contains(language) else {
                continue
            }

            append(canonical)
            append(language)

            if language == "es" {
                append("es-419")
                append("es-MX")
            }
        }

        let supportedAvailable = availableLocalizations.filter { localization in
            let language = Locale(identifier: localization).language.languageCode?.identifier
                ?? localization.split(separator: "-").first.map(String.init)
            return language.map(supportedLanguages.contains) ?? false
        }
        let supportedRequested = requested.filter { identifier in
            let canonical = canonicalIdentifier(identifier)
            let language = Locale(identifier: canonical).language.languageCode?.identifier
                ?? canonical.split(separator: "-").first.map(String.init)
            return language.map(supportedLanguages.contains) ?? false
        }
        let preferred = Bundle.preferredLocalizations(
            from: supportedAvailable,
            forPreferences: supportedRequested
        )
        preferred.forEach(append)

        if let developmentRegion = DreamJotterResourceBundle.bundle.developmentLocalization {
            append(developmentRegion)
        }
        append("en")
        append("Base")

        return result
    }

    private static func canonicalIdentifier(_ identifier: String) -> String {
        guard identifier != "Base" else {
            return identifier
        }
        return Locale(identifier: identifier)
            .identifier
            .replacingOccurrences(of: "_", with: "-")
    }

    private static func bundle(in parent: Bundle, identifier: String) -> Bundle? {
        let canonical = canonicalIdentifier(identifier)
        let variants = [
            canonical,
            canonical.replacingOccurrences(of: "-", with: "_"),
            identifier
        ]

        for variant in variants {
            guard let path = parent.path(forResource: variant, ofType: "lproj") else {
                continue
            }
            if let bundle = Bundle(path: path) {
                return bundle
            }
        }

        return nil
    }
}
