import DreamJotterCore
import SwiftUI

struct ReviewModeView: View {
    @Binding var document: ProjectDocumentViewModel
    let exportAction: () -> Void
    let openScriptAction: () -> Void

    @State private var showLayoutNumbering = true

    private var report: ScriptHealthReport {
        document.scriptHealthReport
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                scriptPreview
                findingsSection
            }
            .padding()
        }
        .onAppear {
            document.enterReviewMode()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Review Mode")
                        .font(.title2.bold())
                    Text("Read-only script review, health findings, and export.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Edit Script") {
                    document.exitReviewMode()
                    openScriptAction()
                }

                Button("Export Fountain") {
                    exportAction()
                }
            }

            HStack(spacing: 16) {
                Label("\(report.sceneCount) scenes", systemImage: "rectangle.stack")
                Label("\(report.findings.count) findings", systemImage: "exclamationmark.triangle")
                Label(document.reviewModeState.isReadOnly ? "Read-only" : "Editable", systemImage: "lock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var scriptPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Script Preview")
                    .font(.headline)
                Spacer()
                Toggle("Show layout numbering", isOn: $showLayoutNumbering)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            if showLayoutNumbering, let plan = document.reviewPDFLayoutPlan {
                ReviewLayoutNumberingView(plan: plan)
            } else {
                Text(document.fountainExportText.isEmpty ? "No script text yet." : document.fountainExportText)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private var findingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review Findings")
                .font(.headline)

            if report.findings.isEmpty {
                Text("No review findings yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(report.findings, id: \.id) { finding in
                    Button {
                        document.selectReviewFinding(finding)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: iconName(for: finding.severity))
                                .foregroundStyle(color(for: finding.severity))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(finding.title)
                                    .font(.subheadline.bold())
                                Text(finding.message)
                                    .foregroundStyle(.secondary)
                                if let action = finding.suggestedAction {
                                    Text(action)
                                        .font(.caption)
                                      .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()
                        }
                        .padding(8)
                        .background(document.reviewModeState.selectedFindingID == finding.id ? Color.accentColor.opacity(0.12) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func iconName(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info:
            return "info.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .issue:
            return "xmark.octagon"
      }
    }

    private func color(for severity: ReviewFindingSeverity) -> Color {
        switch severity {
        case .info:
            return .secondary
      case .warning:
            return .orange
      case .issue:
            return .red
        }
    }
}
