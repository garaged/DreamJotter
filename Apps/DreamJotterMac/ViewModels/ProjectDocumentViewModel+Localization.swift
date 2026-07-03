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
        self = ProjectDocumentViewModel(
            project: updated,
            packageURL: packageURL,
            scriptText: scriptText,
            isDirty: true
        )
    }
}
