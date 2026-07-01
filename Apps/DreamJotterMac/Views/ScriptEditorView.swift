import SwiftUI

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

            if document.scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Start with a scene heading like INT. APARTMENT - NIGHT, then add character cues and dialogue.")
                    .foregroundStyle(.secondary)
            }

            editorView
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
            ))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        case .textEditor:
            TextEditor(text: Binding(
                get: { document.scriptText },
                set: { document.updateScriptText($0) }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
