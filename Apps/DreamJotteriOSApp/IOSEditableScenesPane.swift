import DreamJotterCore
import SwiftUI

struct IOSEditableScenesPane: View {
    @Binding var project: DreamJotterProject
    let commitProjectChange: (DreamJotterProject) -> Void
    var navigateToScene: (SceneCard) -> Void = { _ in }
    @State private var selectedCard: SceneCard?

    var body: some View {
        List {
            ForEach(SceneWorkflow.cards(in: project), id: \.id) { card in
                Button {
                    selectedCard = card
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(card.order + 1). \(card.title)")
                            .font(.headline)
                        if !card.summary.isEmpty {
                            Text(card.summary).lineLimit(2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .leading) {
                    Button {
                        navigateToScene(card)
                    } label: {
                        Label("Open", systemImage: "text.cursor")
                    }
                    .tint(.blue)
                }
            }
            .onMove(perform: moveScenes)
        }
        .toolbar {
            EditButton()
            Button {
                applyPlanningOrder()
            } label: {
                Label("Apply Order", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .sheet(item: $selectedCard) { card in
            IOSSceneCardEditorSheet(card: card) { summary, note, status in
                saveCard(card, summary: summary, note: note, status: status)
            }
        }
    }

    private func applyPlanningOrder() {
        let headings = SceneWorkflow.cards(in: project).compactMap(\.sourceSceneHeading)
        let now = Date()
        let request = SceneWorkflowRequest(
            id: "ios-screenplay-reorder-\(UUID().uuidString)",
            action: .reorderScreenplay,
            orderedSceneHeadings: headings,
            confirmed: true,
            requestedAt: now
        )
        let execution = CommandEngine.execute(request, project: project, now: now)
        guard execution.project != project else { return }
        project = execution.project
        commitProjectChange(execution.project)
    }

    private func moveScenes(from source: IndexSet, to destination: Int) {
        var cards = SceneWorkflow.cards(in: project)
        cards.move(fromOffsets: source, toOffset: destination)
        let headings = cards.compactMap(\.sourceSceneHeading)
        let now = Date()
        let request = SceneWorkflowRequest(
            id: "ios-planning-reorder-\(UUID().uuidString)",
            action: .reorderPlanning,
            orderedSceneHeadings: headings,
            requestedAt: now
        )
        let execution = CommandEngine.execute(request, project: project, now: now)
        guard execution.project != project else { return }
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
