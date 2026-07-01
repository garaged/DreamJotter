import SwiftUI
import DreamJotterCore

enum ScreenplayEditorAdapter: String, CaseIterable, Identifiable {
    case textKit = "TextKit"
    case textEditor = "TextEditor"

    var id: String { rawValue }
}

struct ScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var editorAdapter: ScreenplayEditorAdapter = .textKit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(document.project.metadata.title)
                    .font(.title2.weight(.semibold))

                Spacer()

                Picker("Editor", selection: $editorAdapter) {
                    ForEach(ScreenplayEditorAdapter.allCases) { adapter in
                        Text(adapter.rawValue).tag(adapter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)

            Button("Refresh Parse") {
                document.refreshParse()
            }
            }

            editorView
                .overlay(alignment: .topLeading) {
                    if document.isEmptyEditorGuidanceVisible {
                        EmptyScriptGuidance()
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }

            SuggestionsPanel(
                suggestions: document.editorSuggestions,
                acceptAction: { suggestion in
                    document.acceptEditorSuggestion(suggestion)
                },
                ignoreAction: {
                    document.ignoreEditorSuggestions()
                }
            )
        }
        .padding()
    }

    @ViewBuilder
    private var editorView: some View {
        switch editorAdapter {
        case .textKit:
            TextKitScreenplayEditorView(text: Binding(
                get: { document.scriptText },
                set: { document.updateScriptText($0) }
            ), navigationState: document.editorNavigationState,
            styleRuns: document.editorStyleRuns,
            onSmartEnter: { location in
                document.performSmartEnter(at: location)
                document.refreshEditorSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
            },
            onTabCycle: { location in
                document.performTabCycle(at: location)
                document.refreshEditorSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
            },
            onTextChanged: { location in
                document.refreshEditorSuggestions(cursorLocation: location)
            },
            onSelectionChanged: { location in
                document.updateSelectedSceneForCursor(location: location)
                document.refreshEditorSuggestions(cursorLocation: location)
            },
            onNavigationApplied: {
                document.clearEditorNavigationRequest()
            })
            .clipShape(RoundedRectangle(cornerRadius: 6))
        case .textEditor:
            TextEditor(text: Binding(
                get: { document.scriptText },
                set: {
                    document.updateScriptText($0)
                    document.refreshEditorSuggestions(cursorLocation: (document.scriptText as NSString).length)
                }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

private struct SuggestionsPanel: View {
    let suggestions: [EditorSuggestion]
    let acceptAction: (EditorSuggestion) -> Void
    let ignoreAction: () -> Void

    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Suggestions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button("Ignore") {
                        ignoreAction()
                    }
                    .buttonStyle(.borderless)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions, id: \.id) { suggestion in
                            Button {
                                acceptAction(suggestion)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.displayText)
                                        .font(.callout.monospaced())
                                    Text(suggestion.type.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

private struct EmptyScriptGuidance: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Start with a scene heading")
                .font(.callout.weight(.semibold))
            Text("INT. APARTMENT - MORNING")
                .font(.callout.monospaced())
            Text("A quiet room before sunrise.")
                .font(.callout.monospaced())
            Text("ELENA")
                .font(.callout.monospaced())
            Text("We begin here.")
                .font(.callout.monospaced())
        }
        .foregroundStyle(.secondary)
    }
}
