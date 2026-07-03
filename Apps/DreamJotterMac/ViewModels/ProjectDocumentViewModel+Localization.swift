import DreamJotterCore
import Foundation

extension ProjectDocumentViewModel {
    var screenplayLanguage: ScreenplayLanguageProfile {
        ScreenplayLanguagePersistence.language(in: project)
    }

    mutating func setScreenplayLanguage(_ language: ScreenplayLanguageProfile) {
        guard language != screenplayLanguage else { return }
        let projectWithSetting = ScreenplayLanguagePersistence.setting(language, in: project)
        let parsed = ScreenplayParser.parse(scriptText, language: language)
        let updated = DreamJotterProject(
            metadata: projectWithSetting.metadata,
            screenplay: parsed,
            mode: projectWithSetting.mode,
            template: projectWithSetting.template,
            characters: projectWithSetting.characters,
            ignoredDetectedCharacterKeys: projectWithSetting.ignoredDetectedCharacterKeys,
            locations: projectWithSetting.locations,
            ignoredDetectedLocationKeys: projectWithSetting.ignoredDetectedLocationKeys,
            notes: projectWithSetting.notes,
            inboxItems: projectWithSetting.inboxItems,
            sceneCards: projectWithSetting.sceneCards,
            snapshots: projectWithSetting.snapshots,
            exportPresets: projectWithSetting.exportPresets,
            story: projectWithSetting.story,
            pro: projectWithSetting.pro
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
        withScreenplayLanguage {
            updateScriptText(text)
        }
    }

    mutating func refreshParseRespectingLanguage(now: Date = Date()) {
        withScreenplayLanguage {
            refreshParse(now: now)
        }
    }

    mutating func acceptEditorSuggestionRespectingLanguage(_ suggestion: EditorSuggestion) {
        withScreenplayLanguage {
            acceptEditorSuggestion(suggestion)
        }
    }

    mutating func performSmartEnterRespectingLanguage(at cursorLocation: Int) {
        withScreenplayLanguage {
            performSmartEnter(at: cursorLocation)
        }
    }

    mutating func performTabCycleRespectingLanguage(at cursorLocation: Int) {
        withScreenplayLanguage {
            performTabCycle(at: cursorLocation)
        }
    }

    mutating func saveRespectingLanguage(to packageURL: URL, now: Date = Date()) throws {
        let language = screenplayLanguage
        try ScreenplayParsingContext.$language.withValue(language) {
            try save(to: packageURL, now: now)
        }
    }

    private mutating func withScreenplayLanguage(_ operation: () -> Void) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            operation()
        }
    }
}
