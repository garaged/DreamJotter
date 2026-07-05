import SwiftUI

struct OptimizedDashboardPane: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var data: ProjectPaneDerivedData?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard").font(.headline)

            TextField("Project title", text: Binding(
                get: { document.project.metadata.title },
                set: { document.updateTitle($0) }
            ))
            .font(.title3.weight(.semibold))
            .textFieldStyle(.roundedBorder)

            TextField("Add a one-sentence logline.", text: Binding(
                get: { document.loglineText },
                set: { document.updateLogline($0) }
            ), axis: .vertical)
            .lineLimit(2...4)

            TextField("Add a short synopsis for the project.", text: Binding(
                get: { document.synopsisText },
                set: { document.updateSynopsis($0) }
            ), axis: .vertical)
            .lineLimit(4...8)

            if let data {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        metric("Scenes", document.project.screenplay.scenes.count)
                        metric("Characters", document.project.characters.count)
                        metric("Unresolved Characters", data.unresolvedCharacters.count)
                    }
                    GridRow {
                        metric("Locations", document.project.locations.count)
                        metric("Unresolved Locations", data.unresolvedLocations.count)
                        metric("Notes", data.openNoteCount)
                    }
                    GridRow {
                        metric("TODOs", data.todoCount)
                        metric("Dirty", document.isDirty ? 1 : 0)
                        metric("Saved", document.packageURL == nil ? 0 : 1)
                    }
                }
            } else {
                ProgressView("Preparing project metrics…")
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            }
        }
        .task(id: document.derivedDataRevisionKey) { await load() }
    }

    private func metric(_ label: LocalizedStringKey, _ value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(value.formatted()).font(.title3.weight(.semibold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func load() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.projectPaneData(for: key) {
            data = cached
            return
        }
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            ProjectPaneDerivedData.build(for: project)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        data = generated
    }
}
