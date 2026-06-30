import Foundation

public struct ScreenplayFixtureExpectation: Decodable, Sendable {
    public let fixture: String
    public let description: String
    public let expectedElements: [ExpectedScriptElement]
    public let expectedScenes: [ExpectedScene]
    public let expectedCharacters: [String]
    public let expectedDiagnostics: [ExpectedDiagnostic]
}

public struct ExpectedScriptElement: Decodable, Equatable, Sendable {
    public let kind: String
    public let text: String
    public let characterName: String?

    public init(kind: String, text: String, characterName: String? = nil) {
        self.kind = kind
        self.text = text
        self.characterName = characterName
    }
}

public struct ExpectedScene: Decodable, Equatable, Sendable {
    public let heading: String
    public let location: String
    public let timeOfDay: String?

    public init(heading: String, location: String, timeOfDay: String?) {
        self.heading = heading
        self.location = location
        self.timeOfDay = timeOfDay
    }
}

public struct ExpectedDiagnostic: Decodable, Equatable, Sendable {
    public let code: String
    public let message: String
    public let text: String

    public init(code: String, message: String, text: String) {
        self.code = code
        self.message = message
        self.text = text
    }
}

public enum ScreenplayFixtureExpectations {
    public static let expectedFixturePaths = [
        "specs/fixtures/screenplay/expected/simple.json",
        "specs/fixtures/screenplay/expected/multi-scene.json",
        "specs/fixtures/screenplay/expected/spanish-unicode.json",
        "specs/fixtures/screenplay/expected/malformed.json",
        "specs/fixtures/screenplay/expected/advanced.json"
    ]

    public static let canonicalElementKinds: Set<String> = [
        "titlePage",
        "sceneHeading",
        "action",
        "characterCue",
        "parenthetical",
        "dialogue",
        "transition",
        "shot",
        "section",
        "synopsis",
        "noteReference",
        "pageBreak",
        "unknown"
    ]

    public static func loadAll() throws -> [ScreenplayFixtureExpectation] {
        try expectedFixturePaths.map(load)
    }

    public static func load(_ relativePath: String) throws -> ScreenplayFixtureExpectation {
        let data = try Data(contentsOf: SpecRepository.root().appendingPathComponent(relativePath))
        return try JSONDecoder().decode(ScreenplayFixtureExpectation.self, from: data)
    }
}
