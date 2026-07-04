import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M15 Release Support")
struct ReleaseSupportTests {
    @Test("Diagnostics never include screenplay content")
    func diagnosticsArePrivacyFiltered() throws {
        let diagnostics = SupportDiagnosticsBuilder.make(
            release: ReleaseIdentity(version: "1.0.0", build: "42"),
            packageURL: URL(fileURLWithPath: "/tmp/Project.dreamjotter"),
            recentErrorSummary: "Unable to open package\nDetailed failure",
            locale: Locale(identifier: "es_MX"),
            generatedAt: Date(timeIntervalSince1970: 0)
        )

        #expect(diagnostics.appVersion == "1.0.0")
        #expect(diagnostics.appBuild == "42")
        #expect(diagnostics.packageStatus == "saved-project-open")
        #expect(diagnostics.recentErrorSummary == "Unable to open package Detailed failure")
        #expect(diagnostics.includesScreenplayContent == false)

        let encoded = try SupportDiagnosticsBuilder.encode(diagnostics)
        let text = try #require(String(data: encoded, encoding: .utf8))
        #expect(!text.contains("screenplayText"))
        #expect(text.contains("\"includesScreenplayContent\" : false"))
    }

    @Test("Diagnostics truncate unbounded error details")
    func diagnosticsTruncateErrorDetails() {
        let diagnostics = SupportDiagnosticsBuilder.make(
            packageURL: nil,
            recentErrorSummary: String(repeating: "x", count: 1_000)
        )
        #expect(diagnostics.recentErrorSummary?.count == 500)
    }

    @Test("Recovery actions are non-destructive and context aware")
    func recoveryPolicy() {
        let complete = PackageRecoveryPolicy.actions(for: PackageRecoveryContext(
            packageExists: true,
            backupAvailable: true,
            packageCanBeRevealed: true
        ))
        #expect(complete == [.exportDiagnostics, .chooseBackup, .revealPackage, .cancel])

        let missing = PackageRecoveryPolicy.actions(for: PackageRecoveryContext(
            packageExists: false,
            backupAvailable: false,
            packageCanBeRevealed: false
        ))
        #expect(missing == [.exportDiagnostics, .cancel])
        #expect(PackageRecoveryAction.allCases.allSatisfy {
            !PackageRecoveryPolicy.permitsImplicitSourceMutation($0)
        })
    }

    @Test("Crash-safe presentation produces one bounded user message")
    func crashSafePresentation() {
        struct Failure: LocalizedError {
            var errorDescription: String? { "The operation failed." }
            var recoverySuggestion: String? { "Try opening a backup." }
        }

        let message = CrashSafePresentationPolicy.message(for: Failure(), operation: .open)
        #expect(!message.isEmpty)
        #expect(!message.contains("Optional("))
    }

    @Test("Long-script release budget rejects regressions")
    func longScriptBudget() {
        let budget = LongScriptPerformanceBudget.releaseGate
        #expect(budget.elementCount == 10_000)
        #expect(budget.accepts(open: 4.9, edit: 0.19, save: 4.9, export: 14.9))
        #expect(!budget.accepts(open: 5.1, edit: 0.19, save: 4.9, export: 14.9))
    }
}
