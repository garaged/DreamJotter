import Foundation

public struct ScreenplayDocument: Equatable, Sendable {
    public let elements: [ScriptElement]
    public let scenes: [Scene]
    public let characters: [String]
    public let diagnostics: [ScreenplayDiagnostic]

    public init(
        elements: [ScriptElement] = [],
        scenes: [Scene] = [],
        characters: [String] = [],
        diagnostics: [ScreenplayDiagnostic] = []
    ) {
        self.elements = elements
        self.scenes = scenes
        self.characters = characters
        self.diagnostics = diagnostics
    }
}

public struct ScriptElement: Equatable, Sendable {
    public let kind: ScriptElementKind
    public let text: String
    public let characterName: String?

    public init(kind: ScriptElementKind, text: String, characterName: String? = nil) {
        self.kind = kind
        self.text = text
        self.characterName = characterName
    }
}

public enum ScriptElementKind: String, Equatable, Sendable {
    case titlePage
    case sceneHeading
    case action
    case characterCue
    case parenthetical
    case dialogue
    case transition
    case shot
    case section
    case synopsis
    case noteReference
    case pageBreak
    case unknown
}

public struct Scene: Equatable, Sendable {
    public let heading: String
    public let location: String
    public let timeOfDay: String?

    public init(heading: String, location: String, timeOfDay: String?) {
        self.heading = heading
        self.location = location
        self.timeOfDay = timeOfDay
    }
}

public struct ScreenplayDiagnostic: Equatable, Sendable {
    public let code: String
    public let message: String
    public let text: String

    public init(code: String, message: String, text: String) {
        self.code = code
        self.message = message
        self.text = text
    }
}
