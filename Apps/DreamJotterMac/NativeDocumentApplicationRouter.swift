import Foundation

struct NativeDocumentOpenBatch: Equatable, Sendable {
    let packageURLs: [URL]
    let rejectedURLs: [URL]
}

@MainActor
final class NativeDocumentApplicationRouter {
    static let shared = NativeDocumentApplicationRouter()

    private var pendingPackageURLs: [URL] = []
    private var pendingIdentities: Set<DocumentPackageIdentity> = []

    private init() {}

    @discardableResult
    func enqueue(_ urls: [URL]) -> NativeDocumentOpenBatch {
        var accepted: [URL] = []
        var rejected: [URL] = []

        for url in urls {
            let identity = DocumentPackageIdentity(url: url)
            guard identity.canonicalURL.pathExtension.lowercased() == "dreamjotter" else {
                rejected.append(identity.canonicalURL)
                continue
            }

            guard pendingIdentities.insert(identity).inserted else { continue }
            pendingPackageURLs.append(identity.canonicalURL)
            accepted.append(identity.canonicalURL)
        }

        if !accepted.isEmpty {
            NotificationCenter.default.post(name: .dreamJotterNativeOpenRequestsAvailable, object: nil)
        }

        return NativeDocumentOpenBatch(packageURLs: accepted, rejectedURLs: rejected)
    }

    func drainPendingPackageURLs() -> [URL] {
        let result = pendingPackageURLs
        pendingPackageURLs.removeAll(keepingCapacity: true)
        pendingIdentities.removeAll(keepingCapacity: true)
        return result
    }

    var hasPendingPackageURLs: Bool {
        !pendingPackageURLs.isEmpty
    }
}

extension Notification.Name {
    static let dreamJotterNativeOpenRequestsAvailable = Notification.Name(
        "DreamJotterNativeOpenRequestsAvailable"
    )
}
