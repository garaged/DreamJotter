import DreamJotterCore
import DreamJotteriOS
import SwiftUI

struct IOSAutocompletePanel: View {
    let state: IOSAutocompleteState
    let compact: Bool
    let accept: (EditorSuggestion) -> Void
    let dismiss: () -> Void

    var body: some View {
        if state.isPresented {
            VStack(alignment: .leading, spacing: compact ? 6 : 8) {
                HStack(spacing: 8) {
                    Text("Suggestions")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Dismiss suggestions")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(state.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            Button {
                                accept(suggestion)
                            } label: {
                                Text(suggestion.displayText)
                                    .font((compact ? Font.callout : Font.body).monospaced())
                                    .lineLimit(1)
                                    .padding(.horizontal, compact ? 9 : 10)
                                    .padding(.vertical, compact ? 6 : 8)
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

                if !compact {
                    Text("Use arrow keys to select, Return or Tab to accept, and Escape to dismiss.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(compact ? 8 : 10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 0.5)
            }
            .shadow(radius: compact ? 6 : 10, y: 2)
        }
    }
}
