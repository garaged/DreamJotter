import DreamJotterCore
import SwiftUI

struct IOSCharactersPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: CharacterRecord?
    @State private var showsEditor = false

    private var unresolved: [DetectedCharacter] {
        CharacterManager.unresolvedDetectedCharacters(for: project)
    }

    var body: some View {
        List {
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Character", systemImage: "plus.circle.fill").font(.headline)
                }
            }

            Section("Profiles") {
                ForEach(project.characters, id: \.id) { character in
                    Button {
                        editing = character
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(character.displayName).font(.headline)
                            if !character.note.isEmpty {
                                Text(character.note).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            apply(IOSWorkspaceProjectEditing.removingCharacter(project, id: character.id))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            if !unresolved.isEmpty {
                Section("Detected in Screenplay") {
                    ForEach(unresolved, id: \.id) { detection in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(detection.name).font(.headline)
                                Spacer()
                                Text("\(detection.occurrenceCount)").foregroundStyle(.secondary)
                            }
                            HStack {
                                Button("Create Profile") {
                                    apply(CharacterManager.convertDetectedCharacter(
                                        named: detection.name,
                                        in: project,
                                        now: Date()
                                    ))
                                }
                                Button("Ignore", role: .destructive) {
                                    apply(CharacterManager.ignoreDetectedCharacter(
                                        named: detection.name,
                                        in: project,
                                        now: Date()
                                    ))
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSRecordEditorSheet(
                title: editing == nil ? "New Character" : "Edit Character",
                initialName: editing?.displayName ?? "",
                initialNote: editing?.note ?? ""
            ) { name, note in
                apply(IOSWorkspaceProjectEditing.upsertingCharacter(
                    project,
                    existing: editing,
                    name: name,
                    note: note
                ))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

struct IOSLocationsPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: LocationRecord?
    @State private var showsEditor = false

    private var unresolved: [DetectedLocation] {
        LocationManager.unresolvedDetectedLocations(for: project)
    }

    var body: some View {
        List {
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Location", systemImage: "plus.circle.fill").font(.headline)
                }
            }

            Section("Profiles") {
                ForEach(project.locations, id: \.id) { location in
                    Button {
                        editing = location
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(location.displayName).font(.headline)
                            if !location.note.isEmpty {
                                Text(location.note).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            apply(IOSWorkspaceProjectEditing.removingLocation(project, id: location.id))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            if !unresolved.isEmpty {
                Section("Detected in Screenplay") {
                    ForEach(unresolved, id: \.id) { detection in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(detection.name).font(.headline)
                                Spacer()
                                Text("\(detection.sceneCount) scenes").foregroundStyle(.secondary)
                            }
                            HStack {
                                Button("Create Profile") {
                                    apply(LocationManager.convertDetectedLocation(
                                        named: detection.name,
                                        in: project,
                                        now: Date()
                                    ))
                                }
                                Button("Ignore", role: .destructive) {
                                    apply(LocationManager.ignoreDetectedLocation(
                                        named: detection.name,
                                        in: project,
                                        now: Date()
                                    ))
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSRecordEditorSheet(
                title: editing == nil ? "New Location" : "Edit Location",
                initialName: editing?.displayName ?? "",
                initialNote: editing?.note ?? ""
            ) { name, note in
                apply(IOSWorkspaceProjectEditing.upsertingLocation(
                    project,
                    existing: editing,
                    name: name,
                    note: note
                ))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}
