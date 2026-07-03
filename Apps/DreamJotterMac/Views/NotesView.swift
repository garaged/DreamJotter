import DreamJotterCore
import SwiftUI

private struct NoteTargetOption: Identifiable, Hashable {
    let id: String
    let label: String
    let link: NoteLink

    static func options(for project: DreamJotterProject) -> [NoteTargetOption] {
        var values = [
            NoteTargetOption(
                id: token(kind: .project, targetID: project.metadata.id),
                label: "Project: \(project.metadata.title)",
                link: NoteLink(targetKind: .project, targetID: project.metadata.id)
            )
        ]

        values += project.screenplay.scenes.map { scene in
            NoteTargetOption(
                id: token(kind: .scene, targetID: scene.heading),
                label: "Scene: \(scene.heading)",
                link: NoteLink(targetKind: .scene, targetID: scene.heading)
            )
        }
        values += project.characters.map { character in
            NoteTargetOption(
                id: token(kind: .character, targetID: character.id),
                label: "Character: \(character.displayName)",
                link: NoteLink(targetKind: .character, targetID: character.id)
            )
        }
        values += project.locations.map { location in
            NoteTargetOption(
                id: token(kind: .location, targetID: location.id),
                label: "Location: \(location.displayName)",
                link: NoteLink(targetKind: .location, targetID: location.id)
            )
        }
        return values
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
    @State private var newNoteTargetID = ""
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
                    Picker("Target", selection: newNoteTargetBinding) {
                        ForEach(targetOptions) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                    Button("Add Note") {
                        guard let target = targetOptions.first(where: { $0.id == newNoteTargetBinding.wrappedValue }) else {
                            return
                        }
                        document.addNote(
                            title: noteTitle,
                            body: noteBody,
                            target: noteLinkTarget(for: target.link)
                        )
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
                    targetOptions: targetOptions,
                    isSelected: selectedNoteIDs.contains(note.id),
                    selectionChanged: { selected in
                        if selected {
                            selectedNoteIDs.insert(note.id)
                        } else {
                            selectedNoteIDs.remove(note.id)
                        }
                    },
                    updateAction: { title, text, link in
                        execute(.update, noteIDs: [note.id], title: title, body: text, links: [link])
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
                                Button("Open in Script") { navigateAction(target) }
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }

    private var targetOptions: [NoteTargetOption] {
        NoteTargetOption.options(for: document.project)
    }

    private var newNoteTargetBinding: Binding<String> {
        Binding(
            get: {
                if !newNoteTargetID.isEmpty, targetOptions.contains(where: { $0.id == newNoteTargetID }) {
                    return newNoteTargetID
                }
                return targetOptions.first?.id ?? ""
            },
            set: { newNoteTargetID = $0 }
        )
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
        links: [NoteLink]? = nil,
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
                links: links,
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

    private func noteLinkTarget(for link: NoteLink) -> NoteLinkTarget {
        switch link.targetKind {
        case .project:
            return .project
        case .scene:
            let scene = document.scenes.first { $0.heading == link.targetID } ?? document.scenes[0]
            return .scene(scene)
        case .character:
            let character = document.project.characters.first { $0.id == link.targetID } ?? document.project.characters[0]
            return .character(character)
        case .location:
            let location = document.project.locations.first { $0.id == link.targetID } ?? document.project.locations[0]
            return .location(location)
        case .screenplayElement:
            return .project
        }
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

    init(
        note: ProjectNote,
        project: DreamJotterProject,
        targetOptions: [NoteTargetOption],
        isSelected: Bool,
        selectionChanged: @escaping (Bool) -> Void,
        updateAction: @escaping (String, String, NoteLink) -> Void,
        resolveAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void,
        unlinkAction: @escaping () -> Void,
        navigateAction: @escaping (NoteLink) -> Void
    ) {
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
            Picker("Target", selection: $selectedTargetID) {
                ForEach(targetOptions) { option in
                    Text(option.label).tag(option.id)
                }
            }

            if let link = selectedLink {
                Button("Open \(link.targetKind.rawValue.capitalized)") {
                    navigateAction(link)
                }
                .font(.caption)
            } else if NotesWorkspace.hasOrphanedLinks(note, in: project) {
                Text("Current target is missing")
                    .font(.caption)
                    .foregroundStyle(.red)
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

            Text(note.status.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .confirmationDialog("Delete this note?", isPresented: $confirmDelete) {
            Button("Delete Note", role: .destructive) { deleteAction() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var selectedLink: NoteLink? {
        targetOptions.first { $0.id == selectedTargetID }?.link
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
