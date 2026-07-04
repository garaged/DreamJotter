import Foundation
import Testing

@Suite("M15 Review layout performance regressions")
struct ReviewLayoutPerformanceRegressionTests {
    @Test("Layout numbering uses lazy containers for long scripts")
    func layoutNumberingIsVirtualized() throws {
        let source = try sourceFile(
            "Apps/DreamJotterMac/Views/SimplifiedReviewLayoutNumberingView.swift"
        )

        #expect(source.contains("LazyVStack(alignment: .leading, spacing: 12)"))
        #expect(source.contains("LazyVGrid("))
        #expect(!source.contains("Grid(alignment:"))
        #expect(!source.contains(".textSelection(.enabled)"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
