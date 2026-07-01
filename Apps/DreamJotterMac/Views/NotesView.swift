import DreamJotterCore
import SwiftUI

struct NotesView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var noteTitle = ""
    @State private var noteBody = ""
    @State private var linkToFirstScene = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            TextField("Note title", text: $noteTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Write a project or scene note.", text: $noteBody, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)

            Toggle("Link to first scene", isOn: $linkToFirstScene)
                .disabled(document.scenes.isEmpty)

            Button("Add Note") {
                document.addNote(
                    title: noteTitle,
                    body: noteBody,
                    target: noteTarget
                )
                noteTitle = ""
                noteBody = ""
            }
            .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            NotesListView(notes: document.notes)
        }
    }

    private var noteTarget: NoteLinkTarget {
        if linkToFirstScene, let scene = document.scenes.first {
            return .scene(scene)
        }
        return .project
    }
}

struct NotesListView: View {
    let notes: [ProjectNote]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if notes.isEmpty {
                Text("No notes yet. Add a note above to capture project thoughts or link one to the first scene.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(notes, id: \.id) { note in
                    noteView(note)
                    Divider()
                }
            }
        }
    }

    private func noteView(_ note: ProjectNote) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let title = note.title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            Text(note.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let link = note.links.first {
                Text("\(link.targetKind.rawValue.capitalized): \(link.targetID)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
