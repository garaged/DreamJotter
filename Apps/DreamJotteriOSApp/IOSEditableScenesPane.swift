import DreamJotterCore
import DreamJotteriOS
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    var navigateToScene: (SceneCard) -> Void = { _ in }

    @State private var selectedCard: SceneCard?
    @State private var showsEditor = false
    @State private var confirmsScreenplayReorder = false

    var body: some View {
        List {
            ForEach(SceneWorkflow.cards(in: project), id: \.id) { card in
                HStack {
                    Button {
                        selectedCard = card
                        showsEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(card.order + 1). \(card.title)")
                                .font(.headline)
                            if !card.summary.isEmpty {
                                Text(card.summary).lineLimit(2)
                            }
                            Text(card.status.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        navigateToScene(card)
                    } label: {
                        Image(systemName: "text.cursor")
                    }
                    .accessibilityLabel("Open \(card.title) in screenplay")
                }
            }
            .onMove(perform: moveScenes)
        }
        .toolbar {
            EditButton()
            Button {
                confirmsScreenplayReorder = true
            } label: {
                Label("Apply Order", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .sheet(isPresented: $showsEditor) {
            if let card = selectedCard {
                IOSPersistentSceneCardEditorSheet(card: card) { summary, note, status in
                    saveCard(card, summary: summary, note: note, status: status)
                }
            }
        }
        .confirmationDialog(
            "Apply planning order to screenplay?",
            isPresented: $confirmsScreenplayReorder,
            titleVisibility: .visible
        ) {
            Button("Apply Order") { applyPlanningOrder() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("DreamJotter creates a recovery snapshot before reordering complete scene blocks.")
        }
    }

    private func moveScenes(from source: IndexSet, to destination: Int) {
        var cards = SceneWorkflow.cards(in: project)
        cards.move(fromOffsets: source, toOffset: destination)
        executeReorder(
            action: .reorderPlanning,
            headings: cards.compactMap(\.sourceSceneHeading),
            confirmed: false
        )
    }

    private func applyPlanningOrder() {
        executeReorder(
            action: .reorderScreenplay,
            headings: SceneWorkflow.cards(in: project).compactMap(\.sourceSceneHeading),
            confirmed: true
        )
    }

    private func executeReorder(
        action: SceneWorkflowAction,
        headings: [String],
        confirmed: Bool
    ) {
        let now = Date()
        let request = SceneWorkflowRequest(
            id: "ios-scene-reorder-\(UUID().uuidString)",
            action: action,
            orderedSceneHeadings: headings,
            confirmed: confirmed,
            requestedAt: now
        )
        let execution = CommandEngine.execute(request, project: project, now: now)
        guard execution.project != project else { return }
        if action == .reorderScreenplay {
            IOSExternalScreenplayReplacementStore.stage(
                FountainIO.exportScreenplay(execution.project.screenplay)
            )
        }
        project = execution.project
        commitProjectChange(execution.project)
    }

    private func saveCard(
        _ card: SceneCard,
        summary: String,
        note: String,
        status: SceneCardStatus
    ) {
        let updated = IOSSceneCardEditing.update(
            project: project,
            card: card,
            summary: summary,
            note: note,
            status: status,
            plotlineTags: card.plotlineTags
        )
        guard updated != project else { return }
        project = updated
        commitProjectChange(updated)
    }
}
