import DreamJotterCore
import Foundation

struct PackageGenerationFingerprint: Equatable, Sendable {
    let canonicalURL: URL
    let fileResourceIdentifier: String?
    let manifestDigest: UInt64
    let projectDigest: UInt64
    let screenplayDigest: UInt64

    static func read(
        from packageURL: URL,
        fileManager: FileManager = .default
    ) throws -> PackageGenerationFingerprint {
        let identity = DocumentPackageIdentity(url: packageURL, fileManager: fileManager)
        return PackageGenerationFingerprint(
            canonicalURL: identity.canonicalURL,
            fileResourceIdentifier: identity.observedFileResourceIdentifier,
            manifestDigest: try digest(of: identity.canonicalURL.appendingPathComponent("manifest.json")),
            projectDigest: try digest(of: identity.canonicalURL.appendingPathComponent("project.json")),
            screenplayDigest: try digest(of: identity.canonicalURL.appendingPathComponent("screenplay.json"))
        )
    }

    private static func digest(of url: URL) throws -> UInt64 {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return hash
    }
}

enum PackageGenerationDecision: Equatable, Sendable {
    case unchanged
    case externallyChanged
    case unavailable
}

enum PackageGenerationPolicy {
    static func decision(
        expected: PackageGenerationFingerprint?,
        observed: PackageGenerationFingerprint?
    ) -> PackageGenerationDecision {
        guard let expected else { return observed == nil ? .unavailable : .unchanged }
        guard let observed else { return .unavailable }
        return expected == observed ? .unchanged : .externallyChanged
    }
}

struct AutosaveContext: Equatable, Sendable {
    var hasPackageIdentity: Bool
    var ownsPackageIdentity: Bool
    var isDirty: Bool
    var isOperationActive: Bool
    var hasExternalConflict: Bool
    var destinationReachable: Bool
    var destinationWritable: Bool
}

enum AutosaveDecision: Equatable, Sendable {
    case save
    case skipUnsavedDocument
    case skipNotOwner
    case skipClean
    case deferOperationActive
    case blockExternalConflict
    case deferUnavailableDestination
}

enum AutosavePolicy {
    static func decision(for context: AutosaveContext) -> AutosaveDecision {
        guard context.hasPackageIdentity else { return .skipUnsavedDocument }
        guard context.ownsPackageIdentity else { return .skipNotOwner }
        guard context.isDirty else { return .skipClean }
        guard !context.isOperationActive else { return .deferOperationActive }
        guard !context.hasExternalConflict else { return .blockExternalConflict }
        guard context.destinationReachable, context.destinationWritable else {
            return .deferUnavailableDestination
        }
        return .save
    }
}

enum GuardedPackageSave {
    static func perform(
        at packageURL: URL,
        fileManager: FileManager = .default,
        operation: () throws -> Void
    ) throws {
        let canonicalURL = DocumentPackageIdentity(url: packageURL, fileManager: fileManager).canonicalURL
        let parent = canonicalURL.deletingLastPathComponent()
        let backupURL = parent.appendingPathComponent(
            ".\(canonicalURL.lastPathComponent).backup-\(UUID().uuidString)",
            isDirectory: true
        )
        let existed = fileManager.fileExists(atPath: canonicalURL.path)

        if existed {
            try fileManager.copyItem(at: canonicalURL, to: backupURL)
        }

        do {
            try operation()
            if existed {
                try? fileManager.removeItem(at: backupURL)
            }
        } catch {
            if existed {
                try? fileManager.removeItem(at: canonicalURL)
                try? fileManager.moveItem(at: backupURL, to: canonicalURL)
            } else {
                try? fileManager.removeItem(at: canonicalURL)
            }
            throw error
        }
    }
}

struct DocumentRestorationRecord: Codable, Equatable, Sendable {
    let packagePath: String

    var packageURL: URL {
        URL(fileURLWithPath: packagePath, isDirectory: true)
    }

    init(packageURL: URL) {
        packagePath = DocumentPackageIdentity(url: packageURL).canonicalURL.path
    }
}

struct DocumentRestorationStore {
    var load: () -> [DocumentRestorationRecord]
    var save: ([DocumentRestorationRecord]) -> Void

    static func userDefaults(
        defaults: UserDefaults = .standard,
        key: String = "DreamJotterRestoredDocuments"
    ) -> DocumentRestorationStore {
        DocumentRestorationStore(
            load: {
                guard let data = defaults.data(forKey: key) else { return [] }
                defaults.removeObject(forKey: key)
                return (try? JSONDecoder().decode([DocumentRestorationRecord].self, from: data)) ?? []
            },
            save: { records in
                if records.isEmpty {
                    defaults.removeObject(forKey: key)
                } else {
                    defaults.set(try? JSONEncoder().encode(records), forKey: key)
                }
            }
        )
    }

    static func memory(initialRecords: [DocumentRestorationRecord] = []) -> DocumentRestorationStore {
        final class Storage: @unchecked Sendable {
            var records: [DocumentRestorationRecord]
            init(records: [DocumentRestorationRecord]) { self.records = records }
        }
        let storage = Storage(records: initialRecords)
        return DocumentRestorationStore(
            load: {
                let records = storage.records
                storage.records = []
                return records
            },
            save: { storage.records = $0 }
        )
    }
}

enum DocumentRestorationPolicy {
    static func restorableURLs(
        from records: [DocumentRestorationRecord],
        fileManager: FileManager = .default
    ) -> [URL] {
        RecentDocumentRepair.repair(records.map(\.packageURL), fileManager: fileManager).available
    }
}
