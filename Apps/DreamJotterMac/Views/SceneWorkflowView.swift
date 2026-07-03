import DreamJotterCore
import SwiftUI

struct SceneWorkflowView: View {
    let project: DreamJotterProject
    let selectedSceneID: String?
    let selectAction: (SceneCard) -> Void
    let updateAction: (SceneCard, String, String, SceneCardStatus, [String]) -> Void
    let planningReorderAction: ([String]) -> Void
    let screenplayReorderAction: ([String]) -> Void

    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?
    @State private var selectedTag = ""
    @State private var confirmScreenplayReorder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scenes").font(.headline)
                Spacer()
                Button("Apply Planning Order to Script") {
                    confirmScreenplayReorder = true
                }
                .disabled(cards.count < 2 || screenplayPreview.isEmpty)
            }

            filterBar

            if filteredCards.isEmpty {
                Text(cards.isEmpty ? "No scenes yet. Add a scene heading in the Script pane." : "No scenes match the current filters.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredCards, id: \.id) { card in
                    SceneWorkflowCardRow(
                        card: card,
                        isSelected: selectedSceneID == screenplaySceneID(for: card),
                        canMoveUp: planningIndex(for: card) > 0,
                        canMoveDown: planningIndex(for: card) < cards.count - 1,
                        openAction: { selectAction(card) },
                        saveAction: { summary, note, status, tags in
                            updateAction(card, summary, note, status, tags)
                        },
                        moveUpAction: { move(card, offset: -1) },
                        moveDownAction: { move(card, offset: 1) }
                    )
                }
            }
        }
        .confirmationDialog(
            "Reorder screenplay scenes?",
            isPresented: $confirmScreenplayReorder,
            titleVisibility: .visible
        ) {
            Button("Reorder \(screenplayPreview.count) Scene\(screenplayPreview.count == 1 ? "" : "s")") {
                screenplayReorderAction(orderedHeadings)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("DreamJotter creates a snapshot first, then moves complete screenplay scene blocks to match the planning order.")
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("Search title, location, character, summary, note, or tag", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Picker("Status", selection: $selectedStatus) {
                    Text("All statuses").tag(SceneCardStatus?.none)
                    ForEach(SceneCardStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(Optional(status))
                    }
                }
                .frame(width: 160)
                Picker("Plotline", selection: $selectedTag) {
                    Text("All plotlines").tag("")
                    ForEach(allTags, id: \.self) { tag in
                        Text(tag).tag(tag)
                    }
                }
                .frame(width: 160)
                if filtersAreActive {
                    Button("Clear") {
                        searchText = ""
                        selectedStatus = nil
                        selectedTag = ""
                    }
                }
            }
            Text("Showing \(filteredCards.count) of \(cards.count) scenes in planning order")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var cards: [SceneCard] {
        SceneWorkflow.cards(in: project)
    }

    private var filteredCards: [SceneCard] {
        SceneWorkflow.filteredCards(
            in: project,
            query: SceneWorkflowQuery(
                text: searchText,
                status: selectedStatus,
                plotlineTag: selectedTag.isEmpty ? nil : selectedTag
            )
        )
    }

    private var allTags: [String] {
        var values: [String] = []
        var keys: Set<String> = []
        for tag in cards.flatMap(\.plotlineTags) {
            let key = TextNormalization.key(for: tag)
            if keys.insert(key).inserted { values.append(tag) }
        }
        return values.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var orderedHeadings: [String] {
        cards.compactMap(\.sourceSceneHeading)
    }

    private var screenplayPreview: [String] {
        SceneWorkflow.screenplayReorderPreview(orderedSceneHeadings: orderedHeadings, in: project)
    }

    private var filtersAreActive: Bool {
        !searchText.isEmpty || selectedStatus != nil || !selectedTag.isEmpty
    }

    private func planningIndex(for card: SceneCard) -> Int {
        cards.firstIndex(where: { $0.id == card.id }) ?? 0
    }

    private func move(_ card: SceneCard, offset: Int) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        let destination = index + offset
        guard cards.indices.contains(destination) else { return }
        var headings = orderedHeadings
        headings.swapAt(index, destination)
        planningReorderAction(headings)
    }

    private func screenplaySceneID(for card: SceneCard) -> String? {
        guard let heading = card.sourceSceneHeading,
              let index = project.screenplay.scenes.firstIndex(where: { $0.heading == heading }) else {
            return nil
        }
        return "scene-\(index + 1)"
    }
}

private struct SceneWorkflowCardRow: View {
    let card: SceneCard
    let isSelected: Bool
    let canMoveUp: Bool
    let canMoveDown: Bool
    let openAction: () -> Void
    let saveAction: (String, String, SceneCardStatus, [String]) -> Void
    let moveUpAction: () -> Void
    let moveDownAction: () -> Void

    @State private var summary: String
    @State private var note: String
    @State private var status: SceneCardStatus
    @State private var tagsText: String

    init(card: SceneCard, isSelected: Bool, canMoveUp: Bool, canMoveDown: Bool, openAction: @escaping () -> Void, saveAction: @escaping (String, String, SceneCardStatus, [String]) -> Void, moveUpAction: @escaping () -> Void, moveDownAction: @escaping () -> Void) {
        self.card = card
        self.isSelected = isSelected
        self.canMoveUp = canMoveUp
        self.canMoveDown = canMoveDown
        self.openAction = openAction
        self.saveAction = saveAction
        self.moveUpAction = moveUpAction
        self.moveDownAction = moveDownAction
        _summary = State(initialValue: card.summary)
        _note = State(initialValue: card.note)
        _status = State(initialValue: card.status)
        _tagsText = State(initialValue: card.plotlineTags.joined(separator: ", "))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Button(action: openAction) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(card.order + 1). \(card.title)")
                            .font(.subheadline.weight(.semibold))
                        Text([card.location, card.timeOfDay].compactMap { $0 }.joined(separator: " - "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !card.characters.isEmpty {
                            Text(card.characters.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: moveUpAction) { Image(systemName: "arrow.up") }
                    .disabled(!canMoveUp)
                    .help("Move earlier in planning order")
                Button(action: moveDownAction) { Image(systemName: "arrow.down") }
                    .disabled(!canMoveDown)
                    .help("Move later in planning order")
                Button("Open in Script", action: openAction)
            }

            TextField("Scene summary", text: $summary, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            TextField("Scene notes", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            HStack {
                Picker("Status", selection: $status) {
                    ForEach(SceneCardStatus.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                TextField("Plotline tags, comma separated", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
                Button("Save Scene Card") {
                    saveAction(summary, note, status, parsedTags)
                }
                .disabled(!hasChanges)
            }
        }
        .padding(10)
        .background(isSelected ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var parsedTags: [String] {
        tagsText.split(separator: ",").map(String.init)
    }

    private var hasChanges: Bool {
        summary != card.summary
            || note != card.note
            || status != card.status
            || parsedTags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } != card.plotlineTags
    }
}
