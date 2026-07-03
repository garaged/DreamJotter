import DreamJotterCore
import SwiftUI

struct CharacterListView: View {
    let characters: [CharacterRecord]
    let unresolvedDetectedCharacters: [DetectedCharacter]
    let createAction: (String, String) -> Void
    let updateAction: (CharacterRecord, String, String) -> Void
    let deleteAction: (CharacterRecord) -> Void
    let convertAction: (DetectedCharacter) -> Void
    let ignoreAction: (DetectedCharacter) -> Void
    @State private var newCharacterName = ""
    @State private var newCharacterNote = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Characters").font(.headline)
            createProfileSection
            activeProfilesSection
            detectedCharactersSection
        }
    }

    private var createProfileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Profile").font(.subheadline).foregroundStyle(.secondary)
            TextField("Character name", text: $newCharacterName).textFieldStyle(.roundedBorder)
            TextField("Notes", text: $newCharacterNote, axis: .vertical).textFieldStyle(.roundedBorder)
            Button("Add Character") {
                createAction(newCharacterName, newCharacterNote)
                newCharacterName = ""
                newCharacterNote = ""
            }
            .disabled(newCharacterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @ViewBuilder
    private var activeProfilesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profiles").font(.subheadline).foregroundStyle(.secondary)
            let profiles = characters.filter { $0.source != .detected }
            if profiles.isEmpty {
                Text("No character profiles yet. Add one here or convert a detected character below.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(profiles, id: \.id) { character in
                    CharacterProfileRow(character: character, updateAction: updateAction, deleteAction: deleteAction)
                }
            }
        }
    }

    @ViewBuilder
    private var detectedCharactersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detected in Script").font(.subheadline).foregroundStyle(.secondary)
            if unresolvedDetectedCharacters.isEmpty {
                Text("No unresolved detected characters. Uppercase character cues without profiles will appear here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(unresolvedDetectedCharacters, id: \.id) { detection in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(detection.name).lineLimit(1)
                            Text("\(detection.occurrenceCount) appearance\(detection.occurrenceCount == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Convert") { convertAction(detection) }
                        Button("Ignore") { ignoreAction(detection) }
                    }
                }
            }
        }
    }
}

private struct CharacterProfileRow: View {
    let character: CharacterRecord
    let updateAction: (CharacterRecord, String, String) -> Void
    let deleteAction: (CharacterRecord) -> Void
    @State private var name: String
    @State private var note: String
    @State private var confirmRemoval = false

    init(character: CharacterRecord, updateAction: @escaping (CharacterRecord, String, String) -> Void, deleteAction: @escaping (CharacterRecord) -> Void) {
        self.character = character
        self.updateAction = updateAction
        self.deleteAction = deleteAction
        _name = State(initialValue: character.displayName)
        _note = State(initialValue: character.note)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Character name", text: $name).textFieldStyle(.roundedBorder)
            TextField("Notes", text: $note, axis: .vertical).textFieldStyle(.roundedBorder)
            HStack {
                Button("Save Profile") { updateAction(character, name, note) }
                    .disabled(!hasChanges || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
                Button("Delete", role: .destructive) { confirmRemoval = true }
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog("Delete \(character.displayName)?", isPresented: $confirmRemoval, titleVisibility: .visible) {
            Button("Delete Character", role: .destructive) { deleteAction(character) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("DreamJotter creates a snapshot first. The screenplay text remains unchanged.")
        }
    }

    private var hasChanges: Bool {
        name != character.displayName || note != character.note
    }
}
