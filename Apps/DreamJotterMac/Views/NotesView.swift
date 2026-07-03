import DreamJotterCore
import SwiftUI

private struct NoteTargetOption: Identifiable {
    let id: String
    let label: String
    let link: NoteLink

    static func options(for project: DreamJotterProject) -> [NoteTargetOption] {
        var result = [NoteTargetOption(
            id: token(kind: .project, targetID: project.metadata.id),
            label: "Project: \(project.metadata.title)",
            link: NoteLink(targetKind: .project, targetID: project.metadata.id)
        )]
        result += project.screenplay.scenes.map {
            NoteTargetOption(id: token(kind: .scene, targetID: $0.heading), label: "Scene: \($0.heading)", link: NoteLink(targetKind: .scene, targetID: $0.heading))
        }
        result += project.characters.map {
            NoteTargetOption(id: token(kind: .character, targetID: $0.id), label: "Character: \($0.displayName)", link: NoteLink(targetKind: .character, targetID: $0.id))
        }
        result += project.locations.map {
            NoteTargetOption(id: token(kind: .location, targetID: $0.id), label: "Location: \($0.displayName)", link: NoteLink(targetKind: .location, targetID: $0.id))
        }
        return result
    }

    static func token(for link: NoteLink) -> String {
        token(kind: link.targetKind, targetID: link.targetID)
    }

    private static func token(kind: NoteTargetKind, targetID: String) -> String {
        "\(kind.rawValue)|\(targetID)"
    }
}

struct NotesView: View {
    @Binding var document: ProjectDocumentViewModel
    let navigateAction: (NoteLink) -> Void

    @State private var noteTitle = ""
    @State private var noteBody = ""
    @State private var newTargetID = ""
    @State private var searchText = ""
    @State private var stateFilter: NotesWorkspaceStateFilter = .all
    @State private var targetFilter: NotesWorkspaceTargetFilter = .all
    @State private var selectedNoteIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Notes and TODOs").font(.headline)

            HStack {
                TextField("Search notes", text: $searchText)
                Picker("State", selection: $stateFilter) {
                    ForEach(NotesWorkspaceStateFilter.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                Picker("Target", selection: $targetFilter) {
                    ForEach(NotesWorkspaceTargetFilter.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
            }

            GroupBox("Add Manual Note") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: $noteTitle)
                    TextField("Body", text: $noteBody, axis: .vertical)
                    Picker("Target", selection: newTargetBinding) {
                        ForEach(targetOptions) { Text($0.label).tag($0.id) }
                    }
                    Button("Add Note") { addNote() }
                        .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 4)
            }

            HStack {
                Text("Stored Notes").font(.subheadline.weight(.semibold))
                Spacer()
                Button("Resolve Selected") { bulkResolve() }
                    .disabled(selectedNoteIDs.isEmpty)
            }

            ForEach(filteredNotes, id: \.id) { note in
                NoteWorkspaceRow(
                    note: note,
                    project: document.project,
                    targetOptions: targetOptions,
                    isSelected: selectedNoteIDs.contains(note.id),
                    selectionChanged: { selected in
                        if selected { selectedNoteIDs.insert(note.id) } else { selectedNoteIDs.remove(note.id) }
                    },
                    updateAction: { title, text, link in
                        execute(.update, noteIDs: [note.id], title: title, body: text, links: [link])
                    },
                    resolveAction: { execute(note.status == .open ? .resolve : .reopen, noteIDs: [note.id]) },
                    deleteAction: { execute(.delete, noteIDs: [note.id], confirmed: true) },
                    unlinkAction: { execute(.unlinkOrphans, noteIDs: [note.id], confirmed: true) },
                    navigateAction: navigateAction
                )
                Divider()
            }

            Text("Parsed Script TODOs").font(.subheadline.weight(.semibold))
            let todos = NotesWorkspace.unresolvedParsedTodos(in: document.project, now: document.project.metadata.modifiedAt)
            if todos.isEmpty {
                Text("No unresolved parsed TODOs.").foregroundStyle(.secondary)
            } else {
                ForEach(todos, id: \.id) { todo in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title ?? "Script TODO").font(.subheadline.weight(.semibold))
                        Text(todo.body).foregroundStyle(.secondary)
                        if let target = NotesWorkspace.navigationTarget(for: todo, in: document.project) {
                            Button("Open in Script") { navigateAction(target) }.font(.caption)
                        }
                    }
                }
            }
        }
    }

    private var targetOptions: [NoteTargetOption] { NoteTargetOption.options(for: document.project) }

    private var newTargetBinding: Binding<String> {
        Binding(
            get: {
                targetOptions.contains(where: { $0.id == newTargetID }) ? newTargetID : (targetOptions.first?.id ?? "")
            },
            set: { newTargetID = $0 }
        )
    }

    private var filteredNotes: [ProjectNote] {
        NotesWorkspace.filteredNotes(in: document.project, query: NotesWorkspaceQuery(text: searchText, state: stateFilter, target: targetFilter))
    }

    private func addNote() {
        guard let option = targetOptions.first(where: { $0.id == newTargetBinding.wrappedValue }),
              let target = noteLinkTarget(for: option.link) else { return }
        document.addNote(title: noteTitle, body: noteBody, target: target)
        noteTitle = ""
        noteBody = ""
    }

    private func noteLinkTarget(for link: NoteLink) -> NoteLinkTarget? {
        switch link.targetKind {
        case .project:
            return .project
        case .scene:
            return document.scenes.first(where: { $0.heading == link.targetID }).map(NoteLinkTarget.scene)
        case .character:
            return document.project.characters.first(where: { $0.id == link.targetID }).map(NoteLinkTarget.character)
        case .location:
            return document.project.locations.first(where: { $0.id == link.targetID }).map(NoteLinkTarget.location)
        case .screenplayElement:
            return nil
        }
    }

    private func bulkResolve() {
        execute(.bulkResolve, noteIDs: Array(selectedNoteIDs), confirmed: true)
        selectedNoteIDs.removeAll()
    }

    private func execute(_ action: NoteWorkspaceCommandAction, noteIDs: [String], title: String? = nil, body: String? = nil, links: [NoteLink]? = nil, confirmed: Bool = false) {
        let now = Date()
        let output = CommandEngine.execute(
            NoteWorkspaceCommandRequest(id: "notes-\(action.rawValue)-\(UUID().uuidString)", action: action, noteIDs: noteIDs, title: title, body: body, links: links, confirmed: confirmed, requestedAt: now),
            project: document.project,
            now: now
        )
        guard output.result.status == .succeeded else { return }
        document = ProjectDocumentViewModel(project: output.project, packageURL: document.packageURL, scriptText: document.scriptText, isDirty: true)
    }
}

private struct NoteWorkspaceRow: View {
    let note: ProjectNote
    let project: DreamJotterProject
    let targetOptions: [NoteTargetOption]
    let isSelected: Bool
    let selectionChanged: (Bool) -> Void
    let updateAction: (String, String, NoteLink) -> Void
    let resolveAction: () -> Void
    let deleteAction: () -> Void
    let unlinkAction: () -> Void
    let navigateAction: (NoteLink) -> Void

    @State private var title: String
    @State private var noteText: String
    @State private var selectedTargetID: String
    @State private var confirmDelete = false

    init(note: ProjectNote, project: DreamJotterProject, targetOptions: [NoteTargetOption], isSelected: Bool, selectionChanged: @escaping (Bool) -> Void, updateAction: @escaping (String, String, NoteLink) -> Void, resolveAction: @escaping () -> Void, deleteAction: @escaping () -> Void, unlinkAction: @escaping () -> Void, navigateAction: @escaping (NoteLink) -> Void) {
        self.note = note
        self.project = project
        self.targetOptions = targetOptions
        self.isSelected = isSelected
        self.selectionChanged = selectionChanged
        self.updateAction = updateAction
        self.resolveAction = resolveAction
        self.deleteAction = deleteAction
        self.unlinkAction = unlinkAction
        self.navigateAction = navigateAction
        _title = State(initialValue: note.title ?? "")
        _noteText = State(initialValue: note.body)
        _selectedTargetID = State(initialValue: note.links.first.map(NoteTargetOption.token(for:)) ?? targetOptions.first?.id ?? "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Select", isOn: Binding(get: { isSelected }, set: { selectionChanged($0) }))
                .toggleStyle(.checkbox)
            TextField("Title", text: $title)
            TextField("Body", text: $noteText, axis: .vertical)
            Picker("Target", selection: $selectedTargetID) {
                ForEach(targetOptions) { Text($0.label).tag($0.id) }
            }

            if let link = selectedLink {
                Button("Open \(link.targetKind.rawValue.capitalized)") { navigateAction(link) }
                    .font(.caption)
            } else if NotesWorkspace.hasOrphanedLinks(note, in: project) {
                Text("Current target is missing").font(.caption).foregroundStyle(.red)
            }

            HStack {
                Button("Save") {
                    guard let link = selectedLink else { return }
                    updateAction(title, noteText, link)
                }
                .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedLink == nil)
                Button(note.status == .open ? "Resolve" : "Reopen") { resolveAction() }
                if NotesWorkspace.hasOrphanedLinks(note, in: project) {
                    Button("Unlink Missing Target") { unlinkAction() }
                }
                Spacer()
                Button("Delete", role: .destructive) { confirmDelete = true }
            }
            Text(note.status.rawValue.capitalized).font(.caption).foregroundStyle(.secondary)
        }
        .confirmationDialog("Delete this note?", isPresented: $confirmDelete) {
            Button("Delete Note", role: .destructive) { deleteAction() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var selectedLink: NoteLink? {
        targetOptions.first(where: { $0.id == selectedTargetID })?.link
    }
}

struct NotesListView: View {
    let notes: [ProjectNote]
    let resolveAction: (ProjectNote) -> Void

    init(notes: [ProjectNote], resolveAction: @escaping (ProjectNote) -> Void = { _ in }) {
        self.notes = notes
        self.resolveAction = resolveAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if notes.isEmpty {
                Text("No notes yet.").foregroundStyle(.secondary)
            } else {
                ForEach(notes, id: \.id) { Text($0.title ?? $0.body).font(.subheadline) }
            }
        }
    }
}
