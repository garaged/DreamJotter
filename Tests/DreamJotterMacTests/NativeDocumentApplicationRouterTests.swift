import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M14 Native Document Application Router", .serialized)
@MainActor
struct NativeDocumentApplicationRouterTests {
    @Test("Native open routing accepts DreamJotter packages and rejects unrelated files")
    func acceptsPackagesAndRejectsOtherFiles() {
        let router = NativeDocumentApplicationRouter.shared
        _ = router.drainPendingPackageURLs()
        let packageURL = URL(fileURLWithPath: "/tmp/Native.dreamjotter", isDirectory: true)
        let textURL = URL(fileURLWithPath: "/tmp/Notes.txt")

        let batch = router.enqueue([packageURL, textURL])

        #expect(batch.packageURLs == [DocumentPackageIdentity(url: packageURL).canonicalURL])
        #expect(batch.rejectedURLs == [DocumentPackageIdentity(url: textURL).canonicalURL])
        #expect(router.hasPendingPackageURLs)
        #expect(router.drainPendingPackageURLs() == batch.packageURLs)
        #expect(!router.hasPendingPackageURLs)
    }

    @Test("Equivalent package requests are queued only once until drained")
    func equivalentRequestsDeduplicateUntilDrain() {
        let router = NativeDocumentApplicationRouter.shared
        _ = router.drainPendingPackageURLs()
        let packageURL = URL(fileURLWithPath: "/tmp/Duplicate.dreamjotter", isDirectory: true)

        let first = router.enqueue([packageURL, packageURL.standardizedFileURL])
        let second = router.enqueue([packageURL])

        #expect(first.packageURLs.count == 1)
        #expect(second.packageURLs.isEmpty)
        #expect(router.drainPendingPackageURLs().count == 1)

        let afterDrain = router.enqueue([packageURL])
        #expect(afterDrain.packageURLs.count == 1)
        _ = router.drainPendingPackageURLs()
    }

    @Test("Recent document registration records canonical package URLs")
    func recentRegistrationUsesCanonicalURLs() {
        let memory = NativeRecentDocumentRegistrar.memory()
        let packageURL = URL(
            fileURLWithPath: "/tmp/Folder/../Recent.dreamjotter",
            isDirectory: true
        )

        memory.registrar.note(packageURL)

        #expect(memory.recorded() == [DocumentPackageIdentity(url: packageURL).canonicalURL])

        memory.registrar.clear()
        #expect(memory.recorded().isEmpty)
    }
}
