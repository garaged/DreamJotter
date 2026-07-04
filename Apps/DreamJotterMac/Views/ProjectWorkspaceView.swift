import DreamJotterCore
import SwiftUI

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case dashboard, script, scenes, characters, locations, notes, review, healthReport
    var id: String { rawValue }
    var localizedTitle: LocalizedStringKey {
        switch self {
        case .dashboard: "Dashboard"
        case .script: "Script"
        case .scenes: "Scenes"
        case .characters: "Characters"
        case .locations: "Locations"
        case .notes: "Notes"
        case .review: "Review"
        case .healthReport: "Health Report"
        }
    }
}

struct ProjectWorkspaceView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var selectedSection: WorkspaceSection? = .dashboard
    let saveAction: () -> Void
    let saveAsAction: () -> Void
    let openAction: () -> Void
    let exportAction: () -> Void
    let reviewExportAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section("Project") {
                    ForEach(WorkspaceSection.allCases) { section in
                        Text(section.localizedTitle).tag(section)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItemGroup {
                Text(documentStatus)
                    .foregroundStyle(document.isDirty ? .orange : .secondary)
                Button("Library") { closeAction() }
                Button("Open") { openAction() }
                Button("Save") { saveAction() }
                    .keyboardShortcut("s", modifiers: [.command])
                Button("Save As") { saveAsAction() }
                Button("Export") { exportAction() }
            }
        }
    }

    private var documentStatus: String {
        if document.packageURL == nil {
            return document.isDirty ? String(localized: "Unsaved changes") : String(localized: "Unsaved project")
        }
        return document.isDirty ? String(localized: "Unsaved changes") : String(localized: "Saved")
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedSection ?? .dashboard {
        case .dashboard:
            ScrollView { ProjectDashboardView(document: $document).padding() }
        case .script:
            HSplitView {
                ScriptEditorView(document: $document)
                    .frame(minWidth: 520, maxWidth: .infinity, maxHeight: .infinity)
                ScreenplayParagraphInspectorView(document: $document)
                    .frame(minWidth: 260, idealWidth: 300, maxWidth: 360, maxHeight: .infinity)
            }
        case .scenes:
            ScrollView {
                BoundSceneWorkflowView(document: $document, openScriptAction: { selectedSection = .script })
                    .padding()
            }
        case .characters:
            ScrollView {
                CharacterListView(
                    characters: document.project.characters,
                    unresolvedDetectedCharacters: document.unresolvedDetectedCharacters,
                    createAction: { name, note in document.createCharacterProfile(name: name, note: note) },
                    updateAction: { character, name, note in document.updateCharacterProfile(character, name: name, note: note) },
                    deleteAction: { character in document.removeStoredProfile(id: character.id, kind: .character) },
                    convertAction: { detection in document.convertDetectedCharacterToProfile(detection) },
                    ignoreAction: { detection in document.ignoreDetectedCharacter(detection) }
                ).padding()
            }
        case .locations:
            ScrollView {
                LocationListView(
                    locations: document.project.locations,
                    unresolvedDetectedLocations: document.unresolvedDetectedLocations,
                    createAction: { name, note in document.createLocationProfile(name: name, note: note) },
                    updateAction: { location, name, note in document.updateLocationProfile(location, name: name, note: note) },
                    deleteAction: { location in document.removeStoredProfile(id: location.id, kind: .location) },
                    convertAction: { detection in document.convertDetectedLocationToProfile(detection) },
                    ignoreAction: { detection in document.ignoreDetectedLocation(detection) }
                ).padding()
            }
        case .notes:
            ScrollView {
                NotesView(document: $document, navigateAction: navigateToNoteTarget).padding()
            }
        case .review:
            ReviewModeView(document: $document, exportAction: reviewExportAction, openScriptAction: { selectedSection = .script })
        case .healthReport:
            ScrollView { HealthReportView(findings: document.healthFindings).padding() }
        }
    }

    private func navigateToNoteTarget(_ link: NoteLink) {
        switch link.targetKind {
        case .project: selectedSection = .dashboard
        case .character: selectedSection = .characters
        case .location: selectedSection = .locations
        case .scene:
            if let sceneIndex = document.scenes.firstIndex(where: { $0.heading == link.targetID }) {
                document.requestNavigation(toSceneAt: sceneIndex)
            }
            selectedSection = .script
        case .screenplayElement:
            if let sceneIndex = owningSceneIndex(forElementID: link.targetID) {
                document.requestNavigation(toSceneAt: sceneIndex)
            }
            selectedSection = .script
        }
    }

    private func owningSceneIndex(forElementID elementID: String) -> Int? {
        guard elementID.hasPrefix("element-"),
              let oneBasedElementIndex = Int(elementID.dropFirst("element-".count)),
              oneBasedElementIndex > 0,
              oneBasedElementIndex <= document.project.screenplay.elements.count else { return nil }
        var sceneIndex: Int?
        for index in 0..<oneBasedElementIndex where document.project.screenplay.elements[index].kind == .sceneHeading {
            sceneIndex = (sceneIndex ?? -1) + 1
        }
        return sceneIndex
    }
}
