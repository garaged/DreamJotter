import DreamJotterCore
import DreamJotteriOS
import Foundation
import Testing

@Suite("iOS project document adapter")
struct IOSProjectDocumentAdapterTests {
    @Test("creates a canonical package that core can reopen")
    func createAndOpenRoundTrip() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("My Script.dreamjotter", isDirectory: true)
            let now = Date(timeIntervalSince1970: 1_700_000_000)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: .unrestricted,
                coordination: .direct
            )

            let created = try await adapter.createProject(title: "My Script", at: packageURL, now: now)
            let reopened = try await adapter.openProject(at: packageURL)
            let coreResult = DreamJotterPackageStore.load(from: packageURL)

            #expect(created.project.metadata.title == "My Script")
            #expect(reopened.project == created.project)
            #expect(coreResult.project == created.project)
            #expect(FileManager.default.fileExists(atPath: packageURL.appendingPathComponent("manifest.json").path))
            #expect(FileManager.default.fileExists(atPath: packageURL.appendingPathComponent("script.fountain").path))
        }
    }

    @Test("blank titles are normalized before package creation")
    func blankTitleBecomesUntitled() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("Untitled.dreamjotter", isDirectory: true)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: .unrestricted,
                coordination: .direct
            )

            let snapshot = try await adapter.createProject(title: "   ", at: packageURL)
            #expect(snapshot.project.metadata.title == "Untitled")
        }
    }

    @Test("save rejects an externally changed package")
    func externalChangeIsNotOverwritten() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("Conflict.dreamjotter", isDirectory: true)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: .unrestricted,
                coordination: .direct
            )

            let created = try await adapter.createProject(title: "Conflict", at: packageURL)
            try Data("external change".utf8).write(
                to: packageURL.appendingPathComponent("external-change.txt"),
                options: .atomic
            )

            await #expect(throws: IOSProjectDocumentError.externalModificationDetected) {
                _ = try await adapter.saveProject(
                    created.project,
                    at: packageURL,
                    expectedGeneration: created.generation
                )
            }

            #expect(FileManager.default.fileExists(atPath: packageURL.appendingPathComponent("external-change.txt").path))
        }
    }

    @Test("successful save returns a new generation and remains core-readable")
    func saveAdvancesGeneration() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("Save.dreamjotter", isDirectory: true)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: .unrestricted,
                coordination: .direct
            )

            let created = try await adapter.createProject(
                title: "Save",
                at: packageURL,
                now: Date(timeIntervalSince1970: 10)
            )
            let saved = try await adapter.saveProject(
                created.project,
                at: packageURL,
                expectedGeneration: created.generation,
                now: Date(timeIntervalSince1970: 20)
            )

            #expect(saved.generation != created.generation)
            #expect(DreamJotterPackageStore.load(from: packageURL).project == created.project)
        }
    }

    @Test("security-scope denial fails before reading")
    func deniedSecurityScopeFails() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("Denied.dreamjotter", isDirectory: true)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: IOSSecurityScopedAccess(
                    beginAccess: { _ in false },
                    endAccess: { _ in }
                ),
                coordination: .direct
            )

            await #expect(throws: IOSProjectDocumentError.securityScopedAccessDenied) {
                _ = try await adapter.openProject(at: packageURL)
            }
        }
    }

    @Test("invalid packages expose the core storage diagnostic")
    func invalidPackageReportsDiagnostic() async throws {
        try await withTemporaryDirectory { directory in
            let packageURL = directory.appendingPathComponent("Broken.dreamjotter", isDirectory: true)
            try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)
            let adapter = IOSProjectDocumentAdapter(
                securityScopedAccess: .unrestricted,
                coordination: .direct
            )

            do {
                _ = try await adapter.openProject(at: packageURL)
                Issue.record("Expected invalid package failure")
            } catch let error as IOSProjectDocumentError {
                #expect(error == .invalidPackage("The package manifest is missing."))
            }
        }
    }

    private func withTemporaryDirectory(
        _ operation: (URL) async throws -> Void
    ) async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DreamJotter-iOS-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try await operation(directory)
    }
}
