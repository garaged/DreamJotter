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
        var bundles = [DreamJotterResourceBundle.bundle, Bundle.main]
        var seenURLs = Set(
            bundles.map { $0.bundleURL.standardizedFileURL }
        )

        func appendBundle(at url: URL) {
            let standardizedURL = url.standardizedFileURL
            guard seenURLs.insert(standardizedURL).inserted,
                  let bundle = Bundle(url: standardizedURL) else {
                return
            }
            bundles.append(bundle)
        }

        let searchRoots = [
            Bundle.main.resourceURL,
            Bundle.main.executableURL?.deletingLastPathComponent()
        ].compactMap { $0 }

        for root in searchRoots {
            guard let children = try? FileManager.default.contentsOfDirectory(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for child in children where child.pathExtension == "bundle" {
                appendBundle(at: child)
            }
        }

        return bundles
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

        func append(_ identifier: String) {
            let canonical = canonicalIdentifier(identifier)
            guard !canonical.isEmpty, seen.insert(canonical).inserted else {
                return
            }
            result.append(canonical)
        }

        for identifier in requested {
            let canonical = canonicalIdentifier(identifier)
            append(canonical)

            let language = Locale(identifier: canonical).language.languageCode?.identifier
                ?? canonical.split(separator: "-").first.map(String.init)

            if let language {
                append(language)

                if language == "es" {
                    append("es-419")
                    append("es-MX")
                }
            }
        }

        let preferred = Bundle.preferredLocalizations(
            from: availableLocalizations,
            forPreferences: requested
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
