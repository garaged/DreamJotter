import DreamJotterCore
import SwiftUI

struct IOSDashboardPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var title = ""
    @State private var logline = ""
    @State private var synopsis = ""

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project title", text: $title)
                TextField("Add a one-sentence logline", text: $logline, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Add a short synopsis", text: $synopsis, axis: .vertical)
                    .lineLimit(4...8)
                Button("Save Project Details", systemImage: "checkmark") {
                    apply(IOSWorkspaceProjectEditing.updatingDashboard(
                        project,
                        title: title,
                        logline: logline,
                        synopsis: synopsis
                    ))
                }
                .disabled(!hasChanges)
            }

            Section("Project Metrics") {
                LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                LabeledContent("Characters", value: "\(project.characters.count)")
                LabeledContent("Locations", value: "\(project.locations.count)")
                LabeledContent("Open Notes", value: "\(NotesIndex.openNotes(in: project).count)")
                LabeledContent("TODOs", value: "\(NotesIndex.detectedScriptTodos(in: project).count)")
            }
        }
        .onAppear(perform: reload)
        .onChange(of: project.metadata.modifiedAt) { _, _ in reload() }
    }

    private var hasChanges: Bool {
        title != project.metadata.title ||
        logline != (project.story.logline?.text ?? "") ||
        synopsis != (project.story.synopsis?.text ?? "")
    }

    private func reload() {
        title = project.metadata.title
        logline = project.story.logline?.text ?? ""
        synopsis = project.story.synopsis?.text ?? ""
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

struct IOSScenesPane: View {
    @State private var project: DreamJotterProject
    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?
    @State private var editingCard: SceneCard?
    @State private var showsEditor = false

    init(project: DreamJotterProject) {
        _project = State(initialValue: project)
    }

    private var cards: [SceneCard] {
        SceneWorkflow.cards(in: project).filter { card in
            guard selectedStatus == nil || card.status == selectedStatus else { return false }
            let query = TextNormalization.key(for: searchText)
            guard !query.isEmpty else { return true }
            return TextNormalization.key(for: [
                card.title,
                card.location ?? "",
                card.timeOfDay ?? "",
                card.summary,
                card.note,
                card.plotlineTags.joined(separator: " ")
            ].joined(separator: " ")).contains(query)
        }
    }

    var body: some View {
        List {
            Picker("Status", selection: $selectedStatus) {
                Text("All").tag(SceneCardStatus?.none)
                ForEach(SceneCardStatus.allCases, id: \.self) { status in
                    Text(statusTitle(status)).tag(Optional(status))
                }
            }

            ForEach(cards, id: \.id) { card in
                Button {
                    editingCard = card
                    showsEditor = true
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(card.order + 1). \(card.title)").font(.headline)
                        HStack {
                            if let location = card.location { Text(location) }
                            if let time = card.timeOfDay { Text(time) }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        if !card.summary.isEmpty { Text(card.summary).lineLimit(3) }
                        if !card.note.isEmpty {
                            Label(card.note, systemImage: "note.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 3)
                }
                .buttonStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search scenes")
        .sheet(isPresented: $showsEditor) {
            if let card = editingCard {
                IOSSceneCardEditorSheet(card: card) { summary, note, status, tags in
                    project = IOSSceneCardEditing.update(
                        project: project,
                        card: card,
                        summary: summary,
                        note: note,
                        status: status,
                        plotlineTags: tags
                    )
                }
            }
        }
    }

    private func statusTitle(_ status: SceneCardStatus) -> String {
        switch status {
        case .idea: "Idea"
        case .outlined: "Outlined"
        case .drafted: "Drafted"
        case .needsRewrite: "Needs Rewrite"
        case .reviewed: "Reviewed"
        case .locked: "Locked"
        case .ready: "Ready"
        }
    }
}

private struct IOSSceneCardEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let card: SceneCard
    let save: (String, String, SceneCardStatus, [String]) -> Void
    @State private var summary: String
    @State private var note: String
    @State private var status: SceneCardStatus
    @State private var tagsText: String

    init(card: SceneCard, save: @escaping (String, String, SceneCardStatus, [String]) -> Void) {
        self.card = card
        self.save = save
        _summary = State(initialValue: card.summary)
        _note = State(initialValue: card.note)
        _status = State(initialValue: card.status)
        _tagsText = State(initialValue: card.plotlineTags.joined(separator: ", "))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Scene") {
                    Text(card.title).font(.headline)
                }
                Section("Planning") {
                    Picker("Status", selection: $status) {
                        ForEach(SceneCardStatus.allCases, id: \.self) { value in
                            Text(value.rawValue).tag(value)
                        }
                    }
                    TextField("Summary", text: $summary, axis: .vertical)
                        .lineLimit(4...10)
                    TextField("Scene note", text: $note, axis: .vertical)
                        .lineLimit(4...10)
                    TextField("Plotline tags, comma separated", text: $tagsText)
                }
            }
            .navigationTitle("Edit Scene Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save(summary, note, status, tagsText.split(separator: ",").map(String.init))
                        dismiss()
                    }
                }
            }
        }
    }
}
