import SwiftUI

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case script = "Script"
    case scenes = "Scenes"
    case characters = "Characters"
    case notes = "Notes"
    case healthReport = "Health Report"

    var id: String { rawValue }
}

struct ProjectWorkspaceView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var selectedSection: WorkspaceSection? = .dashboard

    let saveAction: () -> Void
    let saveAsAction: () -> Void
    let openAction: () -> Void
    let exportAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section("Project") {
                    ForEach(WorkspaceSection.allCases) { section in
                        Text(section.rawValue)
                            .tag(section)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } content: {
            contentView
                .navigationSplitViewColumnWidth(min: 520, ideal: 680)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ProjectDashboardView(document: $document)
                    HealthReportView(findings: document.healthFindings)
                    NotesListView(notes: document.notes)
                }
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 280, ideal: 340)
        }
        .toolbar {
            ToolbarItemGroup {
                Text(documentStatus)
                    .foregroundStyle(document.isDirty ? .orange : .secondary)

                Button("Library") {
                    closeAction()
                }

                Button("Open") {
                    openAction()
                }

                Button("Save") {
                    saveAction()
                }
                .keyboardShortcut("s", modifiers: [.command])

                Button("Save As") {
                    saveAsAction()
                }

                Button("Export Fountain") {
                    exportAction()
                }
            }
        }
    }

    private var documentStatus: String {
        if document.packageURL == nil {
            return document.isDirty ? "Unsaved changes" : "Unsaved project"
        }
        return document.isDirty ? "Unsaved changes" : "Saved"
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedSection ?? .dashboard {
        case .dashboard:
            ScrollView {
                ProjectDashboardView(document: $document)
                    .padding()
            }
        case .script:
            ScriptEditorView(document: $document)
        case .scenes:
            ScrollView {
                SceneListView(scenes: document.scenes)
                    .padding()
            }
        case .characters:
            ScrollView {
                CharacterListView(characters: document.characters)
                    .padding()
            }
        case .notes:
            ScrollView {
                NotesView(document: $document)
                    .padding()
            }
        case .healthReport:
            ScrollView {
                HealthReportView(findings: document.healthFindings)
                    .padding()
            }
        }
    }
}
