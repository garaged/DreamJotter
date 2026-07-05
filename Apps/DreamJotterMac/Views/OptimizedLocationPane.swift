import DreamJotterCore
import SwiftUI

struct OptimizedLocationPane: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var detections: [DetectedLocation]?

    var body: some View {
        Group {
            if let detections {
                LocationListView(
                    locations: document.project.locations,
                    unresolvedDetectedLocations: detections,
                    createAction: { document.createLocationProfile(name: $0, note: $1) },
                    updateAction: { document.updateLocationProfile($0, name: $1, note: $2) },
                    deleteAction: { document.removeStoredProfile(id: $0.id, kind: .location) },
                    convertAction: { document.convertDetectedLocationToProfile($0) },
                    ignoreAction: { document.ignoreDetectedLocation($0) }
                )
            } else {
                ProgressView("Indexing locations…")
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            }
        }
        .task(id: document.derivedDataRevisionKey) { await load() }
    }

    private func load() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.projectPaneData(for: key) {
            detections = cached.unresolvedLocations
            return
        }
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            ProjectPaneDerivedData.build(for: project)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        detections = generated.unresolvedLocations
    }
}
