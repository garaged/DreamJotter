import Foundation
import Testing
@testable import DreamJotterCore

@Suite("M12.4 Localization and Spanish Screenplay Support")
struct LocalizationSpanishExecutableSpecs {
    @Test("Spanish screenplay constructs map to language-neutral semantic kinds")
    func spanishConstructs() {
        let source = """
        Título: El corazón de Sofía
        Autor: María López

        INT. CASA DE SOFÍA - NOCHE

        SOFÍA
        (susurrando)
        No sé qué decir.

        CORTE A:

        EXT. PARQUE - DÍA

        PRIMER PLANO:
        [[PENDIENTE: revisar diálogo de ÍÑIGO]]
        """

        let document = ScreenplayParser.parse(source, language: .spanishLatinAmerica)
        #expect(document.elements.map(\.kind) == [
            .titlePage, .sceneHeading, .characterCue, .parenthetical, .dialogue,
            .transition, .sceneHeading, .shot, .noteReference
        ])
        #expect(document.elements[0].text.contains("Título: El corazón de Sofía"))
        #expect(document.elements[2].text == "SOFÍA")
        #expect(document.elements[5].text == "CORTE A:")
        #expect(document.elements[7].text == "PRIMER PLANO:")
        #expect(document.scenes.map(\.timeOfDay) == ["NOCHE", "DÍA"])
        #expect(document.characters == ["SOFÍA"])
    }

    @Test("Automatic mode accepts mixed English and Spanish constructs")
    func mixedLanguage() {
        let source = """
        INT. KITCHEN - DAY

        SOFÍA
        We need to leave.

        FUNDIDO A NEGRO.

        EXT. PARQUE - NOCHE
        """
        let document = ScreenplayParser.parse(source)
        #expect(document.scenes.map(\.heading) == ["INT. KITCHEN - DAY", "EXT. PARQUE - NOCHE"])
        #expect(document.elements.contains { $0.kind == .transition && $0.text == "FUNDIDO A NEGRO." })
    }

    @Test("Spanish I/E alias preserves original heading")
    func spanishInteriorExteriorAlias() {
        let document = ScreenplayParser.parse("I/E. AUTO - CONTINUO", language: .spanishLatinAmerica)
        #expect(document.elements.first?.kind == .sceneHeading)
        #expect(document.elements.first?.text == "I/E. AUTO - CONTINUO")
        #expect(document.scenes.first?.location == "AUTO")
        #expect(document.scenes.first?.timeOfDay == "CONTINUO")
    }

    @Test("Unicode cue extensions resolve a stable base character")
    func cueExtensions() {
        #expect(ScreenplayConstructs.baseCharacterName(from: "SOFÍA (V.O.)") == "SOFÍA")
        #expect(ScreenplayConstructs.baseCharacterName(from: "ÍÑIGO (VOZ EN OFF)") == "ÍÑIGO")
        #expect(ScreenplayConstructs.baseCharacterName(from: "DOÑA ÁNGELES") == "DOÑA ÁNGELES")
    }

    @Test("Spanish TODO aliases remain note text and are detected")
    func todoAliases() {
        let note = "PENDIENTE: revisar diálogo de SOFÍA"
        let document = ScreenplayParser.parse("[[\(note)]]", language: .spanishLatinAmerica)
        #expect(document.elements.first?.kind == .noteReference)
        #expect(document.elements.first?.text == note)
        #expect(ScreenplayConstructs.containsTodoToken(note, profile: .spanishLatinAmerica))
    }

    @Test("Language setting is backward compatible and persisted in project metadata")
    func languagePersistence() {
        let project = ProjectFactory.blankProject(title: "Idioma", now: Date(timeIntervalSince1970: 1_730_000_000))
        #expect(ScreenplayLanguagePersistence.language(in: project) == .automatic)

        let spanish = ScreenplayLanguagePersistence.setting(.spanishLatinAmerica, in: project)
        #expect(ScreenplayLanguagePersistence.language(in: spanish) == .spanishLatinAmerica)

        let data = try! JSONEncoder().encode(spanish)
        let decoded = try! JSONDecoder().decode(DreamJotterProject.self, from: data)
        #expect(ScreenplayLanguagePersistence.language(in: decoded) == .spanishLatinAmerica)
    }

    @Test("English profile keeps legacy semantic output")
    func englishRegression() {
        let source = """
        Title: A Test

        INT. ROOM - DAY

        ELENA
        We begin here.

        CUT TO:
        """
        #expect(ScreenplayParser.parse(source, language: .english) == LegacyScreenplayParser.parse(source))
    }

    @Test("Search normalization matches accents without changing storage")
    func unicodeNormalization() {
        #expect(TextNormalization.key(for: "SOFÍA") == TextNormalization.key(for: "sofia"))
        #expect(TextNormalization.key(for: "CAFÉ") == TextNormalization.key(for: "cafe"))
        #expect(TextNormalization.key(for: "Corazón") == TextNormalization.key(for: "corazon"))
    }

    @Test("Diagnostic messages can render in English and Spanish from one code")
    func localizedDiagnostics() {
        let english = LocalizedDiagnosticCatalog.message(code: "invalidSceneHeading", localeIdentifier: "en")
        let spanish = LocalizedDiagnosticCatalog.message(code: "invalidSceneHeading", localeIdentifier: "es-MX")
        #expect(english != spanish)
        #expect(spanish.contains("escena"))
    }
}
