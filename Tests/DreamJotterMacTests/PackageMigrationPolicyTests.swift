import Testing
@testable import DreamJotterMac

@Suite("M15 Package Migration Policy")
struct PackageMigrationPolicyTests {
    @Test("Current format opens normally")
    func currentFormat() {
        #expect(PackageMigrationPolicy.decision(for: "1.0.0") == .openNormally)
    }

    @Test("Historical supported formats require migration and backup")
    func historicalFormats() {
        let decision = PackageMigrationPolicy.decision(for: "0.1.0")
        #expect(decision == .migrateFrom(SemanticVersion("0.1.0")!))
        #expect(PackageMigrationPolicy.requiresBackupBeforeWrite(decision))
        #expect(!PackageMigrationPolicy.permitsSourceMutation(decision))
    }

    @Test("Newer minor format opens read-only")
    func newerMinor() {
        let decision = PackageMigrationPolicy.decision(for: "1.1.0")
        #expect(decision == .openCompatibilityReadOnly)
        #expect(!PackageMigrationPolicy.permitsSourceMutation(decision))
    }

    @Test("Future major format is rejected without mutation")
    func futureMajor() {
        let decision = PackageMigrationPolicy.decision(for: "2.0.0")
        #expect(decision == .rejectUnsupportedFutureMajor)
        #expect(!PackageMigrationPolicy.permitsSourceMutation(decision))
    }

    @Test("Malformed and obsolete versions are rejected")
    func invalidVersions() {
        #expect(PackageMigrationPolicy.decision(for: "not-a-version") == .rejectInvalidVersion)
        #expect(PackageMigrationPolicy.decision(for: "0.0.9") == .rejectInvalidVersion)
    }
}
