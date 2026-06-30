import Foundation

public struct SpecRegistry: Decodable, Sendable {
    public let version: Int
    public let registryStatuses: [String]
    public let items: [SpecRegistryItem]

    private enum CodingKeys: String, CodingKey {
        case version
        case registryStatuses = "registry_statuses"
        case items
    }
}

public struct SpecRegistryItem: Decodable, Sendable {
    public let id: String
    public let title: String
    public let milestone: String
    public let status: String
    public let spec: String
    public let acceptance: String?
    public let relatedAdrs: [String]
    public let relatedDataContracts: [String]
    public let plannedModules: [String]
    public let guardrails: [String]
    public let notes: String

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case milestone
        case status
        case spec
        case acceptance
        case relatedAdrs = "related_adrs"
        case relatedDataContracts = "related_data_contracts"
        case plannedModules = "planned_modules"
        case guardrails
        case notes
    }
}

public enum SpecRepository {
    public static func root(startingAt start: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) throws -> URL {
        var candidate = start
        let fileManager = FileManager.default

        while true {
            let package = candidate.appendingPathComponent("Package.swift").path
            let agents = candidate.appendingPathComponent("AGENTS.md").path
            if fileManager.fileExists(atPath: package), fileManager.fileExists(atPath: agents) {
                return candidate
            }

            let parent = candidate.deletingLastPathComponent()
            if parent.path == candidate.path {
                throw SpecRepositoryError.rootNotFound(start.path)
            }
            candidate = parent
        }
    }

    public static func pathExists(_ relativePath: String) throws -> Bool {
        let url = try root().appendingPathComponent(relativePath)
        return FileManager.default.fileExists(atPath: url.path)
    }

    public static func read(_ relativePath: String) throws -> String {
        let url = try root().appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }

    public static func registry() throws -> SpecRegistry {
        let data = try Data(contentsOf: root().appendingPathComponent("specs/registry.yml"))
        return try JSONDecoder().decode(SpecRegistry.self, from: data)
    }

    public static func contains(_ text: String, _ needle: String) -> Bool {
        text.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}

public enum SpecRepositoryError: Error, CustomStringConvertible {
    case rootNotFound(String)

    public var description: String {
        switch self {
        case .rootNotFound(let path):
            return "Could not find DreamJotter repository root from \(path)"
        }
    }
}
