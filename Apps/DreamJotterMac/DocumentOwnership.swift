import Foundation

struct DocumentPackageIdentity: Hashable, Sendable {
    let canonicalURL: URL
    let observedFileResourceIdentifier: String?

    init(url: URL, fileManager: FileManager = .default) {
        let fileURL = url.isFileURL ? url : URL(fileURLWithPath: url.path, isDirectory: true)
        let canonicalURL = fileURL
            .standardizedFileURL
            .resolvingSymlinksInPath()
            .standardizedFileURL
        self.canonicalURL = canonicalURL

        if fileManager.fileExists(atPath: canonicalURL.path),
           let values = try? canonicalURL.resourceValues(forKeys: [.fileResourceIdentifierKey]),
           let identifier = values.fileResourceIdentifier {
            observedFileResourceIdentifier = String(describing: identifier)
        } else {
            observedFileResourceIdentifier = nil
        }
    }

    static func == (lhs: DocumentPackageIdentity, rhs: DocumentPackageIdentity) -> Bool {
        lhs.canonicalURL == rhs.canonicalURL
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(canonicalURL)
    }
}

enum DocumentOpenDecision<SessionID: Hashable & Sendable>: Equatable, Sendable {
    case openNew(DocumentPackageIdentity)
    case activateExisting(SessionID)
}

enum DocumentOwnershipClaim<SessionID: Hashable & Sendable>: Equatable, Sendable {
    case claimed
    case alreadyOwned(by: SessionID)
}

struct DocumentSessionRegistry<SessionID: Hashable & Sendable>: Sendable {
    private var ownersByIdentity: [DocumentPackageIdentity: SessionID] = [:]
    private var identitiesBySession: [SessionID: DocumentPackageIdentity] = [:]

    func decision(forOpening identity: DocumentPackageIdentity) -> DocumentOpenDecision<SessionID> {
        if let owner = ownersByIdentity[identity] {
            return .activateExisting(owner)
        }
        return .openNew(identity)
    }

    mutating func claim(
        _ identity: DocumentPackageIdentity,
        for sessionID: SessionID
    ) -> DocumentOwnershipClaim<SessionID> {
        if let owner = ownersByIdentity[identity] {
            return owner == sessionID ? .claimed : .alreadyOwned(by: owner)
        }

        if let previousIdentity = identitiesBySession[sessionID] {
            ownersByIdentity.removeValue(forKey: previousIdentity)
        }

        ownersByIdentity[identity] = sessionID
        identitiesBySession[sessionID] = identity
        return .claimed
    }

    mutating func release(sessionID: SessionID) {
        guard let identity = identitiesBySession.removeValue(forKey: sessionID) else { return }
        ownersByIdentity.removeValue(forKey: identity)
    }

    func identity(for sessionID: SessionID) -> DocumentPackageIdentity? {
        identitiesBySession[sessionID]
    }
}

struct RecentDocumentRepairResult: Equatable, Sendable {
    let available: [URL]
    let removed: [URL]
}

enum RecentDocumentRepair {
    static func repair(
        _ urls: [URL],
        fileManager: FileManager = .default
    ) -> RecentDocumentRepairResult {
        var seen: Set<DocumentPackageIdentity> = []
        var available: [URL] = []
        var removed: [URL] = []

        for url in urls {
            let identity = DocumentPackageIdentity(url: url, fileManager: fileManager)
            guard seen.insert(identity).inserted else { continue }

            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(atPath: identity.canonicalURL.path, isDirectory: &isDirectory)
            if exists, isDirectory.boolValue, identity.canonicalURL.pathExtension.lowercased() == "dreamjotter" {
                available.append(identity.canonicalURL)
            } else {
                removed.append(identity.canonicalURL)
            }
        }

        return RecentDocumentRepairResult(available: available, removed: removed)
    }
}

enum DocumentReopenDecision: Equatable, Sendable {
    case useRestoredWindows
    case openLastProject(URL)
    case showProjectLibrary
}

enum DocumentReopenPolicy {
    static func decision(
        restoredWindowCount: Int,
        lastProjectURL: URL?,
        lastProjectIsAvailable: Bool
    ) -> DocumentReopenDecision {
        if restoredWindowCount > 0 {
            return .useRestoredWindows
        }

        if let lastProjectURL, lastProjectIsAvailable {
            return .openLastProject(lastProjectURL.standardizedFileURL)
        }

        return .showProjectLibrary
    }
}
