import DreamJotterCore
import SwiftUI

struct IOSNoteTargetEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let options: [IOSNoteTargetOption]
    let save: (String, String, [NoteLink]) -> Void

    @State private var title: String
    @State private var bodyText: String
    @State private var selectedTargetIDs: Set<String>

    init(
        note: ProjectNote?,
        options: [IOSNoteTargetOption],
        save: @escaping (String, String, [NoteLink]) -> Void
    ) {
        self.options = options
        self.save = save
        _title = State(initialValue: note?.title ?? "")
        _bodyText = State(initialValue: note?.body ?? "")
        let existing = Set((note?.links ?? []).map {
            "\($0.targetKind.rawValue):\($0.targetID)"
        })
        _selectedTargetIDs = State(initialValue: existing.isEmpty
            ? Set(options.prefix(1).map(\.id))
            : existing)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Title", text: $title)
                    TextField("Note", text: $bodyText, axis: .vertical)
                        .lineLimit(8...20)
                }

                Section("Linked Targets") {
                    ForEach(options) { option in
                        Button {
                            toggle(option.id)
                        } label: {
                            HStack {
                                Text(option.title)
                                Spacer()
                                if selectedTargetIDs.contains(option.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let links = options
                            .filter { selectedTargetIDs.contains($0.id) }
                            .map(\.link)
                        save(title, bodyText, links)
                        dismiss()
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func toggle(_ id: String) {
        if selectedTargetIDs.contains(id) {
            selectedTargetIDs.remove(id)
        } else {
            selectedTargetIDs.insert(id)
        }
    }
}
