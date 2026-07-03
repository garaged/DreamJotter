import DreamJotterCore
import SwiftUI

struct SceneListView: View {
    let sceneCards: [SceneCard]
    let selectedSceneID: String?
    let selectAction: (Int) -> Void
    let updateStatusAction: (SceneCard, SceneCardStatus) -> Void

    @State private var searchText = ""
    @State private var selectedStatus: SceneCardStatus?

    init(
        sceneCards: [SceneCard],
        selectedSceneID: String? = nil,
        selectAction: @escaping (Int) -> Void = { _ in },
        updateStatusAction: @escaping (SceneCard, SceneCardStatus) -> Void = { _, _ in }
    ) {
        self.sceneCards = sceneCards
        self.selectedSceneID = selectedSceneID
        self.selectAction = selectAction
        self.updateStatusAction = updateStatusAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Scenes").font(.headline)
            filterBar

            if filteredCards.isEmpty {
                Text(emptyMessage)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(filteredCards, id: \.id) { card in
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            selectAction(card.order)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(card.order + 1). \(card.title)")
                                        .lineLimit(2)
                                    Text([card.location, card.timeOfDay].compactMap { $0 }.joined(separator: " - "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if !card.characters.isEmpty {
                                        Text(card.characters.joined(separator: ", "))
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                                    .foregroundStyle(.secondary)
                                    .accessibilityLabel("Open in Script")
                            }
                            .padding(8)
                            .background(selectedSceneID == "scene-\(card.order + 1)" ? Color.accentColor.opacity(0.14) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)

                        Picker("Status", selection: statusBinding(for: card)) {
                            ForEach(SceneCardStatus.allCases, id: \.self) { status in
                                Text(status.sceneListLocalizedTitle).tag(status)
                            }
                        }
                        .labelsHidden()
                    }
                }
            }
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("Search scene title, location, time, or character", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Picker("Status", selection: $selectedStatus) {
                    Text("All statuses").tag(SceneCardStatus?.none)
                    ForEach(SceneCardStatus.allCases, id: \.self) { status in
                        Text(status.sceneListLocalizedTitle).tag(Optional(status))
                    }
                }
                .frame(width: 160)
                if !searchText.isEmpty || selectedStatus != nil {
                    Button("Clear") {
                        searchText = ""
                        selectedStatus = nil
                    }
                }
            }
            HStack(spacing: 4) {
                Text("Showing")
                Text(filteredCards.count.formatted())
                Text("of")
                Text(sceneCards.count.formatted())
                Text("scenes")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var emptyMessage: LocalizedStringKey {
        sceneCards.isEmpty
            ? "No scenes yet. Add a scene heading in the Script pane."
            : "No scenes match the current filters."
    }

    private var filteredCards: [SceneCard] {
        sceneCards.filter { card in
            let statusMatches = selectedStatus == nil || card.status == selectedStatus
            guard statusMatches else { return false }
            guard !normalizedSearch.isEmpty else { return true }
            let material = [
                card.title,
                card.location ?? "",
                card.timeOfDay ?? "",
                card.characters.joined(separator: " ")
            ].joined(separator: " ")
            return TextNormalization.key(for: material).contains(normalizedSearch)
        }
    }

    private var normalizedSearch: String {
        TextNormalization.key(for: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func statusBinding(for card: SceneCard) -> Binding<SceneCardStatus> {
        Binding(
            get: { card.status },
            set: { updateStatusAction(card, $0) }
        )
    }
}

private extension SceneCardStatus {
    var sceneListLocalizedTitle: LocalizedStringKey {
        switch self {
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
