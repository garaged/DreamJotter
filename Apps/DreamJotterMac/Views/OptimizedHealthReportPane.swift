import SwiftUI

struct OptimizedHealthReportPane: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var findings: [HealthFinding]?

    var body: some View {
        Group {
            if let findings {
                HealthReportView(findings: findings)
            } else {
                ProgressView("Preparing health report…")
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            }
        }
        .task(id: document.derivedDataRevisionKey) { await load() }
    }

    private func load() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.projectPaneData(for: key) {
            findings = cached.healthFindings
            return
        }
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            ProjectPaneDerivedData.build(for: project)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        findings = generated.healthFindings
    }
}
