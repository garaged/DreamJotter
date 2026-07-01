import SwiftUI

struct ProjectWorkspaceView: View {
    @Binding var document: ProjectDocumentViewModel

    let saveAction: () -> Void
    let saveAsAction: () -> Void
    let openAction: () -> Void
    let exportAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        NavigationSplitView {
            List {
                Section("Scenes") {
                    SceneListView(scenes: document.scenes)
                }

                Section("Characters") {
                    CharacterListView(characters: document.characters)
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } content: {
            ScriptEditorView(document: $document)
                .navigationSplitViewColumnWidth(min: 520, ideal: 680)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ProjectDashboardView(snapshot: document.dashboard)
                    HealthReportView(findings: document.healthFindings)
                    NotesView(notes: document.notes)
                }
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 280, ideal: 340)
        }
        .toolbar {
            ToolbarItemGroup {
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
}
