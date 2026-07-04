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

    /// Resolves a localization without touching `Bundle.module`.
    ///
    /// SwiftPM's generated `Bundle.module` accessor traps when its generated
    /// resource bundle cannot be found. That is appropriate for a normal
    /// SwiftPM layout, but a packaged standalone app may copy localized
    /// resources into `Bundle.main` and may not retain the generated bundle in
    /// the location expected by that accessor. Discovering bundles from the
    /// filesystem keeps localization fallback non-fatal in both layouts.
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
        var bundles = [Bundle.main]
        var seenURLs = Set<URL>()
        seenURLs.insert(Bundle.main.bundleURL.standardizedFileURL)

        func appendBundle(at url: URL) {
            let standardizedURL = url.standardizedFileURL
            guard seenURLs.insert(standardizedURL).inserted,
                  let bundle = Bundle(url: standardizedURL) else {
                return
            }
            bundles.append(bundle)
        }

        let fileManager = FileManager.default
        let searchRoots = [
            Bundle.main.resourceURL,
            Bundle.main.executableURL?.deletingLastPathComponent()
        ].compactMap { $0 }

        for root in searchRoots {
            guard let children = try? fileManager.contentsOfDirectory(
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

        for bundle in Bundle.allBundles {
            let url = bundle.bundleURL.standardizedFileURL
            let name = url.deletingPathExtension().lastPathComponent.lowercased()
            guard url.pathExtension == "bundle", name.contains("dreamjotter") else {
                continue
            }
            appendBundle(at: url)
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

                // DreamJotter currently ships regional Spanish resources rather
                // than a generic es.lproj. Keep the fallback explicit and stable.
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

        if let developmentRegion = Bundle.main.developmentLocalization {
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
        return Locale.canonicalIdentifier(from: identifier)
            .replacingOccurrences(of: "_", with: "-")
    }

    private static func bundle(in parent: Bundle, identifier: String) -> Bundle? {
        let variants = [
            identifier,
            identifier.replacingOccurrences(of: "-", with: "_"),
            Locale.canonicalIdentifier(from: identifier)
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
