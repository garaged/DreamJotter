import DreamJotterCore
import SwiftUI

struct NotesView: View {
    let notes: [ProjectNote]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

            if notes.isEmpty {
                Text("No notes yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(notes, id: \.id) { note in
                    VStack(alignment: .leading, spacing: 2) {
                        if let title = note.title {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                        }
                        Text(note.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }
    }
}
