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
                        Text(localizedSeverity(finding.severity.rawValue))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(localized(finding.message))
                        if let suggestedAction = finding.suggestedAction {
                            Text(localized(suggestedAction))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private func localized(_ value: String) -> String {
        String(localized: String.LocalizationValue(value))
    }

    private func localizedSeverity(_ rawValue: String) -> String {
        switch rawValue {
        case "info": String(localized: "Information")
        case "warning": String(localized: "Warning")
        case "issue", "error": String(localized: "Issue")
        default: localized(rawValue)
        }
    }
}
