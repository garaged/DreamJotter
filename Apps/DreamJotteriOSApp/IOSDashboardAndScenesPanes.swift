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
    let project: DreamJotterProject
    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?

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
        }
        .searchable(text: $searchText, prompt: "Search scenes")
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
