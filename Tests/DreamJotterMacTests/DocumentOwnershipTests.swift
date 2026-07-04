import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M14 Document Ownership")
struct DocumentOwnershipTests {
    @Test("Equivalent standardized package URLs share one identity")
    func equivalentPathsShareIdentity() throws {
        let root = temporaryDirectory(named: "DreamJotterIdentity")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let packageURL = root.appendingPathComponent("Draft.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)

        let equivalentURL = root
            .appendingPathComponent("Folder", isDirectory: true)
            .appendingPathComponent("..", isDirectory: true)
            .appendingPathComponent("Draft.dreamjotter", isDirectory: true)

        #expect(DocumentPackageIdentity(url: packageURL) == DocumentPackageIdentity(url: equivalentURL))
    }

    @Test("Symlinked package URLs resolve to the same identity")
    func symlinkSharesIdentity() throws {
        let root = temporaryDirectory(named: "DreamJotterIdentitySymlink")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let packageURL = root.appendingPathComponent("Draft.dreamjotter", isDirectory: true)
        let linkURL = root.appendingPathComponent("Alias.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: packageURL)

        #expect(DocumentPackageIdentity(url: packageURL) == DocumentPackageIdentity(url: linkURL))
    }

    @Test("A duplicate open request activates the existing owner")
    func duplicateOpenActivatesExistingOwner() {
        let packageURL = URL(fileURLWithPath: "/tmp/Draft.dreamjotter", isDirectory: true)
        let identity = DocumentPackageIdentity(url: packageURL)
        var registry = DocumentSessionRegistry<String>()

        #expect(registry.decision(forOpening: identity) == .openNew(identity))
        #expect(registry.claim(identity, for: "window-1") == .claimed)
        #expect(registry.decision(forOpening: identity) == .activateExisting("window-1"))
        #expect(registry.claim(identity, for: "window-2") == .alreadyOwned(by: "window-1"))
    }

    @Test("Releasing a session makes the package available again")
    func releaseMakesPackageAvailable() {
        let identity = DocumentPackageIdentity(
            url: URL(fileURLWithPath: "/tmp/Draft.dreamjotter", isDirectory: true)
        )
        var registry = DocumentSessionRegistry<String>()
        _ = registry.claim(identity, for: "window-1")

        registry.release(sessionID: "window-1")

        #expect(registry.decision(forOpening: identity) == .openNew(identity))
    }

    @Test("Recent repair retains valid packages and reports missing entries")
    func recentRepairSeparatesMissingEntries() throws {
        let root = temporaryDirectory(named: "DreamJotterRecentRepair")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let existing = root.appendingPathComponent("Existing.dreamjotter", isDirectory: true)
        let missing = root.appendingPathComponent("Missing.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: existing, withIntermediateDirectories: true)

        let result = RecentDocumentRepair.repair([missing, existing, existing.standardizedFileURL])

        #expect(result.available == [existing.standardizedFileURL])
        #expect(result.removed == [missing.standardizedFileURL])
    }

    private func temporaryDirectory(named name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name)-\(UUID().uuidString)", isDirectory: true)
    }
}
