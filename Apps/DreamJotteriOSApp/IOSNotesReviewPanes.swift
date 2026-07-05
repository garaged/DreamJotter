import DreamJotterCore
import SwiftUI

struct IOSNotesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: ProjectNote?
    @State private var showsEditor = false
    @State private var status: ProjectNoteStatus? = .open

    private var notes: [ProjectNote] {
        project.notes.filter { status == nil || $0.status == status }
    }

    var body: some View {
        List {
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Note", systemImage: "plus.circle.fill").font(.headline)
                }
            }

            Picker("Status", selection: $status) {
                Text("All").tag(ProjectNoteStatus?.none)
                Text("Open").tag(ProjectNoteStatus?.some(.open))
                Text("Resolved").tag(ProjectNoteStatus?.some(.resolved))
                Text("Archived").tag(ProjectNoteStatus?.some(.archived))
            }
            .pickerStyle(.segmented)

            ForEach(notes, id: \.id) { note in
                Button {
                    editing = note
                    showsEditor = true
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title ?? "Untitled Note").font(.headline)
                        Text(note.body).lineLimit(3)
                    }
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .leading) {
                    Button {
                        apply(IOSWorkspaceProjectEditing.settingNoteStatus(
                            project,
                            note: note,
                            status: note.status == .resolved ? .open : .resolved
                        ))
                    } label: {
                        Label(note.status == .resolved ? "Reopen" : "Resolve", systemImage: "checkmark.circle")
                    }
                    .tint(.green)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        apply(IOSWorkspaceProjectEditing.removingNote(project, id: note.id))
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSNoteEditorSheet(note: editing) { title, body in
                apply(IOSWorkspaceProjectEditing.upsertingNote(
                    project,
                    existing: editing,
                    title: title,
                    body: body
                ))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

struct IOSReviewPane: View {
    let project: DreamJotterProject
    let openFinding: (ReviewFinding) -> Void
    @State private var searchText = ""
    @State private var showsScript = true

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
        VStack(spacing: 0) {
            List {
                Section("Summary") {
                    LabeledContent("Scenes", value: "\(report.sceneCount)")
                    LabeledContent("Elements", value: "\(report.elementCount)")
                    LabeledContent("Findings", value: "\(report.findings.count)")
                    Toggle("Show Screenplay Preview", isOn: $showsScript)
                }
            }
            .frame(maxHeight: 230)

            if showsScript {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Read-only Screenplay")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    IOSReadOnlyScreenplayPreview(text: screenplayText)
                        .frame(minHeight: 220, maxHeight: .infinity)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
            }

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
            .frame(minHeight: 180)
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
