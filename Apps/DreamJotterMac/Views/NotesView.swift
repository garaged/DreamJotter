import DreamJotterCore
import SwiftUI

struct NotesView: View {
    @Binding var document: ProjectDocumentViewModel
    let navigateAction: (NoteLink) -> Void

    @State private var noteTitle = ""
    @State private var noteBody = ""
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
                    ForEach(NotesWorkspaceStateFilter.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                Picker("Target", selection: $targetFilter) {
                    ForEach(NotesWorkspaceTargetFilter.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
            }

            GroupBox("Add Manual Note") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: $noteTitle)
                    TextField("Body", text: $noteBody, axis: .vertical)
                    Button("Add Note") {
                        document.addNote(title: noteTitle, body: noteBody, target: .project)
                        noteTitle = ""
                        noteBody = ""
                    }
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
                    isSelected: selectedNoteIDs.contains(note.id),
                    selectionChanged: { selected in
                        if selected {
                            selectedNoteIDs.insert(note.id)
                        } else {
                            selectedNoteIDs.remove(note.id)
                        }
                    },
                    updateAction: { title, text in
                        execute(.update, noteIDs: [note.id], title: title, body: text)
                    },
                    resolveAction: {
                        execute(note.status == .open ? .resolve : .reopen, noteIDs: [note.id])
                    },
                    deleteAction: {
                        execute(.delete, noteIDs: [note.id], confirmed: true)
                    },
                    unlinkAction: {
                        execute(.unlinkOrphans, noteIDs: [note.id], confirmed: true)
                    },
                    navigateAction: navigateAction
                )
                Divider()
            }

            Text("Parsed Script TODOs").font(.subheadline.weight(.semibold))
            let todos = NotesWorkspace.unresolvedParsedTodos(
                in: document.project,
                now: document.project.metadata.modifiedAt
            )
            if todos.isEmpty {
                Text("No unresolved parsed TODOs.").foregroundStyle(.secondary)
            } else {
                ForEach(todos, id: \.id) { todo in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title ?? "Script TODO").font(.subheadline.weight(.semibold))
                        Text(todo.body).foregroundStyle(.secondary)
                        HStack {
                            Text("Derived from screenplay; edit the script to remove it.")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            if let target = NotesWorkspace.navigationTarget(for: todo, in: document.project) {
                                Button("Open in Script") {
                                    navigateAction(target)
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }

    private var filteredNotes: [ProjectNote] {
        NotesWorkspace.filteredNotes(
            in: document.project,
            query: NotesWorkspaceQuery(text: searchText, state: stateFilter, target: targetFilter)
        )
    }

    private func bulkResolve() {
        execute(.bulkResolve, noteIDs: Array(selectedNoteIDs), confirmed: true)
        selectedNoteIDs.removeAll()
    }

    private func execute(
        _ action: NoteWorkspaceCommandAction,
        noteIDs: [String],
        title: String? = nil,
        body: String? = nil,
        confirmed: Bool = false
    ) {
        let now = Date()
        let output = CommandEngine.execute(
            NoteWorkspaceCommandRequest(
                id: "notes-\(action.rawValue)-\(UUID().uuidString)",
                action: action,
                noteIDs: noteIDs,
                title: title,
                body: body,
                confirmed: confirmed,
                requestedAt: now
            ),
            project: document.project,
            now: now
        )
        guard output.result.status == .succeeded else { return }
        document = ProjectDocumentViewModel(
            project: output.project,
            packageURL: document.packageURL,
            scriptText: document.scriptText,
            isDirty: true
        )
    }
}

private struct NoteWorkspaceRow: View {
    let note: ProjectNote
    let project: DreamJotterProject
    let isSelected: Bool
    let selectionChanged: (Bool) -> Void
    let updateAction: (String, String) -> Void
    let resolveAction: () -> Void
    let deleteAction: () -> Void
    let unlinkAction: () -> Void
    let navigateAction: (NoteLink) -> Void

    @State private var title: String
    @State private var noteText: String
    @State private var confirmDelete = false

    init(
        note: ProjectNote,
        project: DreamJotterProject,
        isSelected: Bool,
        selectionChanged: @escaping (Bool) -> Void,
        updateAction: @escaping (String, String) -> Void,
        resolveAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        navigateAction: @escaping (NoteLink) -> Void
    ) {
        self.note = note
        self.project = project
        self.isSelected = isSelected
        self.selectionChanged = selectionChanged
        self.updateAction = updateAction
        self.resolveAction = resolveAction
        self.deleteAction = deleteAction
        self.unlinkAction = unlinkAction
        self.navigateAction = navigateAction
        _title = State(initialValue: note.title ?? "")
        _noteText = State(initialValue: note.body)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(
                "Select",
                isOn: Binding(
                    get: { isSelected },
                    set: { newValue in selectionChanged(newValue) }
                )
            )
            .toggleStyle(.checkbox)

            TextField("Title", text: $title)
            TextField("Body", text: $noteText, axis: .vertical)

            if !note.links.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(note.links.enumerated()), id: \.offset) { _, link in
                        if NotesWorkspace.orphanedLinks(for: note, in: project).contains(link) {
                            Text("Missing \(link.targetKind.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else {
                            Button("Open \(link.targetKind.rawValue.capitalized)") {
                                navigateAction(link)
                            }
                            .font(.caption)
                        }
                    }
                }
            }

            HStack {
                Button("Save") { updateAction(title, noteText) }
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button(note.status == .open ? "Resolve" : "Reopen") { resolveAction() }
                if NotesWorkspace.hasOrphanedLinks(note, in: project) {
                    Button("Unlink Missing Target") { unlinkAction() }
                }
                Spacer()
                Button("Delete", role: .destructive) { confirmDelete = true }
            }

            Text(note.status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .confirmationDialog("Delete this note?", isPresented: $confirmDelete) {
            Button("Delete Note", role: .destructive) { deleteAction() }
            Button("Cancel", role: .cancel) {}
        }
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
                ForEach(notes, id: \.id) { note in
                    Text(note.title ?? note.body).font(.subheadline)
                }
            }
        }
    }
}
