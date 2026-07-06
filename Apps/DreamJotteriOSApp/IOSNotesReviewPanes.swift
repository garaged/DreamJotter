import DreamJotterCore
import SwiftUI

struct IOSNotesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    var navigateToLink: (NoteLink) -> Void = { _ in }
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
                HStack(alignment: .top) {
                    Button {
                        editing = note
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title ?? "Untitled Note").font(.headline)
                            Text(note.body).lineLimit(3)
                            if !note.links.isEmpty {
                                Text("\(note.links.count) linked target\(note.links.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    if !note.links.isEmpty {
                        Menu {
                            ForEach(Array(note.links.enumerated()), id: \.offset) { _, link in
                                Button(targetTitle(link)) {
                                    navigateToLink(link)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.forward.app")
                        }
                        .accessibilityLabel("Open linked target")
                    }
                }
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
            IOSNoteTargetEditorSheet(
                note: editing,
                options: IOSNoteTargetOption.options(for: project)
            ) { title, body, links in
                if let editing {
                    apply(IOSNoteLinkEditing.update(
                        project: project,
                        note: editing,
                        title: title,
                        body: body,
                        links: links
                    ))
                } else {
                    apply(IOSWorkspaceProjectEditing.upsertingNote(
                        project,
                        existing: nil,
                        title: title,
                        body: body,
                        links: links
                    ))
                }
            }
        }
    }

    private func targetTitle(_ link: NoteLink) -> String {
        IOSNoteTargetOption.options(for: project)
            .first(where: { $0.id == "\(link.targetKind.rawValue):\(link.targetID)" })?
            .title ?? link.targetID
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}
