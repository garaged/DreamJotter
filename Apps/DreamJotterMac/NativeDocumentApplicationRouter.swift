import AppKit
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

    func dequeuePendingPackageURL() -> URL? {
        guard !pendingPackageURLs.isEmpty else { return nil }
        let url = pendingPackageURLs.removeFirst()
        pendingIdentities.remove(DocumentPackageIdentity(url: url))
        return url
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

@MainActor
struct NativeRecentDocumentRegistrar {
    var note: (URL) -> Void
    var clear: () -> Void

    static let application = NativeRecentDocumentRegistrar(
        note: { url in
            NSDocumentController.shared.noteNewRecentDocumentURL(
                DocumentPackageIdentity(url: url).canonicalURL
            )
        },
        clear: {
            NSDocumentController.shared.clearRecentDocuments(nil)
        }
    )

    static func memory() -> (
        registrar: NativeRecentDocumentRegistrar,
        recorded: () -> [URL]
    ) {
        @MainActor
        final class Storage {
            var urls: [URL] = []
        }

        let storage = Storage()
        return (
            NativeRecentDocumentRegistrar(
                note: { url in
                    storage.urls.append(DocumentPackageIdentity(url: url).canonicalURL)
                },
                clear: { storage.urls.removeAll() }
            ),
            { storage.urls }
        )
    }
}

extension Notification.Name {
    static let dreamJotterNativeOpenRequestsAvailable = Notification.Name(
        "DreamJotterNativeOpenRequestsAvailable"
    )
}
