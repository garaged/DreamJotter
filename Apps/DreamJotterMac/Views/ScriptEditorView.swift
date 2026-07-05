import DreamJotterCore
import SwiftUI

struct ScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        TextKitOnlyScriptEditorView(document: $document)
    }
}

extension ProjectDocumentViewModel {
    var screenplayLanguage: ScreenplayLanguageProfile {
        ScreenplayLanguagePersistence.language(in: project)
    }

    mutating func setScreenplayLanguage(_ language: ScreenplayLanguageProfile) {
        guard language != screenplayLanguage else { return }
        let configured = ScreenplayLanguagePersistence.setting(language, in: project)
        let parsed = ScreenplayParser.parse(scriptText, language: language)
        let updated = DreamJotterProject(
            metadata: configured.metadata,
            screenplay: parsed,
            mode: configured.mode,
            template: configured.template,
            characters: configured.characters,
            ignoredDetectedCharacterKeys: configured.ignoredDetectedCharacterKeys,
            locations: configured.locations,
            ignoredDetectedLocationKeys: configured.ignoredDetectedLocationKeys,
            notes: configured.notes,
            inboxItems: configured.inboxItems,
            sceneCards: configured.sceneCards,
            snapshots: configured.snapshots,
            exportPresets: configured.exportPresets,
            story: configured.story,
            pro: configured.pro
        )
        self = ScreenplayParsingContext.$language.withValue(language) {
            ProjectDocumentViewModel(
                project: updated,
                packageURL: packageURL,
                scriptText: scriptText,
                isDirty: true
            )
        }
    }

    mutating func updateScriptTextRespectingLanguage(_ text: String) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            updateScriptText(text)
        }
    }

    mutating func refreshParseRespectingLanguage(now: Date = Date()) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            refreshParse(now: now)
        }
    }

    mutating func acceptEditorSuggestionRespectingLanguage(_ suggestion: EditorSuggestion) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            acceptEditorSuggestion(suggestion)
        }
    }

    mutating func performSmartEnterRespectingLanguage(at cursorLocation: Int) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            performSmartEnter(at: cursorLocation)
        }
    }

    mutating func performTabCycleRespectingLanguage(at cursorLocation: Int) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            performTabCycle(at: cursorLocation)
        }
    }

    mutating func saveRespectingLanguage(to packageURL: URL, now: Date = Date()) throws {
        try ScreenplayParsingContext.$language.withValue(screenplayLanguage) {
            try save(to: packageURL, now: now)
        }
    }
}
