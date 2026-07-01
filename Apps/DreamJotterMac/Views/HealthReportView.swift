import DreamJotterCore
import SwiftUI

struct HealthReportView: View {
    let findings: [HealthFinding]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health")
                .font(.headline)

            if findings.isEmpty {
                Text("No findings. As you write, screenplay health checks will show advisory issues here without changing your text.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(findings.enumerated()), id: \.offset) { _, finding in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(finding.severity.rawValue.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(finding.message)
                        if let suggestedAction = finding.suggestedAction {
                            Text(suggestedAction)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Divider()
                }
            }
        }
    }
}
