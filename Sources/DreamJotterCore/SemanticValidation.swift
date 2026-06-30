import Foundation

public enum ValidationSeverity: String, Codable, Equatable, Sendable {
    case info
    case warning
    case error
}

public struct ValidationIssue: Codable, Equatable, Sendable {
    public let code: String
    public let severity: ValidationSeverity
    public let message: String
    public let elementText: String?

    public init(code: String, severity: ValidationSeverity, message: String, elementText: String? = nil) {
        self.code = code
        self.severity = severity
        self.message = message
        self.elementText = elementText
    }
}

public enum SemanticValidator {
    public static func validate(document: ScreenplayDocument) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        let characterSet = Set(document.characters)
        let sceneHeadingSet = Set(document.elements.filter { $0.kind == .sceneHeading }.map(\.text))

        for element in document.elements {
            if element.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(ValidationIssue(
                    code: "emptyElementText",
                    severity: .error,
                    message: "Screenplay elements must preserve non-empty authored text.",
                    elementText: element.text
                ))
            }

            if [.dialogue, .parenthetical].contains(element.kind),
               element.characterName?.isEmpty ?? true {
                issues.append(ValidationIssue(
                    code: "missingDialogueCharacter",
                    severity: .warning,
                    message: "Dialogue and parenthetical elements should reference the active character cue.",
                    elementText: element.text
                ))
            }

            if let characterName = element.characterName,
               !characterSet.contains(characterName) {
                issues.append(ValidationIssue(
                    code: "unknownDialogueCharacter",
                    severity: .warning,
                    message: "Dialogue references a character that is not in the document character list.",
                    elementText: element.text
                ))
            }
        }

        for scene in document.scenes where !sceneHeadingSet.contains(scene.heading) {
            issues.append(ValidationIssue(
                code: "sceneWithoutHeadingElement",
                severity: .error,
                message: "Scene records must derive from semantic scene heading elements.",
                elementText: scene.heading
            ))
        }

        return issues
    }

    public static func validate(project: DreamJotterProject) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        if project.metadata.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(ValidationIssue(
                code: "missingProjectID",
                severity: .error,
                message: "Project metadata requires a portable project ID."
            ))
        }

        if project.metadata.primaryScreenplayID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(ValidationIssue(
                code: "missingPrimaryScreenplayID",
                severity: .error,
                message: "Project metadata requires a primary screenplay ID."
            ))
        }

        if project.metadata.packageExtension != ".dreamjotter" {
            issues.append(ValidationIssue(
                code: "invalidPackageExtension",
                severity: .error,
                message: "DreamJotter project packages must use the .dreamjotter extension."
            ))
        }

        issues.append(contentsOf: validate(document: project.screenplay))
        return issues
    }
}
