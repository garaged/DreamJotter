import DreamJotterCore
import SwiftUI

private enum ReviewSeverityFilter: String, CaseIterable, Identifiable {
    case all = "All severities"
    case info = "Info"
    case warning = "Warnings"
    case issue = "Issues"

    var id: String { rawValue }

    func matches(_ severity: ReviewFindingSeverity) -> Bool {
        switch self {
        case .all: return true
        case .info: return severity == .info
        case .warning: return severity == .warning
        case .issue: return severity == .issue
        }
    }
}

private enum ReviewSourceFilter: String, CaseIterable, Identifiable {
    case all = "All sources"
    case formatting = "Formatting"
    case unresolvedCharacter = "Characters"
    case unresolvedLocation = "Locations"
    case todo = "TODOs"
    case healthReport = "Health"
    case storage = "Storage"

    var id: String { rawValue }

    func matches(_ source: ReviewFindingSource) -> Bool {
        switch self {
        case .all: return true
        case .formatting: return source == .formatting
        case .unresolvedCharacter: return source == .unresolvedCharacter
        case .unresolvedLocation: return source == .unresolvedLocation
        case .todo: return source == .todo
        case .healthReport: return source == .healthReport
        case .storage: return source == .storage
        }
    }
}

struct ReviewModeView: View {
    @Binding var document: ProjectDocumentViewModel
    let exportAction: () -> Void
    let openScriptAction: () -> Void

    @State private var showLayoutNumbering = true
    @State private var searchText = ""
    @State private var severityFilter: ReviewSeverityFilter = .all
    @State private var sourceFilter: ReviewSourceFilter = .all

    private var report: ScriptHealthReport {
        document.scriptHealthReport
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                navigationSummary
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
                    Text("Read-only script review with searchable findings and direct navigation.")
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

    private var navigationSummary: some View {
        HStack(spacing: 10) {
            Label("Use filters to narrow findings, then open any result directly in the script.", systemImage: "location.magnifyingglass")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            if let selectedID = document.reviewModeState.selectedFindingID,
               let selected = report.findings.first(where: { $0.id == selectedID }) {
                Button("Open Selected in Script") {
                    openFinding(selected)
                }
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                SimplifiedReviewLayoutNumberingView(plan: plan)
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Review Findings")
                .font(.headline)

            filterBar

            if filteredFindings.isEmpty {
                Text(report.findings.isEmpty ? "No review findings yet." : "No findings match the current filters.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredFindings, id: \.id) { finding in
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            document.selectReviewFinding(finding)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: iconName(for: finding.severity))
                                    .foregroundStyle(color(for: finding.severity))

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(finding.title)
                                            .font(.subheadline.bold())
                                        Text(finding.source.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
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

                        HStack {
                            Button("Select") {
                                document.selectReviewFinding(finding)
                            }
                            Button("Open in Script") {
                                openFinding(finding)
                            }
                            Spacer()
                            Text(navigationDescription(for: finding))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Divider()
                }
            }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("Search finding title, message, action, or source", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Picker("Severity", selection: $severityFilter) {
                    ForEach(ReviewSeverityFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                .frame(width: 145)
                Picker("Source", selection: $sourceFilter) {
                    ForEach(ReviewSourceFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                .frame(width: 145)
                if !searchText.isEmpty || severityFilter != .all || sourceFilter != .all {
                    Button("Clear") {
                        searchText = ""
                        severityFilter = .all
                        sourceFilter = .all
                    }
                }
            }
            Text("Showing \(filteredFindings.count) of \(report.findings.count) findings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var filteredFindings: [ReviewFinding] {
        report.findings.filter { finding in
            guard severityFilter.matches(finding.severity), sourceFilter.matches(finding.source) else { return false }
            guard !normalizedSearch.isEmpty else { return true }
            let material = [
                finding.title,
                finding.message,
                finding.suggestedAction ?? "",
                finding.source.rawValue,
                finding.linkedEntityID ?? ""
            ].joined(separator: " ")
            return TextNormalization.key(for: material).contains(normalizedSearch)
        }
    }

    private var normalizedSearch: String {
        TextNormalization.key(for: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func openFinding(_ finding: ReviewFinding) {
        document.selectReviewFinding(finding)
        document.exitReviewMode()
        openScriptAction()
    }

    private func navigationDescription(for finding: ReviewFinding) -> String {
        guard let type = finding.linkedEntityType else { return "Project-level finding" }
        if let id = finding.linkedEntityID {
            return "\(type.rawValue.capitalized): \(id)"
        }
        return type.rawValue.capitalized
    }

    private func iconName(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .issue: return "xmark.octagon"
        }
    }

    private func color(for severity: ReviewFindingSeverity) -> Color {
        switch severity {
        case .info: return .secondary
        case .warning: return .orange
        case .issue: return .red
        }
    }
}
