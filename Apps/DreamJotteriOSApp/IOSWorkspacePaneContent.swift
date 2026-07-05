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
            case .dashboard:
                IOSDashboardPane(project: $project, commitProjectChange: commitProjectChange)
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
            case .healthReport:
                IOSHealthReportPane(project: project)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct IOSDashboardPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    @State private var title = ""
    @State private var logline = ""
    @State private var synopsis = ""

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project title", text: $title)
                TextField("Add a one-sentence logline", text: $logline, axis: .vertical)
                    .lineLimit(2...4)
                TextField("Add a short synopsis", text: $synopsis, axis: .vertical)
                    .lineLimit(4...8)
                Button("Save Project Details", systemImage: "checkmark") {
                    apply(IOSWorkspaceProjectEditing.updatingDashboard(
                        project,
                        title: title,
                        logline: logline,
                        synopsis: synopsis
                    ))
                }
                .disabled(!hasChanges)
            }

            Section("Project Metrics") {
                LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                LabeledContent("Characters", value: "\(project.characters.count)")
                LabeledContent(
                    "Unresolved Characters",
                    value: "\(CharacterManager.unresolvedDetectedCharacters(for: project).count)"
                )
                LabeledContent("Locations", value: "\(project.locations.count)")
                LabeledContent(
                    "Unresolved Locations",
                    value: "\(LocationManager.unresolvedDetectedLocations(for: project).count)"
                )
                LabeledContent("Open Notes", value: "\(NotesIndex.openNotes(in: project).count)")
                LabeledContent("TODOs", value: "\(NotesIndex.detectedScriptTodos(in: project).count)")
            }
        }
        .onAppear(perform: reload)
        .onChange(of: project.metadata.modifiedAt) { _, _ in reload() }
    }

    private var hasChanges: Bool {
        title != project.metadata.title ||
        logline != (project.story.logline?.text ?? "") ||
        synopsis != (project.story.synopsis?.text ?? "")
    }

    private func reload() {
        title = project.metadata.title
        logline = project.story.logline?.text ?? ""
        synopsis = project.story.synopsis?.text ?? ""
    }

    private func apply(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}

private struct IOSScenesPane: View {
    let project: DreamJotterProject
    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?

    private var cards: [SceneCard] {
        SceneWorkflow.cards(in: project).filter { card in
            guard selectedStatus == nil || card.status == selectedStatus else { return false }
            let query = TextNormalization.key(for: searchText)
            guard !query.isEmpty else { return true }
            return TextNormalization.key(for: [
                card.title,
                card.location ?? "",
                card.timeOfDay ?? "",
                card.characters.joined(separator: " "),
                card.summary,
                card.note,
                card.plotlineTags.joined(separator: " ")
            ].joined(separator: " ")).contains(query)
        }
    }

    var body: some View {
        List {
            Picker("Status", selection: $selectedStatus) {
                Text("All").tag(SceneCardStatus?.none)
                ForEach(SceneCardStatus.allCases, id: \.self) { status in
                    Text(statusTitle(status)).tag(Optional(status))
                }
            }

            ForEach(cards, id: \.id) { card in
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(card.order + 1). \(card.title)").font(.headline)
                    HStack {
                        if let location = card.location { Text(location) }
                        if let time = card.timeOfDay { Text(time) }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    if !card.summary.isEmpty { Text(card.summary).lineLimit(3) }
                    if !card.note.isEmpty {
                        Label(card.note, systemImage: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !card.plotlineTags.isEmpty {
                        Text(card.plotlineTags.joined(separator: " • "))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 3)
            }
        }
        .searchable(text: $searchText, prompt: "Search scenes")
        .overlay {
            if cards.isEmpty {
                ContentUnavailableView("No Matching Scenes", systemImage: "rectangle.stack")
            }
        }
    }

    private func statusTitle(_ status: SceneCardStatus) -> String {
        switch status {
        case .idea: "Idea"
        case .outlined: "Outlined"
        case .drafted: "Drafted"
        case .needsRewrite: "Needs Rewrite"
        case .reviewed: "Reviewed"
        case .locked: "Locked"
        case .ready: "Ready"
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
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Character", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
            }

            Section("Profiles") {
                if project.characters.isEmpty {
                    Text("No character profiles yet.").foregroundStyle(.secondary)
                }
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
                        } label: { Label("Delete", systemImage: "trash") }
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
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Location", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
            }

            Section("Profiles") {
                if project.locations.isEmpty {
                    Text("No location profiles yet.").foregroundStyle(.secondary)
                }
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
                        } label: { Label("Delete", systemImage: "trash") }
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
            Section {
                Button {
                    editing = nil
                    showsEditor = true
                } label: {
                    Label("Create Note", systemImage: "plus.circle.fill")
                        .font(.headline)
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
                            if let link = note.links.first { Text("→ \(link.targetKind.rawValue)") }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
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
                    } label: { Label("Delete", systemImage: "trash") }
                }
            }
        }
        .overlay {
            if notes.isEmpty {
                ContentUnavailableView("No Notes", systemImage: "note.text")
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showsEditor) {
            IOSNoteEditorSheet(note: editing) { title, body in
                apply(IOSWorkspaceProjectEditing.upsertingNote(
                    project,
                    existing: editing,
                    title: title,
                    body: body
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

private struct IOSReviewPane: View {
    let project: DreamJotterProject
    let openFinding: (ReviewFinding) -> Void
    @State private var searchText = ""
    @State private var showsScript = true

    private var report: ScriptHealthReport {
        ScriptHealthReportBuilder.report(
            for: project,
            generatedAt: project.metadata.modifiedAt,
            lastSavedAt: project.metadata.modifiedAt
        )
    }

    private var findings: [ReviewFinding] {
        guard !searchText.isEmpty else { return report.findings }
        let key = TextNormalization.key(for: searchText)
        return report.findings.filter {
            TextNormalization.key(for: [$0.title, $0.message, $0.source.rawValue].joined(separator: " "))
                .contains(key)
        }
    }

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Scenes", value: "\(report.sceneCount)")
                LabeledContent("Elements", value: "\(report.elementCount)")
                LabeledContent("Findings", value: "\(report.findings.count)")
                Toggle("Show Screenplay Preview", isOn: $showsScript)
            }

            if showsScript {
                Section("Read-only Screenplay") {
                    Text(FountainIO.exportScreenplay(project.screenplay).isEmpty
                         ? "No script text yet."
                         : FountainIO.exportScreenplay(project.screenplay))
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Section("Review Findings") {
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
        }
        .searchable(text: $searchText, prompt: "Search findings")
    }

    private func icon(for severity: ReviewFindingSeverity) -> String {
        switch severity {
        case .info: "info.circle"
        case .warning: "exclamationmark.triangle"
        case .issue: "xmark.octagon"
        }
    }
}

private struct IOSHealthReportPane: View {
    let project: DreamJotterProject

    private var report: ScriptHealthReport {
        ScriptHealthReportBuilder.report(
            for: project,
            generatedAt: project.metadata.modifiedAt,
            lastSavedAt: project.metadata.modifiedAt
        )
    }

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Scenes", value: "\(report.sceneCount)")
                LabeledContent("Screenplay Elements", value: "\(report.elementCount)")
                LabeledContent("Character Profiles", value: "\(report.characterProfileCount)")
                LabeledContent("Unresolved Characters", value: "\(report.unresolvedDetectedCharacterCount)")
                LabeledContent("Location Profiles", value: "\(report.locationProfileCount)")
                LabeledContent("Unresolved Locations", value: "\(report.unresolvedDetectedLocationCount)")
                LabeledContent("Open Notes", value: "\(report.openNotesCount)")
                LabeledContent("TODOs", value: "\(report.todoCount)")
                LabeledContent("Dialogue / Action", value: report.dialogueActionRatio.formatted(.number.precision(.fractionLength(2))))
            }

            Section("Longest Scenes") {
                ForEach(report.longestScenes, id: \.sceneID) { scene in
                    LabeledContent(scene.heading, value: "\(scene.elementCount) elements")
                }
            }

            Section("Scenes Without Dialogue") {
                if report.scenesWithoutDialogue.isEmpty {
                    Text("Every scene contains dialogue.").foregroundStyle(.secondary)
                } else {
                    ForEach(report.scenesWithoutDialogue, id: \.sceneID) { scene in
                        Text(scene.heading)
                    }
                }
            }

            Section("Formatting Warnings") {
                if report.formattingWarnings.isEmpty {
                    Text("No formatting warnings.").foregroundStyle(.secondary)
                } else {
                    ForEach(report.formattingWarnings, id: \.id) { finding in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(finding.title).font(.headline)
                            Text(finding.message).foregroundStyle(.secondary)
                        }
                    }
                }
            }
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
                TextField("Notes", text: $note, axis: .vertical).lineLimit(4...10)
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
                TextField("Note", text: $bodyText, axis: .vertical).lineLimit(8...20)
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
