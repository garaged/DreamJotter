import SpecSupport
import Testing

@Suite("Milestone 3 Executable Specs")
struct Milestone3ExecutableSpecs {
    @Test("Milestone 3 friendly writer tool specs exist")
    func milestoneThreeSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-3-friendly-writer-tools.md",
            "docs/acceptance/milestone-3-acceptance.md",
            "docs/ai/ai-abstraction-spec.md",
            "docs/specs/continuity-analysis-spec.md",
            "docs/specs/table-read-spec.md",
            "docs/ux/writing-experience-principles.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("AI spec keeps external providers out of Milestone 4")
    func aiSpecKeepsExternalProvidersOutOfMilestoneFour() throws {
        let aiSpec = try SpecRepository.read("docs/ai/ai-abstraction-spec.md")

        #expect(SpecRepository.contains(aiSpec, "No real provider through Milestone 4"))
        #expect(SpecRepository.contains(aiSpec, "FakeAIProvider"))
        #expect(SpecRepository.contains(aiSpec, "AIRequest"))
        #expect(SpecRepository.contains(aiSpec, "AIResponse"))
        #expect(SpecRepository.contains(aiSpec, "AISuggestion"))
        #expect(SpecRepository.contains(aiSpec, "snapshot before"))
        #expect(SpecRepository.contains(aiSpec, "no external AI calls"))
    }

    @Test("Analysis specs are read-only")
    func analysisSpecsAreReadOnly() throws {
        let scriptAnalysis = try SpecRepository.read("docs/specs/script-analysis-spec.md")
        let continuityAnalysis = try SpecRepository.read("docs/specs/continuity-analysis-spec.md")

        #expect(SpecRepository.contains(scriptAnalysis, "Reports must not mutate project data"))
        #expect(SpecRepository.contains(scriptAnalysis, "report behavior"))
        #expect(SpecRepository.contains(continuityAnalysis, "Findings are advisory"))
        #expect(SpecRepository.contains(continuityAnalysis, "False-positive mitigation"))
    }
}
