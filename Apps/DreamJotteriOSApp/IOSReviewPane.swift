import DreamJotterCore
import SwiftUI

private enum IOSReviewSection: String, CaseIterable, Identifiable {
    case screenplay
    case findings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .screenplay: "Screenplay"
        case .findings: "Findings"
        }
    }
}

private enum IOSReviewSeverityFilter: String, CaseIterable, Identifiable {
    case all
    case info
    case warning
    case issue

    var id: String { rawValue }

    var title: String {
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

private enum IOSReviewSourceFilter: String, CaseIterable, Identifiable {
    case all
    case formatting
    case unresolvedCharacter
    case unresolvedLocation
    case todo
    case healthReport
    case storage

    var id: String { rawValue }

    var title: String {
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

struct IOSReviewPane: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let project: DreamJotterProject
    let openFinding: (ReviewFinding) -> Void

    @State private var searchText = ""
    @State private var selectedSection: IOSReviewSection = .screenplay
    @State private var severityFilter: IOSReviewSeverityFilter = .all
    @State private var sourceFilter: IOSReviewSourceFilter = .all
    @State private var showLayoutNumbering = false

    private var report: ScriptHealthReport {
        ScriptHealthReportBuilder.report(
            for: project,
            generatedAt: project.metadata.modifiedAt,
            lastSavedAt: project.metadata.modifiedAt
        )
    }

    private var screenplayText: String {
        FountainIO.exportScreenplay(project.screenplay)
    }

    private var numberedScreenplayText: String {
        screenplayText
            .components(separatedBy: "\n")
            .enumerated()
            .map { index, line in
                String(format: "%4d  %@", index + 1, line)
            }
            .joined(separator: "\n")
    }

    private var findings: [ReviewFinding] {
        let key = TextNormalization.key(for: searchText)
        return report.findings.filter { finding in
            guard severityFilter.matches(finding.severity),
                  sourceFilter.matches(finding.source) else { return false }
            guard !key.isEmpty else { return true }
            return TextNormalization.key(for: [
                finding.title,
                finding.message,
                finding.suggestedAction ?? "",
                finding.source.rawValue,
                finding.linkedEntityID ?? ""
            ].joined(separator: " ")).contains(key)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let usesSplitLayout = horizontalSizeClass == .regular && proxy.size.width >= 700

            VStack(spacing: 0) {
                compactSummary

                if usesSplitLayout {
                    regularReviewLayout
                } else {
                    compactReviewLayout
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var compactSummary: some View {
        HStack(spacing: 16) {
            metric(value: report.sceneCount, label: "Scenes")
            metric(value: report.elementCount, label: "Elements")
            metric(value: findings.count, label: "Findings")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func metric(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value.formatted())
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var compactReviewLayout: some View {
        VStack(spacing: 0) {
            Picker("Review section", selection: $selectedSection) {
                ForEach(IOSReviewSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Group {
                switch selectedSection {
                case .screenplay:
                    screenplayPane
                case .findings:
                    findingsPane
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var regularReviewLayout: some View {
        HStack(spacing: 0) {
            screenplayPane
                .frame(minWidth: 420, maxWidth: .infinity)

            Divider()

            findingsPane
                .frame(minWidth: 280, idealWidth: 340, maxWidth: 380)
        }
    }

    private var screenplayPane: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Read-only Screenplay")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("Show layout numbering", isOn: $showLayoutNumbering)
                    .labelsHidden()
                    .accessibilityLabel("Show layout numbering")
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)

            IOSReadOnlyScreenplayPreview(
                text: showLayoutNumbering ? numberedScreenplayText : screenplayText
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var findingsPane: some View {
        List {
            Section("Filters") {
                Picker("Severity", selection: $severityFilter) {
                    ForEach(IOSReviewSeverityFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                Picker("Source", selection: $sourceFilter) {
                    ForEach(IOSReviewSourceFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                if !searchText.isEmpty || severityFilter != .all || sourceFilter != .all {
                    Button("Clear Filters") {
                        searchText = ""
                        severityFilter = .all
                        sourceFilter = .all
                    }
                }
            }

            Section("Review Findings") {
                ForEach(findings, id: \.id) { finding in
                    Button {
                        openFinding(finding)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: icon(for: finding.severity))
                                Text(finding.title).font(.headline)
                                Spacer()
                                Text(finding.source.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(finding.message).foregroundStyle(.secondary)
                            if let action = finding.suggestedAction {
                                Text(action).font(.caption)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search findings")
        .overlay {
            if findings.isEmpty {
                ContentUnavailableView("No Findings", systemImage: "checkmark.circle")
            }
        }
    }

    private func icon(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .issue: "xmark.octagon"
        }
    }
}
