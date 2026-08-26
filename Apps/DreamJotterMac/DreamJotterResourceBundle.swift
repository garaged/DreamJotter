import Foundation

enum DreamJotterResourceBundle {
    static let bundle: Bundle = {
        let resourceBundleName = "DreamJotter_DreamJotterMac"
        let searchRoots = [
            Bundle.main.bundleURL,
            Bundle.main.bundleURL.deletingLastPathComponent()
        ]

        for root in searchRoots {
            let candidate = root.appendingPathComponent(resourceBundleName).appendingPathExtension("bundle")
            if let bundle = Bundle(url: candidate) {
                return bundle
            }
        }

        return Bundle.main
    }()
}
