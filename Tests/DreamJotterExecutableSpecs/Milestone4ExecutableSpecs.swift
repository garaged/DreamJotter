import SpecSupport
import Testing

@Suite("Milestone 4 Executable Specs")
struct Milestone4ExecutableSpecs {
    @Test("Milestone 4 pro foundation specs exist")
    func milestoneFourSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/acceptance/milestone-4-acceptance.md",
            "docs/routines/routine-system-v1-spec.md",
            "docs/architecture/command-engine-spec.md",
            "docs/plugins/future-plugin-extension-points.md",
            "docs/plugins/future-plugin-model.md",
            "docs/export/export-system-spec.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Milestone 4 does not scope arbitrary plugin scripting")
    func milestoneFourDoesNotScopeArbitraryPluginScripting() throws {
        let milestoneFourCorpus = try [
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/plugins/future-plugin-extension-points.md",
            "docs/plugins/future-plugin-model.md",
            "docs/routines/routine-system-v1-spec.md"
        ]
        .map { try SpecRepository.read($0) }
        .joined(separator: "\n")

        #expect(SpecRepository.contains(milestoneFourCorpus, "No arbitrary scripting"))
        #expect(SpecRepository.contains(milestoneFourCorpus, "plugin runtime"))
        #expect(SpecRepository.contains(milestoneFourCorpus, "deferred"))
        #expect(!SpecRepository.contains(milestoneFourCorpus, "Milestone 4 includes arbitrary scripting"))
        #expect(!SpecRepository.contains(milestoneFourCorpus, "Milestone 4 allows arbitrary scripting"))
        #expect(!SpecRepository.contains(milestoneFourCorpus, "arbitrary plugin scripting is in scope"))
    }

    @Test("Routines mutate only through CommandEngine")
    func routinesMutateOnlyThroughCommandEngine() throws {
        let routineSpec = try SpecRepository.read("docs/routines/routine-system-v1-spec.md")
        let commandSpec = try SpecRepository.read("docs/architecture/command-engine-spec.md")

        #expect(SpecRepository.contains(routineSpec, "CommandEngine-only mutation"))
        #expect(SpecRepository.contains(routineSpec, "no-code"))
        #expect(SpecRepository.contains(commandSpec, "safe mutation boundary"))
        #expect(SpecRepository.contains(commandSpec, "Future plugins"))
    }
}
