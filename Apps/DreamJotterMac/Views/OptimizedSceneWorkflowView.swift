import DreamJotterCore
import SwiftUI

struct OptimizedSceneWorkflowView: View {
    @Binding var document: ProjectDocumentViewModel
    let openScriptAction: () -> Void

    @State private var cards: [SceneCard] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?
    @State private var confirmReorder = false

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scenes").font(.headline)
                Spacer()
                if isLoading { ProgressView().controlSize(.small) }
                Button("Apply Planning Order to Script") { confirmReorder = true }
                    .disabled(cards.count < 2)
            }

            HStack {
                TextField("Search title, location, character, summary, note, or tag", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Picker("Status", selection: $selectedStatus) {
                    Text("All statuses").tag(SceneCardStatus?.none)
                    ForEach(SceneCardStatus.allCases, id: \.self) { status in
                        Text(statusTitle(status)).tag(Optional(status))
                    }
                }
                .frame(width: 160)
                Text("\(filteredCards.count) of \(cards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if isLoading, cards.isEmpty {
                HStack(spacing: 10) {
                    ProgressView().controlSize(.small)
                    Text("Preparing scene cards in the background…")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            } else if filteredCards.isEmpty {
                Text(cards.isEmpty ? "No scenes yet. Add a scene heading in the Script pane." : "No scenes match the current filters.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredCards, id: \.id) { card in
                    OptimizedSceneCardRow(
                        card: card,
                        isSelected: selectedSceneID(for: card) == document.editorNavigationState.selectedSceneID,
                        openAction: { open(card) },
                        saveAction: { summary, note, status, tags in
                            document.updateSceneCard(card, summary: summary, note: note, status: status, tags: tags)
                        }
                    )
                }
            }
        }
        .task(id: document.derivedDataRevisionKey) { await loadCards() }
        .confirmationDialog("Reorder screenplay scenes?", isPresented: $confirmReorder) {
            Button("Reorder Scenes") {
                document.reorderScreenplayScenes(cards.compactMap(\.sourceSceneHeading))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("DreamJotter creates a snapshot first, then moves complete screenplay scene blocks to match the planning order.")
        }
    }

    private var filteredCards: [SceneCard] {
        let query = TextNormalization.key(for: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        return cards.filter { card in
            guard selectedStatus == nil || card.status == selectedStatus else { return false }
            guard !query.isEmpty else { return true }
            let material = [
                card.title,
                card.location ?? "",
                card.timeOfDay ?? "",
                card.characters.joined(separator: " "),
                card.summary,
                card.note,
                card.plotlineTags.joined(separator: " ")
            ].joined(separator: " ")
            return TextNormalization.key(for: material).contains(query)
        }
    }

    private func loadCards() async {
        let key = document.derivedDataRevisionKey
        if let cached = LargeProjectDerivedDataCache.shared.sceneCards(for: key) {
            cards = cached
            isLoading = false
            return
        }
        isLoading = true
        let project = document.project
        let generated = await Task.detached(priority: .userInitiated) {
            SceneWorkflow.cards(in: project)
        }.value
        guard !Task.isCancelled, document.derivedDataRevisionKey == key else { return }
        LargeProjectDerivedDataCache.shared.store(generated, for: key)
        cards = generated
        isLoading = false
    }

    private func open(_ card: SceneCard) {
        guard let heading = card.sourceSceneHeading,
              let index = document.project.screenplay.scenes.firstIndex(where: { $0.heading == heading }) else { return }
        document.requestNavigation(toSceneAt: index)
        openScriptAction()
    }

    private func selectedSceneID(for card: SceneCard) -> String? {
        guard let heading = card.sourceSceneHeading,
              let index = document.project.screenplay.scenes.firstIndex(where: { $0.heading == heading }) else { return nil }
        return "scene-\(index + 1)"
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

private struct OptimizedSceneCardRow: View {
    let card: SceneCard
    let isSelected: Bool
    let openAction: () -> Void
    let saveAction: (String, String, SceneCardStatus, [String]) -> Void

    @State private var summary: String
    @State private var note: String
    @State private var status: SceneCardStatus
    @State private var tagsText: String

    init(card: SceneCard, isSelected: Bool, openAction: @escaping () -> Void, saveAction: @escaping (String, String, SceneCardStatus, [String]) -> Void) {
        self.card = card
        self.isSelected = isSelected
        self.openAction = openAction
        self.saveAction = saveAction
        _summary = State(initialValue: card.summary)
        _note = State(initialValue: card.note)
        _status = State(initialValue: card.status)
        _tagsText = State(initialValue: card.plotlineTags.joined(separator: ", "))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("\(card.order + 1). \(card.title)", action: openAction)
                    .buttonStyle(.plain)
                    .font(.subheadline.bold())
                Spacer()
                Button("Open in Script", action: openAction)
            }
            TextField("Scene summary", text: $summary, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            TextField("Scene notes", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            HStack {
                Picker("Status", selection: $status) {
                    ForEach(SceneCardStatus.allCases, id: \.self) { value in
                        Text(String(describing: value)).tag(value)
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
        tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private var hasChanges: Bool {
        summary != card.summary || note != card.note || status != card.status || parsedTags != card.plotlineTags
    }
}
