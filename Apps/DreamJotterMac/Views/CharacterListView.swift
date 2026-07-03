import DreamJotterCore
import SwiftUI

private enum CharacterListScope: String, CaseIterable, Identifiable {
    case all
    case profiles
    case detected

    var id: String { rawValue }

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .profiles: "Profiles"
        case .detected: "Detected"
        }
    }
}

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
    @State private var searchText = ""
    @State private var scope: CharacterListScope = .all

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Characters").font(.headline)
            filterBar
            createProfileSection
            if scope != .detected { activeProfilesSection }
            if scope != .profiles { detectedCharactersSection }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("Search character names and notes", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Picker("Scope", selection: $scope) {
                    ForEach(CharacterListScope.allCases) { Text($0.localizedTitle).tag($0) }
                }
                .frame(width: 130)
                if !searchText.isEmpty {
                    Button("Clear") { searchText = "" }
                }
            }
            HStack(spacing: 4) {
                Text("Profiles")
                Text(filteredProfiles.count.formatted())
                Text("Detected")
                Text(filteredDetections.count.formatted())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
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
            if filteredProfiles.isEmpty {
                Text(searchText.isEmpty ? "No character profiles yet." : "No character profiles match the search.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredProfiles, id: \.id) { character in
                    CharacterProfileRow(character: character, updateAction: updateAction, deleteAction: deleteAction)
                }
            }
        }
    }

    @ViewBuilder
    private var detectedCharactersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detected in Script").font(.subheadline).foregroundStyle(.secondary)
            if filteredDetections.isEmpty {
                Text(searchText.isEmpty ? "No unresolved detected characters." : "No detected characters match the search.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredDetections, id: \.id) { detection in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(detection.name).lineLimit(1)
                            HStack(spacing: 4) {
                                Text(detection.occurrenceCount.formatted())
                                Text(detection.occurrenceCount == 1 ? "appearance" : "appearances")
                            }
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

    private var filteredProfiles: [CharacterRecord] {
        let profiles = characters.filter { $0.source != .detected }
        guard !normalizedSearch.isEmpty else { return profiles }
        return profiles.filter {
            TextNormalization.key(for: "\($0.displayName) \($0.note)").contains(normalizedSearch)
        }
    }

    private var filteredDetections: [DetectedCharacter] {
        guard !normalizedSearch.isEmpty else { return unresolvedDetectedCharacters }
        return unresolvedDetectedCharacters.filter {
            TextNormalization.key(for: $0.name).contains(normalizedSearch)
        }
    }

    private var normalizedSearch: String {
        TextNormalization.key(for: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
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
