import DreamJotterCore
import DreamJotteriOS
import SwiftUI

struct IOSAutocompletePanel: View {
    let state: IOSAutocompleteState
    let accept: (EditorSuggestion) -> Void
    let dismiss: () -> Void

    var body: some View {
        if state.isPresented {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Suggestions")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Button("Dismiss", action: dismiss)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(state.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            Button {
                                accept(suggestion)
                            } label: {
                                Text(suggestion.displayText)
                                    .font(.body.monospaced())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(
                                        index == state.selectedIndex
                                            ? Color.accentColor.opacity(0.18)
                                            : Color.secondary.opacity(0.08)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .accessibilityLabel("Accept suggestion: \(suggestion.displayText)")
                            .accessibilityValue(index == state.selectedIndex ? "Selected" : "")
                        }
                    }
                }

                Text("Use arrow keys to select, Return or Tab to accept, and Escape to dismiss.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.thinMaterial)
        }
    }
}
