import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M14 Document Persistence Policies")
struct DocumentPersistencePolicyTests {
    @Test("Generation fingerprint changes when canonical package content changes")
    func fingerprintDetectsExternalChange() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("DreamJotterGeneration-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try Data("manifest-a".utf8).write(to: root.appendingPathComponent("manifest.json"))
        try Data("project-a".utf8).write(to: root.appendingPathComponent("project.json"))
        try Data("screenplay-a".utf8).write(to: root.appendingPathComponent("screenplay.json"))

        let expected = try PackageGenerationFingerprint.read(from: root)
        try Data("screenplay-b".utf8).write(to: root.appendingPathComponent("screenplay.json"))
        let observed = try PackageGenerationFingerprint.read(from: root)

        #expect(PackageGenerationPolicy.decision(expected: expected, observed: observed) == .externallyChanged)
        #expect(PackageGenerationPolicy.decision(expected: observed, observed: observed) == .unchanged)
        #expect(PackageGenerationPolicy.decision(expected: observed, observed: nil) == .unavailable)
    }

    @Test("Autosave only runs for a dirty owned reachable conflict-free package")
    func autosaveEligibilityMatrix() {
        let eligible = AutosaveContext(
            hasPackageIdentity: true,
            ownsPackageIdentity: true,
            isDirty: true,
            isOperationActive: false,
            hasExternalConflict: false,
            destinationReachable: true,
            destinationWritable: true
        )
        #expect(AutosavePolicy.decision(for: eligible) == .save)

        var context = eligible
        context.hasPackageIdentity = false
        #expect(AutosavePolicy.decision(for: context) == .skipUnsavedDocument)
        context = eligible
        context.ownsPackageIdentity = false
        #expect(AutosavePolicy.decision(for: context) == .skipNotOwner)
        context = eligible
        context.isDirty = false
        #expect(AutosavePolicy.decision(for: context) == .skipClean)
        context = eligible
        context.isOperationActive = true
        #expect(AutosavePolicy.decision(for: context) == .deferOperationActive)
        context = eligible
        context.hasExternalConflict = true
        #expect(AutosavePolicy.decision(for: context) == .blockExternalConflict)
        context = eligible
        context.destinationWritable = false
        #expect(AutosavePolicy.decision(for: context) == .deferUnavailableDestination)
    }

    @Test("Restoration skips missing packages and deduplicates equivalent records")
    func restorationRepairsRecords() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("DreamJotterRestoration-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let existing = root.appendingPathComponent("Existing.dreamjotter", isDirectory: true)
        let missing = root.appendingPathComponent("Missing.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: existing, withIntermediateDirectories: true)

        let records = [
            DocumentRestorationRecord(packageURL: missing),
            DocumentRestorationRecord(packageURL: existing),
            DocumentRestorationRecord(packageURL: existing.standardizedFileURL)
        ]

        #expect(DocumentRestorationPolicy.restorableURLs(from: records) == [
            DocumentPackageIdentity(url: existing).canonicalURL
        ])
    }
}
