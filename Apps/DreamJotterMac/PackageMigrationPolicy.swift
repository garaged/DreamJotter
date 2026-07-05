import Foundation

struct SemanticVersion: Comparable, Equatable, Sendable {
    let major: Int
    let minor: Int
    let patch: Int

    init?(_ value: String) {
        let components = value.split(separator: ".", omittingEmptySubsequences: false)
        guard components.count == 3,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components[2]),
              major >= 0, minor >= 0, patch >= 0 else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }
}

enum PackageCompatibilityDecision: Equatable, Sendable {
    case openNormally
    case migrateFrom(SemanticVersion)
    case openCompatibilityReadOnly
    case rejectUnsupportedFutureMajor
    case rejectInvalidVersion
}

enum PackageMigrationPolicy {
    static let currentFormat = SemanticVersion("1.0.0")!
    static let oldestSupportedFormat = SemanticVersion("0.1.0")!

    static func decision(for formatVersion: String) -> PackageCompatibilityDecision {
        guard let version = SemanticVersion(formatVersion) else {
            return .rejectInvalidVersion
        }
        if version.major > currentFormat.major {
            return .rejectUnsupportedFutureMajor
        }
        if version.major == currentFormat.major, version > currentFormat {
            return .openCompatibilityReadOnly
        }
        if version < oldestSupportedFormat {
            return .rejectInvalidVersion
        }
        if version < currentFormat {
            return .migrateFrom(version)
        }
        return .openNormally
    }

    static func requiresBackupBeforeWrite(_ decision: PackageCompatibilityDecision) -> Bool {
        if case .migrateFrom = decision { return true }
        return false
    }

    static func permitsSourceMutation(_ decision: PackageCompatibilityDecision) -> Bool {
        switch decision {
        case .openNormally:
            return true
        case .migrateFrom:
            return false
        case .openCompatibilityReadOnly, .rejectUnsupportedFutureMajor, .rejectInvalidVersion:
            return false
        }
    }
}
