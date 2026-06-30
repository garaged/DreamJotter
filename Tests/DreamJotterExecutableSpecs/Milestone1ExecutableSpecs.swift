import Foundation
import SpecSupport
import Testing

@Suite("Milestone 1 Executable Specs")
struct Milestone1ExecutableSpecs {
    @Test("Required foundation specs exist")
    func requiredFoundationSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-1-apple-prototype-foundations.md",
            "docs/acceptance/milestone-1-acceptance.md",
            "docs/specs/product-requirements.md",
            "docs/data-contracts/core-domain-model.md",
            "docs/data-contracts/screenplay-element-kinds.md",
            "docs/data-contracts/serialization-rules.md",
            "docs/storage/dreamjotter-package-format.md",
            "docs/editor/screenplay-engine-spec.md",
            "docs/editor/fountain-support-spec.md",
            "docs/editor/editor-behavior-spec.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Architecture docs preserve core guardrails")
    func architectureDocsPreserveCoreGuardrails() throws {
        let architectureCorpus = try [
            "docs/architecture/overview.md",
            "docs/architecture/apple-native-first.md",
            "docs/architecture/portable-core.md",
            "docs/architecture/command-engine-spec.md"
        ]
        .map { try SpecRepository.read($0) }
        .joined(separator: "\n")

        #expect(SpecRepository.contains(architectureCorpus, "Apple-native first"))
        #expect(SpecRepository.contains(architectureCorpus, "portable core"))
        #expect(SpecRepository.contains(architectureCorpus, ".dreamjotter"))
        #expect(SpecRepository.contains(architectureCorpus, "commands before routines before plugins"))
        #expect(SpecRepository.contains(architectureCorpus, "SwiftData is not canonical storage"))
    }

    @Test("Registry spec paths exist")
    func registrySpecPathsExist() throws {
        let registry = try SpecRepository.registry()

        for item in registry.items {
            #expect(try SpecRepository.pathExists(item.spec))
            if let acceptance = item.acceptance, !acceptance.isEmpty {
                #expect(try SpecRepository.pathExists(acceptance))
            }
        }
    }
}
