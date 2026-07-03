import Foundation

public enum ScreenplayLanguageProfile: String, Codable, CaseIterable, Equatable, Sendable {
    case automatic
    case english
    case spanishLatinAmerica
}

public enum ApplicationLanguagePreference: String, Codable, CaseIterable, Equatable, Sendable {
    case system
    case english
    case spanishLatinAmerica
}

public struct ScreenplayLexicon: Equatable, Sendable {
    public let scenePrefixes: [String]
    public let transitions: [String]
    public let shots: [String]
    public let titlePageAliases: [String: String]
    public let timeOfDayValues: [String]
    public let todoTokens: [String]
    public let cueExtensions: [String]

    public init(
        scenePrefixes: [String],
        transitions: [String],
        shots: [String],
        titlePageAliases: [String: String],
        timeOfDayValues: [String],
        todoTokens: [String],
        cueExtensions: [String]
    ) {
        self.scenePrefixes = scenePrefixes
        self.transitions = transitions
        self.shots = shots
        self.titlePageAliases = titlePageAliases
        self.timeOfDayValues = timeOfDayValues
        self.todoTokens = todoTokens
        self.cueExtensions = cueExtensions
    }
}

public enum ScreenplayLexiconCatalog {
    public static let english = ScreenplayLexicon(
        scenePrefixes: ["INT./EXT.", "EXT./INT.", "INT.", "EXT."],
        transitions: [
            "CUT TO:", "DISSOLVE TO:", "SMASH CUT TO:", "MATCH CUT TO:",
            "FADE IN:", "FADE OUT."
        ],
        shots: ["CLOSE ON:", "ANGLE ON:", "WIDE SHOT:", "INSERT:", "POV:"],
        titlePageAliases: normalizedAliases([
            "title": "title", "credit": "credit", "author": "author",
            "authors": "author", "written by": "author", "source": "source",
            "draft date": "draftDate", "date": "draftDate", "contact": "contact",
            "copyright": "copyright", "notes": "notes"
        ]),
        timeOfDayValues: ["DAY", "NIGHT", "DAWN", "DUSK", "NOON", "CONTINUOUS", "LATER", "SAME TIME"],
        todoTokens: ["TODO:"],
        cueExtensions: ["V.O.", "O.S.", "O.C.", "CONT'D", "CONT."]
    )

    public static let spanishLatinAmerica = ScreenplayLexicon(
        scenePrefixes: ["INT./EXT.", "EXT./INT.", "INT.", "EXT.", "I/E."],
        transitions: [
            "CORTE A:", "CORTE DIRECTO A:", "DISOLVENCIA A:", "ENCADENA A:",
            "FUNDIDO A:", "FUNDIDO A NEGRO.", "FUNDIDO A BLANCO.", "ABRE DE NEGRO:"
        ],
        shots: [
            "PRIMER PLANO:", "PLANO GENERAL:", "PLANO DETALLE:",
            "ÁNGULO SOBRE:", "INSERTAR:", "PUNTO DE VISTA:"
        ],
        titlePageAliases: normalizedAliases([
            "título": "title", "titulo": "title", "crédito": "credit", "credito": "credit",
            "autor": "author", "autores": "author", "escrito por": "author",
            "fuente": "source", "basado en": "source", "fecha de borrador": "draftDate",
            "fecha": "draftDate", "contacto": "contact", "derechos": "copyright",
            "derechos de autor": "copyright", "notas": "notes"
        ]),
        timeOfDayValues: [
            "DÍA", "NOCHE", "AMANECER", "ATARDECER", "MEDIODÍA", "MADRUGADA",
            "CONTINUO", "MOMENTOS DESPUÉS", "MÁS TARDE", "MISMO TIEMPO"
        ],
        todoTokens: ["PENDIENTE:", "POR HACER:"],
        cueExtensions: ["VOZ EN OFF", "FUERA DE CAMPO", "CONTINÚA"]
    )

    public static func lexicon(for profile: ScreenplayLanguageProfile) -> ScreenplayLexicon {
        switch profile {
        case .english:
            return english
        case .spanishLatinAmerica:
            return merged(primary: spanishLatinAmerica, secondary: english)
        case .automatic:
            return merged(primary: english, secondary: spanishLatinAmerica)
        }
    }

    private static func normalizedAliases(_ aliases: [String: String]) -> [String: String] {
        aliases.reduce(into: [:]) { result, alias in
            let key = TextNormalization.key(for: alias.key)
            if let existing = result[key], existing != alias.value {
                assertionFailure("Conflicting screenplay title-page aliases normalize to \(key).")
                return
            }
            result[key] = alias.value
        }
    }

    private static func merged(primary: ScreenplayLexicon, secondary: ScreenplayLexicon) -> ScreenplayLexicon {
        ScreenplayLexicon(
            scenePrefixes: unique(primary.scenePrefixes + secondary.scenePrefixes),
            transitions: unique(primary.transitions + secondary.transitions),
            shots: unique(primary.shots + secondary.shots),
            titlePageAliases: primary.titlePageAliases.merging(secondary.titlePageAliases) { first, _ in first },
            timeOfDayValues: unique(primary.timeOfDayValues + secondary.timeOfDayValues),
            todoTokens: unique(primary.todoTokens + secondary.todoTokens),
            cueExtensions: unique(primary.cueExtensions + secondary.cueExtensions)
        )
    }

    private static func unique(_ values: [String]) -> [String] {
        var keys: Set<String> = []
        return values.filter { keys.insert(TextNormalization.key(for: $0)).inserted }
    }
}

public enum LocalizedDiagnosticCatalog {
    public static func message(code: String, localeIdentifier: String) -> String {
        let spanish = localeIdentifier.lowercased().hasPrefix("es")
        switch code {
        case "ambiguousUppercaseLine":
            return spanish
                ? "El texto en mayúsculas se conservó sin crear un personaje porque el contexto de diálogo no fue claro."
                : "Uppercase text was preserved without creating a character cue because dialogue context was not clear."
        case "invalidSceneHeading":
            return spanish
                ? "El texto parece un encabezado de escena, pero no usa un prefijo compatible."
                : "Scene-like text is missing a supported scene heading prefix pattern."
        case "malformedParenthetical":
            return spanish
                ? "El texto entre paréntesis no tiene cierre y se conservó sin cambios."
                : "Parenthetical-like text is missing a closing parenthesis and must be preserved."
        default:
            return spanish ? "Se detectó un problema de formato." : "A formatting issue was detected."
        }
    }
}
