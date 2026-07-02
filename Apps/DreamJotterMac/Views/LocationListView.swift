import DreamJotterCore
import SwiftUI

struct LocationListView: View {
    let locations: [LocationRecord]
    let unresolvedDetectedLocations: [DetectedLocation]
    let createAction: (String, String) -> Void
    let updateAction: (LocationRecord, String, String) -> Void
    let convertAction: (DetectedLocation) -> Void
    let ignoreAction: (DetectedLocation) -> Void
    @State private var newLocationName = ""
    @State private var newLocationNote = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Locations")
                .font(.headline)

            createProfileSection
            profilesSection
            detectedSection
        }
    }

    private var createProfileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Profile")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Location name", text: $newLocationName)
                .textFieldStyle(.roundedBorder)
            TextField("Notes", text: $newLocationNote, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            Button("Add Location") {
                createAction(newLocationName, newLocationNote)
                newLocationName = ""
                newLocationNote = ""
            }
            .disabled(newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @ViewBuilder
    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profiles")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            let profiles = locations.filter { $0.source != .detected }
            if profiles.isEmpty {
                Text("No location profiles yet. Add one here or convert a detected location from a scene heading.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(profiles, id: \.id) { location in
                    LocationProfileRow(location: location, updateAction: updateAction)
                }
            }
        }
    }

    @ViewBuilder
    private var detectedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detected in Scene Headings")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if unresolvedDetectedLocations.isEmpty {
                Text("No unresolved detected locations. Scene heading locations without profiles will appear here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(unresolvedDetectedLocations, id: \.id) { detection in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(detection.name)
                                .lineLimit(1)
                            Text("\(detection.sceneCount) scene\(detection.sceneCount == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Convert") {
                            convertAction(detection)
                        }

                        Button("Ignore") {
                            ignoreAction(detection)
                        }
                    }
                }
            }
        }
    }
}

private struct LocationProfileRow: View {
    let location: LocationRecord
    let updateAction: (LocationRecord, String, String) -> Void
    @State private var name: String
    @State private var note: String

    init(location: LocationRecord, updateAction: @escaping (LocationRecord, String, String) -> Void) {
        self.location = location
        self.updateAction = updateAction
        _name = State(initialValue: location.displayName)
        _note = State(initialValue: location.note)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Location name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Notes", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Button("Save Profile") {
                updateAction(location, name, note)
            }
            .disabled(!hasChanges || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.vertical, 4)
    }

    private var hasChanges: Bool {
        name != location.displayName || note != location.note
    }
}
