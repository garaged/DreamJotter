import DreamJotterCore
import SwiftUI

private enum ReviewSeverityFilter: String, CaseIterable, Identifiable {
    case all
    case info
    case warning
    case issue

    var id: String { rawValue }

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .all: "All severities"
        case .info: "Information"
        case .warning: "Warnings"
        case .issue: "Issues"
        }
    }

    func matches(_ severity: ReviewFindingSeverity) -> Bool {
        switch self {
        case .all: true
        case .info: severity == .info
        case .warning: severity == .warning
        case .issue: severity == .issue
        }
    }
}

private enum ReviewSourceFilter: String, CaseIterable, Identifiable {
    case all
    case formatting
    case unresolvedCharacter
    case unresolvedLocation
    case todo
    case healthReport
    case storage

    var id: String { rawValue }

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .all: "All sources"
        case .formatting: "Formatting"
        case .unresolvedCharacter: "Characters"
        case .unresolvedLocation: "Locations"
        case .todo: "TODOs"
        case .healthReport: "Health"
        case .storage: "Storage"
        }
    }

    func matches(_ source: ReviewFindingSource) -> Bool {
        switch self {
        case .all: true
        case .formatting: source == .formatting
        case .unresolvedCharacter: source == .unresolvedCharacter
        case .unresolvedLocation: source == .unresolvedLocation
        case .todo: source == .todo
        case .healthReport: source == .healthReport
        case .storage: source == .storage
        }
    }
}

struct ReviewModeView: View {
    @Binding var document: ProjectDocumentViewModel
    let exportAction: () -> Void
    let openScriptAction: () -> Void

    @State private var showLayoutNumbering = false
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
                Label {
                    HStack(spacing: 4) { Text(report.sceneCount.formatted()); Text("scenes") }
                } icon: { Image(systemName: "rectangle.stack") }
                Label {
                    HStack(spacing: 4) { Text(report.findings.count.formatted()); Text("findings") }
                } icon: { Image(systemName: "exclamationmark.triangle") }
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
                Text(document.fountainExportText.isEmpty ? String(localized: "No script text yet.") : document.fountainExportText)
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
                                    .accessibilityLabel(finding.severity.localizedTitle)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(localizedTitle(for: finding))
                                            .font(.subheadline.bold())
                                        Text(finding.source.localizedTitle)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(localizedMessage(for: finding))
                                        .foregroundStyle(.secondary)
                                    if let action = localizedAction(for: finding) {
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
                    ForEach(ReviewSeverityFilter.allCases) { Text($0.localizedTitle).tag($0) }
                }
                .frame(width: 145)
                Picker("Source", selection: $sourceFilter) {
                    ForEach(ReviewSourceFilter.allCases) { Text($0.localizedTitle).tag($0) }
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
            HStack(spacing: 4) {
                Text("Showing")
                Text(filteredFindings.count.formatted())
                Text("of")
                Text(report.findings.count.formatted())
                Text("findings")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var filteredFindings: [ReviewFinding] {
        report.findings.filter { finding in
            guard severityFilter.matches(finding.severity), sourceFilter.matches(finding.source) else { return false }
            guard !normalizedSearch.isEmpty else { return true }
            let material = [
                localizedTitle(for: finding),
                localizedMessage(for: finding),
                localizedAction(for: finding) ?? "",
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

    private func localizedTitle(for finding: ReviewFinding) -> String {
        switch true {
        case finding.id.hasPrefix("finding-unresolved-character-"): String(localized: "Unresolved character")
        case finding.id.hasPrefix("finding-unresolved-location-"): String(localized: "Unresolved location")
        case finding.id.hasPrefix("finding-script-todo-"): String(localized: "Open script TODO")
        case finding.id.hasPrefix("finding-scene-missing-location-"): String(localized: "Scene heading missing location")
        case finding.id.hasPrefix("finding-scene-missing-time-"): String(localized: "Scene heading missing time of day")
        case finding.id.hasPrefix("finding-duplicate-scene-heading-"): String(localized: "Duplicate scene heading")
        case finding.id.hasPrefix("finding-character-without-dialogue-"): String(localized: "Character cue without dialogue")
        case finding.id.hasPrefix("finding-dialogue-without-character-"): String(localized: "Dialogue without a character cue")
        default: String(localized: String.LocalizationValue(finding.title))
        }
    }

    private func localizedMessage(for finding: ReviewFinding) -> String {
        switch true {
        case finding.id.hasPrefix("finding-unresolved-character-"):
            return String(format: String(localized: "%@ appears in the script but is not a character profile yet."), finding.message.components(separatedBy: " appears").first ?? finding.message)
        case finding.id.hasPrefix("finding-unresolved-location-"):
            return String(format: String(localized: "%@ appears in scene headings but is not a location profile yet."), finding.message.components(separatedBy: " appears").first ?? finding.message)
        case finding.id.hasPrefix("finding-scene-missing-location-"):
            return String(format: String(localized: "%@ does not include a clear location."), finding.message.components(separatedBy: " does not").first ?? finding.message)
        case finding.id.hasPrefix("finding-scene-missing-time-"):
            return String(format: String(localized: "%@ does not include a time of day."), finding.message.components(separatedBy: " does not").first ?? finding.message)
        case finding.id.hasPrefix("finding-duplicate-scene-heading-"):
            return String(format: String(localized: "%@ appears more than once."), finding.message.components(separatedBy: " appears").first ?? finding.message)
        case finding.id.hasPrefix("finding-character-without-dialogue-"):
            return String(format: String(localized: "%@ is not followed by dialogue."), finding.message.components(separatedBy: " is not").first ?? finding.message)
        case finding.id.hasPrefix("finding-dialogue-without-character-"):
            return String(localized: "A dialogue line appears without a clear speaker.")
        default:
            return String(localized: String.LocalizationValue(finding.message))
        }
    }

    private func localizedAction(for finding: ReviewFinding) -> String? {
        guard let action = finding.suggestedAction else { return nil }
        return String(localized: String.LocalizationValue(action))
    }

    private func navigationDescription(for finding: ReviewFinding) -> String {
        guard let type = finding.linkedEntityType else { return String(localized: "Project-level finding") }
        if let id = finding.linkedEntityID {
            return "\(type.localizedTitle): \(id)"
        }
        return type.localizedTitle
    }

    private func iconName(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .issue: "xmark.octagon"
        }
    }

    private func color(for severity: ReviewFindingSeverity) -> Color {
        switch severity {
        case .info: .secondary
        case .warning: .orange
        case .issue: .red
        }
    }
}

private extension ReviewFindingSeverity {
    var localizedTitle: String {
        switch self {
        case .info: String(localized: "Information")
        case .warning: String(localized: "Warning")
        case .issue: String(localized: "Issue")
        }
    }
}

private extension ReviewFindingSource {
    var localizedTitle: String {
        switch self {
        case .healthReport: String(localized: "Health")
        case .formatting: String(localized: "Formatting")
        case .unresolvedCharacter: String(localized: "Characters")
        case .unresolvedLocation: String(localized: "Locations")
        case .todo: String(localized: "TODOs")
        case .storage: String(localized: "Storage")
        }
    }
}

private extension ReviewLinkedEntityType {
    var localizedTitle: String {
        switch self {
        case .project: String(localized: "Project")
        case .scene: String(localized: "Scene")
        case .character: String(localized: "Character")
        case .location: String(localized: "Location")
        case .note: String(localized: "Note")
        case .screenplayElement: String(localized: "Script element")
        }
    }
}
