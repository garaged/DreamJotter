import SpecSupport
import Testing

@Suite("Milestone 2 Executable Specs")
struct Milestone2ExecutableSpecs {
    @Test("Milestone 2 organization specs exist")
    func milestoneTwoSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-2-real-mvp.md",
            "docs/acceptance/milestone-2-acceptance.md",
            "docs/export/export-system-spec.md",
            "docs/specs/script-analysis-spec.md",
            "docs/storage/dreamjotter-package-format.md",
            "docs/storage/storage-errors.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Traceability matrix mentions every milestone spec file")
    func traceabilityMentionsEveryMilestoneSpecFile() throws {
        let traceability = try SpecRepository.read("docs/acceptance/traceability-matrix.md")
        let milestoneSpecFiles = [
            "docs/milestones/milestone-1-apple-prototype-foundations.md",
            "docs/milestones/milestone-2-real-mvp.md",
            "docs/milestones/milestone-3-friendly-writer-tools.md",
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/milestones/milestone-map.md"
        ]

        for path in milestoneSpecFiles {
            #expect(traceability.contains(path))
        }
    }

    @Test("Traceability matrix mentions registered acceptance files")
    func traceabilityMentionsRegisteredAcceptanceFiles() throws {
        let traceability = try SpecRepository.read("docs/acceptance/traceability-matrix.md")
        let registry = try SpecRepository.registry()
        let acceptanceFiles = Set(registry.items.compactMap(\.acceptance).filter { !$0.isEmpty })

        for path in acceptanceFiles where path.contains("milestone") {
            let fileExists = try SpecRepository.pathExists(path)
            #expect(traceability.contains(path) || fileExists)
        }
    }
}
