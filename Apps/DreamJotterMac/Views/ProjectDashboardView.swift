import SwiftUI

struct ProjectDashboardView: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard")
                .font(.headline)

            TextField("Project title", text: Binding(
                get: { document.dashboard.title },
                set: { document.updateTitle($0) }
            ))
            .font(.title3.weight(.semibold))
            .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 4) {
                Text("Logline")
                    .font(.caption.weight(.semibold))
                TextField("Add a one-sentence logline.", text: Binding(
                    get: { document.loglineText },
                    set: { document.updateLogline($0) }
                ), axis: .vertical)
                .lineLimit(2...4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Synopsis")
                    .font(.caption.weight(.semibold))
                TextField("Add a short synopsis for the project.", text: Binding(
                    get: { document.synopsisText },
                    set: { document.updateSynopsis($0) }
                ), axis: .vertical)
                .lineLimit(4...8)
            }

            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                GridRow {
                    metric("Scenes", document.dashboard.sceneCount)
                    metric("Characters", document.dashboard.characterCount)
                    metric("Unresolved Characters", document.dashboard.unresolvedCharacterCount)
                }
                GridRow {
                    metric("Locations", document.dashboard.locationCount)
                    metric("Unresolved Locations", document.dashboard.unresolvedLocationCount)
                    metric("Notes", document.dashboard.noteCount)
                }
                GridRow {
                    metric("TODOs", document.localizedScriptTodoNotes.count)
                    metric("Dirty", document.workspaceSummary.isDirty ? 1 : 0)
                    metric("Saved", document.workspaceSummary.lastSavedAt == nil ? 0 : 1)
                }
            }
        }
    }

    private func metric(_ label: LocalizedStringKey, _ value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(value.formatted())
                .font(.title3.weight(.semibold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
