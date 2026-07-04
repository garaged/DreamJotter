import DreamJotterCore
import SwiftUI

struct OptimizedReviewModeView: View {
    @Binding var document: ProjectDocumentViewModel
    let exportAction: () -> Void
    let openScriptAction: () -> Void

    @State private var report: ScriptHealthReport?
    @State private var layoutPlan: PDFLayoutPlan?
    @State private var isAnalyzing = false
    @State private var isPlanningLayout = false
    @State private var showLayoutNumbering = false
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                preview
                findings
            }
            .padding()
        }
        .task(id: document.derivedDataRevisionKey) { await loadReport() }
        .task(id: layoutTaskID) {
            if showLayoutNumbering { await loadLayout() }
            else { layoutPlan = nil; isPlanningLayout = false }
        }
    }

    private var layoutTaskID: String {
        let key = document.derivedDataRevisionKey
        return "\(key.projectID)-\(key.textRevision)-\(key.modifiedAt.timeIntervalSince1970)-\(showLayoutNumbering)"
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Review Mode").font(.title2.bold())
                    Text("Read-only review. Expensive analysis loads in the background.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Edit Script", action: openScriptAction)
                Button("Export Fountain", action: exportAction)
            }
            HStack(spacing: 14) {
                Label("\(report?.sceneCount ?? document.project.screenplay.scenes.count) scenes", systemImage: "rectangle.stack")
                Label("\(report?.findings.count ?? 0) findings", systemImage: "exclamationmark.triangle")
                Label("Read-only", systemImage: "lock")
                if isAnalyzing {
                    ProgressView().controlSize(.small)
                    Text("Analyzing…")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var preview: some View {
        let sample = LargeProjectPreview.make(from: document.scriptText)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Script Preview").font(.headline)
                Spacer()
                Toggle("Show layout numbering", isOn: $showLayoutNumbering)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }

            if showLayoutNumbering {
                if let layoutPlan {
                    SimplifiedReviewLayoutNumberingView(plan: layoutPlan)
                } else {
                    loadingRow(isPlanningLayout ? "Preparing numbered layout…" : "Layout unavailable")
                }
            } else {
                Text(sample.text.isEmpty ? String(localized: "No script text yet.") : sample.text)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                if sample.isTruncated {
                    HStack {
                        Text("Preview limited for performance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Open Full Script", action: openScriptAction)
                    }
                }
            }
        }
    }

    private var findings: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Review Findings").font(.headline)
                Spacer()
                TextField("Search findings", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 300)
            }

            if isAnalyzing, report == nil {
                loadingRow("Preparing findings in the background…")
            } else if filteredFindings.isEmpty {
                Text(report == nil ? "No findings available." : "No findings match the search.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredFindings, id: \.id) { finding in
                    Button {
                        open(finding)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: finding.severity == .issue ? "xmark.octagon" : "exclamationmark.triangle")
                            VStack(alignment: .leading, spacing: 3) {
                                Text(finding.title).font(.subheadline.bold())
                                Text(finding.message).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
    }

    private var filteredFindings: [ReviewFinding] {
        guard let findings = report?.findings else { return [] }
        let query = TextNormalization.key(for: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !query.isEmpty else { return findings }
        return findings.filter {
            TextNormalization.key(for: "\($0.title) \($0.message) \($0.suggestedAction ?? "")").contains(query)
        }
    }

    private func loadingRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            ProgressView().controlSize(.small)
            Text(text).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
    }

    private func loadReport() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.healthReport(for: key) {
            report = cached
            isAnalyzing = false
            return
        }
        isAnalyzing = true
        let project = document.project
        let lastSavedAt = document.packageURL == nil ? nil : project.metadata.modifiedAt
        let generated = await Task.detached(priority: .userInitiated) {
            ScriptHealthReportBuilder.report(for: project, lastSavedAt: lastSavedAt)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        report = generated
        isAnalyzing = false
    }

    private func loadLayout() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.layoutPlan(for: key) {
            layoutPlan = cached
            isPlanningLayout = false
            return
        }
        isPlanningLayout = true
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            ProjectDocumentViewModel.makeReviewPDFLayoutPlan(for: project)
        }.value
        guard !Task.isCancelled, showLayoutNumbering, document.derivedDataRevisionKey == key else { return }
        if let generated { LargeProjectDerivedDataCache.shared.store(generated, for: key) }
        layoutPlan = generated
        isPlanningLayout = false
    }

    private func open(_ finding: ReviewFinding) {
        document.selectReviewFinding(finding)
        openScriptAction()
    }
}
