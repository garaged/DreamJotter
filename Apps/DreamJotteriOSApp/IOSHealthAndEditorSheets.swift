import DreamJotterCore
import SwiftUI

struct IOSHealthReportPane: View {
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
                LabeledContent("Location Profiles", value: "\(report.locationProfileCount)")
                LabeledContent("Open Notes", value: "\(report.openNotesCount)")
                LabeledContent("TODOs", value: "\(report.todoCount)")
            }

            Section("Longest Scenes") {
                ForEach(report.longestScenes, id: \.sceneID) { scene in
                    LabeledContent(scene.heading, value: "\(scene.elementCount) elements")
                }
            }

            Section("Formatting Warnings") {
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

struct IOSRecordEditorSheet: View {
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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

struct IOSNoteEditorSheet: View {
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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
