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

struct IOSReviewPane: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let project: DreamJotterProject
    let openFinding: (ReviewFinding) -> Void

    @State private var searchText = ""
    @State private var selectedSection: IOSReviewSection = .screenplay

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

    private var findings: [ReviewFinding] {
        guard !searchText.isEmpty else { return report.findings }
        let key = TextNormalization.key(for: searchText)
        return report.findings.filter {
            TextNormalization.key(for: [$0.title, $0.message, $0.source.rawValue].joined(separator: " "))
                .contains(key)
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
            metric(value: report.findings.count, label: "Findings")
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
            Text("Read-only Screenplay")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 10)

            IOSReadOnlyScreenplayPreview(text: screenplayText)
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
