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

    private static func findBundle(localeIdentifiers: [String]) -> Bundle? {
        for identifier in localeIdentifiers {
            if let bundle = bundle(in: Bundle.main, identifier: identifier) {
                return bundle
            }

            if let bundle = bundle(in: Bundle.module, identifier: identifier) {
                return bundle
            }
        }

        return nil
    }

    private static func bundle(in parent: Bundle, identifier: String) -> Bundle? {
        guard let path = parent.path(forResource: identifier, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }
}
