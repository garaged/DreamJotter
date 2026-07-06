import DreamJotterCore
import Foundation

public enum IOSEditorProjectProjection {
    public static func applying(
        text: String,
        to project: DreamJotterProject,
        modifiedAt: Date = Date()
    ) -> DreamJotterProject {
        let projectedText = IOSExternalScreenplayReplacementStore.sharedText(or: text)
        let language = ScreenplayLanguagePersistence.language(in: project)
        let screenplay = ScreenplayParser.parse(projectedText, language: language)
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
        return DreamJotterProject(
            metadata: metadata,
            screenplay: screenplay,
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
            pro: project.pro
        )
    }
}

private extension IOSExternalScreenplayReplacementStore {
    static func sharedText(or fallback: String) -> String {
        current() ?? fallback
    }
}
