import SwiftUI

struct ProjectDashboardView: View {
    let snapshot: ProjectDashboardSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard")
                .font(.headline)

            Text(snapshot.title)
                .font(.title3.weight(.semibold))

            if let logline = snapshot.logline {
                Text(logline)
                    .foregroundStyle(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                GridRow {
                    metric("Scenes", snapshot.sceneCount)
                    metric("Characters", snapshot.characterCount)
                    metric("Notes", snapshot.noteCount)
                }
            }
        }
    }

    private func metric(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading) {
            Text(value.formatted())
                .font(.title3.weight(.semibold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
