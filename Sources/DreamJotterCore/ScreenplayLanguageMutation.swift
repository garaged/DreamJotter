import Foundation

public extension ScreenplayLanguagePersistence {
    static func setting(_ language: ScreenplayLanguageProfile, in project: DreamJotterProject) -> DreamJotterProject {
        let definition = CustomFieldDefinition(
            id: definitionID,
            name: "Screenplay language",
            type: .singleSelect,
            allowedTargets: [.project],
            selectOptions: ScreenplayLanguageProfile.allCases.map(\.rawValue)
        )
        let value = CustomFieldValue(
            id: valueID,
            definitionID: definitionID,
            targetKind: .project,
            targetID: project.metadata.id,
            value: .singleSelect(language.rawValue)
        )
        let pro = ProProjectState(
            revisionSets: project.pro.revisionSets,
            draftVersions: project.pro.draftVersions,
            productionBreakdown: project.pro.productionBreakdown,
            customFieldDefinitions: project.pro.customFieldDefinitions.filter { $0.id != definitionID } + [definition],
            customFieldValues: project.pro.customFieldValues.filter { $0.definitionID != definitionID } + [value],
            routines: project.pro.routines,
            routineLogs: project.pro.routineLogs
        )
        return DreamJotterProject(
            metadata: project.metadata,
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: pro
        )
    }
}
