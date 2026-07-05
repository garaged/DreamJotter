import DreamJotterCore
import SwiftUI

struct IOSWorkspacePaneContent: View {
    let pane: IOSWorkspacePane
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    let openReviewFinding: (ReviewFinding) -> Void

    var body: some View {
        Group {
            switch pane {
            case .screenplay:
                EmptyView()
            case .scenes:
                IOSScenesPane(project: project)
            case .characters:
                IOSCharactersPane(project: $project, commitProjectChange: commitProjectChange)
            case .locations:
                IOSLocationsPane(project: $project, commitProjectChange: commitProjectChange)
            case .notes:
                IOSNotesPane(project: $project, commitProjectChange: commitProjectChange)
            case .review:
                IOSReviewPane(project: project, openFinding: openReviewFinding)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct IOSScenesPane: View {
    let project: DreamJotterProject

    var body: some View {
        List(Array(project.screenplay.scenes.enumerated()), id: \.offset) { index, scene in
            VStack(alignment: .leading, spacing: 3) {
                Text(scene.heading)
                    .font(.headline)
                HStack {
                    Text("Scene \(index + 1)")
                    if !scene.location.isEmpty { Text(scene.location) }
                    if let timeOfDay = scene.timeOfDay, !timeOfDay.isEmpty { Text(timeOfDay) }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 3)
        }
        .overlay {
            if project.screenplay.scenes.isEmpty {
                ContentUnavailableView("No Scenes", systemImage: "rectangle.stack")
            }
        }
    }
}

private struct IOSCharactersPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: CharacterRecord?
    @State private var showsEditor = false

    private var unresolved: [DetectedCharacter] {
        CharacterManager.unresolvedDetectedCharacters(for: project)
    }

    var body: some View {
        List {
            Section("Profiles") {
                ForEach(project.characters, id: \.id) { character in
                    Button {
                        editing = character
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(character.displayName).font(.headline)
                            if !character.note.isEmpty {
                                Text(character.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
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
                                Text("\(detection.occurrenceCount)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Button("Create Profile") {
                                    apply(CharacterManager.convertDetectedCharacter(named: detection.name, in: project, now: Date()))
                                }
                                Button("Ignore", role: .destructive) {
                                    apply(CharacterManager.ignoreDetectedCharacter(named: detection.name, in: project, now: Date()))
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .toolbar {
            Button {
                editing = nil
                showsEditor = true
            } label: {
                Label("Add Character", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSRecordEditorSheet(
                title: editing == nil ? "New Character" : "Edit Character",
                initialName: editing?.displayName ?? "",
                initialNote: editing?.note ?? ""
            ) { name, note in
                apply(IOSWorkspaceProjectEditing.upsertingCharacter(project, existing: editing, name: name, note: note))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

private struct IOSLocationsPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: LocationRecord?
    @State private var showsEditor = false

    private var unresolved: [DetectedLocation] {
        LocationManager.unresolvedDetectedLocations(for: project)
    }

    var body: some View {
        List {
            Section("Profiles") {
                ForEach(project.locations, id: \.id) { location in
                    Button {
                        editing = location
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(location.displayName).font(.headline)
                            if !location.note.isEmpty {
                                Text(location.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
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
                                Text("\(detection.sceneCount) scenes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Button("Create Profile") {
                                    apply(LocationManager.convertDetectedLocation(named: detection.name, in: project, now: Date()))
                                }
                                Button("Ignore", role: .destructive) {
                                    apply(LocationManager.ignoreDetectedLocation(named: detection.name, in: project, now: Date()))
                                }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .toolbar {
            Button {
                editing = nil
                showsEditor = true
            } label: {
                Label("Add Location", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSRecordEditorSheet(
                title: editing == nil ? "New Location" : "Edit Location",
                initialName: editing?.displayName ?? "",
                initialNote: editing?.note ?? ""
            ) { name, note in
                apply(IOSWorkspaceProjectEditing.upsertingLocation(project, existing: editing, name: name, note: note))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

private struct IOSNotesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var editing: ProjectNote?
    @State private var showsEditor = false
    @State private var status: ProjectNoteStatus? = .open

    private var notes: [ProjectNote] {
        project.notes.filter { status == nil || $0.status == status }
    }

    var body: some View {
        List {
            Picker("Status", selection: $status) {
                Text("All").tag(ProjectNoteStatus?.none)
                Text("Open").tag(ProjectNoteStatus?.some(.open))
                Text("Resolved").tag(ProjectNoteStatus?.some(.resolved))
                Text("Archived").tag(ProjectNoteStatus?.some(.archived))
            }
            .pickerStyle(.segmented)

            ForEach(notes, id: \.id) { note in
                Button {
                    editing = note
                    showsEditor = true
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title ?? "Untitled Note").font(.headline)
                        Text(note.body).lineLimit(3)
                        HStack {
                            Text(note.status.rawValue.capitalized)
                            Text(note.source.rawValue)
                            if let link = note.links.first {
                                Text("→ \(link.targetKind.rawValue)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .leading) {
                    Button {
                        let next: ProjectNoteStatus = note.status == .resolved ? .open : .resolved
                        apply(IOSWorkspaceProjectEditing.settingNoteStatus(project, note: note, status: next))
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
        .overlay {
            if notes.isEmpty {
                ContentUnavailableView("No Notes", systemImage: "note.text")
            }
        }
        .toolbar {
            Button {
                editing = nil
                showsEditor = true
            } label: {
                Label("Add Note", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSNoteEditorSheet(note: editing) { title, body in
                apply(IOSWorkspaceProjectEditing.upsertingNote(project, existing: editing, title: title, body: body))
            }
        }
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

private struct IOSReviewPane: View {
    let project: DreamJotterProject
    let openFinding: (ReviewFinding) -> Void
    @State private var searchText = ""

    private var report: ScriptHealthReport {
        ScriptHealthReportBuilder.report(for: project, generatedAt: Date(), lastSavedAt: project.metadata.modifiedAt)
    }

    private var findings: [ReviewFinding] {
        guard !searchText.isEmpty else { return report.findings }
        let key = TextNormalization.key(for: searchText)
        return report.findings.filter {
            TextNormalization.key(for: [$0.title, $0.message, $0.source.rawValue].joined(separator: " ")).contains(key)
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Label("\(report.sceneCount) scenes", systemImage: "rectangle.stack")
                    Spacer()
                    Label("\(report.findings.count) findings", systemImage: "exclamationmark.triangle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            ForEach(findings, id: \.id) { finding in
                Button {
                    openFinding(finding)
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: icon(for: finding.severity))
                            Text(finding.title).font(.headline)
                            Spacer()
                            Text(finding.source.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(finding.message).foregroundStyle(.secondary)
                        if let action = finding.suggestedAction {
                            Text(action).font(.caption)
                        }
                    }
                    .padding(.vertical, 3)
                }
                .buttonStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search findings")
        .overlay {
            if findings.isEmpty {
                ContentUnavailableView("No Findings", systemImage: "checkmark.circle")
            }
        }
    }

    private func icon(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .issue: "xmark.octagon"
        }
    }
}

private struct IOSRecordEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let save: (String, String) -> Void
    @State private var name: String
    @State private var note: String

    init(title: String, initialName: String, initialNote: String, save: @escaping (String, String) -> Void) {
        self.title = title
        self.save = save
        _name = State(initialValue: initialName)
        _note = State(initialValue: initialNote)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Notes", text: $note, axis: .vertical)
                    .lineLimit(4...10)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save(name, note)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct IOSNoteEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let save: (String, String) -> Void
    @State private var title: String
    @State private var bodyText: String

    init(note: ProjectNote?, save: @escaping (String, String) -> Void) {
        self.save = save
        _title = State(initialValue: note?.title ?? "")
        _bodyText = State(initialValue: note?.body ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Note", text: $bodyText, axis: .vertical)
                    .lineLimit(8...20)
            }
            .navigationTitle("Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save(title, bodyText)
                        dismiss()
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
