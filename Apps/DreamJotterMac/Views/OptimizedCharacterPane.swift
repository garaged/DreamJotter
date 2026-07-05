import DreamJotterCore
import SwiftUI

struct OptimizedCharacterPane: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var detections: [DetectedCharacter]?

    var body: some View {
        Group {
            if let detections {
                CharacterListView(
                    characters: document.project.characters,
                    unresolvedDetectedCharacters: detections,
                    createAction: { document.createCharacterProfile(name: $0, note: $1) },
                    updateAction: { document.updateCharacterProfile($0, name: $1, note: $2) },
                    deleteAction: { document.removeStoredProfile(id: $0.id, kind: .character) },
                    convertAction: { document.convertDetectedCharacterToProfile($0) },
                    ignoreAction: { document.ignoreDetectedCharacter($0) }
                )
            } else {
                ProgressView("Indexing characters…")
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            }
        }
        .task(id: document.derivedDataRevisionKey) { await load() }
    }

    private func load() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.projectPaneData(for: key) {
            detections = cached.unresolvedCharacters
            return
        }
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            ProjectPaneDerivedData.build(for: project)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        detections = generated.unresolvedCharacters
    }
}
