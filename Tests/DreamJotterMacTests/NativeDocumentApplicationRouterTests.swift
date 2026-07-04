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
        let uppercasePackageURL = URL(fileURLWithPath: "/tmp/Upper.DREAMJOTTER", isDirectory: true)
        let textURL = URL(fileURLWithPath: "/tmp/Notes.txt")

        let batch = router.enqueue([packageURL, uppercasePackageURL, textURL])

        #expect(batch.packageURLs == [
            DocumentPackageIdentity(url: packageURL).canonicalURL,
            DocumentPackageIdentity(url: uppercasePackageURL).canonicalURL
        ])
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

    @Test("Queued native opens are consumed in arrival order")
    func queuedRequestsDequeueInOrder() {
        let router = NativeDocumentApplicationRouter.shared
        _ = router.drainPendingPackageURLs()
        let first = URL(fileURLWithPath: "/tmp/First.dreamjotter", isDirectory: true)
        let second = URL(fileURLWithPath: "/tmp/Second.dreamjotter", isDirectory: true)

        router.enqueue([first, second])

        #expect(router.dequeuePendingPackageURL() == DocumentPackageIdentity(url: first).canonicalURL)
        #expect(router.hasPendingPackageURLs)
        #expect(router.dequeuePendingPackageURL() == DocumentPackageIdentity(url: second).canonicalURL)
        #expect(router.dequeuePendingPackageURL() == nil)
        #expect(!router.hasPendingPackageURLs)
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
