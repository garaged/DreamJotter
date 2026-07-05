import DreamJotterCore
import SwiftUI

struct SuggestionsPanel: View {
    let suggestions: [EditorSuggestion]
    let selectedIndex: Int
    let acceptAction: (EditorSuggestion) -> Void
    let ignoreAction: () -> Void

    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Suggestions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("↑↓ select • Return or Tab accept • Esc dismiss")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Ignore", action: ignoreAction)
                        .buttonStyle(.borderless)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            Button { acceptAction(suggestion) } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.displayText)
                                        .font(.callout.monospaced())
                                    Text(localizedType(suggestion.type.rawValue))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(index == selectedIndex ? Color.accentColor.opacity(0.16) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .accessibilityLabel(String(format: String(localized: "Accept suggestion: %@"), suggestion.displayText))
                            .accessibilityValue(index == selectedIndex ? String(localized: "Selected") : "")
                        }
                    }
                }
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func localizedType(_ rawValue: String) -> String {
        switch rawValue {
        case "sceneHeading": String(localized: "Scene Heading")
        case "character": String(localized: "Character")
        case "location": String(localized: "Location")
        case "timeOfDay": String(localized: "Time of Day")
        default: String(localized: String.LocalizationValue(rawValue))
        }
    }
}

struct EmptyScriptGuidance: View {
    let language: ScreenplayLanguageProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Start with a scene heading")
                .font(.callout.weight(.semibold))
            Text(language == .spanishLatinAmerica ? "INT. DEPARTAMENTO - MAÑANA" : "INT. APARTMENT - MORNING")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Una habitación tranquila antes del amanecer." : "A quiet room before sunrise.")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "SOFÍA" : "ELENA")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Aquí comenzamos." : "We begin here.")
                .font(.callout.monospaced())
        }
        .foregroundStyle(.secondary)
    }
}

struct ScreenplayLanguagePicker: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        Picker("Screenplay Language", selection: Binding(
            get: { document.screenplayLanguage },
            set: { document.setScreenplayLanguage($0) }
        )) {
            Text("Automatic").tag(ScreenplayLanguageProfile.automatic)
            Text("English").tag(ScreenplayLanguageProfile.english)
            Text("Spanish (Latin America)").tag(ScreenplayLanguageProfile.spanishLatinAmerica)
        }
        .frame(width: 210)
    }
}
