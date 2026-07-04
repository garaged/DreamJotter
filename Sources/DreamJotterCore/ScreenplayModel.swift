import Foundation

public struct ScreenplayDocument: Codable, Equatable, Sendable {
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

public enum ScreenplayParagraphType: String, Codable, Equatable, CaseIterable, Sendable {
    case sceneHeading
    case action
    case characterCue
    case dialogue
    case parenthetical
    case transition
    case shot
    case section
    case synopsis
    case montage
    case characterIntroduction
    case note
    case pageBreak
    case titlePage
    case unknown

    public var elementKind: ScriptElementKind {
        switch self {
        case .sceneHeading: .sceneHeading
        case .action, .characterIntroduction: .action
        case .characterCue: .characterCue
        case .dialogue: .dialogue
        case .parenthetical: .parenthetical
        case .transition: .transition
        case .shot: .shot
        case .section, .montage: .section
        case .synopsis: .synopsis
        case .note: .noteReference
        case .pageBreak: .pageBreak
        case .titlePage: .titlePage
        case .unknown: .unknown
        }
    }

    public static func compatibleType(for kind: ScriptElementKind) -> ScreenplayParagraphType {
        switch kind {
        case .titlePage: .titlePage
        case .sceneHeading: .sceneHeading
        case .action: .action
        case .characterCue: .characterCue
        case .parenthetical: .parenthetical
        case .dialogue: .dialogue
        case .transition: .transition
        case .shot: .shot
        case .section: .section
        case .synopsis: .synopsis
        case .noteReference: .note
        case .pageBreak: .pageBreak
        case .unknown: .unknown
        }
    }
}

public struct ScriptElement: Codable, Equatable, Sendable {
    public let kind: ScriptElementKind
    public let text: String
    public let characterName: String?
    public let paragraphType: ScreenplayParagraphType

    public init(
        kind: ScriptElementKind,
        text: String,
        characterName: String? = nil,
        paragraphType: ScreenplayParagraphType? = nil
    ) {
        self.kind = kind
        self.text = text
        self.characterName = characterName
        self.paragraphType = paragraphType ?? .compatibleType(for: kind)
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case text
        case characterName
        case paragraphType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(ScriptElementKind.self, forKey: .kind)
        self.kind = kind
        text = try container.decode(String.self, forKey: .text)
        characterName = try container.decodeIfPresent(String.self, forKey: .characterName)
        paragraphType = try container.decodeIfPresent(ScreenplayParagraphType.self, forKey: .paragraphType)
            ?? .compatibleType(for: kind)
    }
}

public enum ScriptElementKind: String, Codable, Equatable, Sendable {
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

public struct Scene: Codable, Equatable, Sendable {
    public let heading: String
    public let location: String
    public let timeOfDay: String?

    public init(heading: String, location: String, timeOfDay: String?) {
        self.heading = heading
        self.location = location
        self.timeOfDay = timeOfDay
    }
}

public struct ScreenplayDiagnostic: Codable, Equatable, Sendable {
    public let code: String
    public let message: String
    public let text: String

    public init(code: String, message: String, text: String) {
        self.code = code
        self.message = message
        self.text = text
    }
}
