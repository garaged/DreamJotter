import SwiftUI

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case script = "Script"
    case scenes = "Scenes"
    case characters = "Characters"
    case locations = "Locations"
    case notes = "Notes"
    case review = "Review"
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
                SceneListView(
                    sceneCards: document.sceneCards,
                    selectedSceneID: document.editorNavigationState.selectedSceneID,
                    selectAction: { index in
                        document.requestNavigation(toSceneAt: index)
                        selectedSection = .script
                    },
                    updateStatusAction: { card, status in
                        if let heading = card.sourceSceneHeading {
                            document.updateSceneStatus(sceneHeading: heading, status: status)
                        }
                    }
                )
                    .padding()
            }
        case .characters:
            ScrollView {
                CharacterListView(
                    characters: document.characters,
                    unresolvedDetectedCharacters: document.unresolvedDetectedCharacters,
                    createAction: { name, note in
                        document.createCharacterProfile(name: name, note: note)
                    },
                    updateAction: { character, name, note in
                        document.updateCharacterProfile(character, name: name, note: note)
                    },
                    convertAction: { detection in
                        document.convertDetectedCharacterToProfile(detection)
                    },
                    ignoreAction: { detection in
                        document.ignoreDetectedCharacter(detection)
                    }
                )
                    .padding()
            }
        case .locations:
            ScrollView {
                LocationListView(
                    locations: document.locations,
                    unresolvedDetectedLocations: document.unresolvedDetectedLocations,
                    createAction: { name, note in
                        document.createLocationProfile(name: name, note: note)
                    },
                    updateAction: { location, name, note in
                        document.updateLocationProfile(location, name: name, note: note)
                    },
                    convertAction: { detection in
                        document.convertDetectedLocationToProfile(detection)
                    },
                    ignoreAction: { detection in
                        document.ignoreDetectedLocation(detection)
                    }
                )
                    .padding()
            }
        case .notes:
            ScrollView {
                NotesView(document: $document)
                    .padding()
            }
        case .review:
            ReviewModeView(
                document: $document,
                exportAction: exportAction,
                openScriptAction: {
                    selectedSection = .script
                }
            )
        case .healthReport:
            ScrollView {
                HealthReportView(findings: document.healthFindings)
                    .padding()
            }
        }
    }
}
