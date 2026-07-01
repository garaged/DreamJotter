import SwiftUI

struct ScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(document.project.metadata.title)
                    .font(.title2.weight(.semibold))

                Spacer()

                Button("Refresh Parse") {
                    document.refreshParse()
                }
            }

            if document.scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Start with a scene heading like INT. APARTMENT - NIGHT, then add character cues and dialogue.")
                    .foregroundStyle(.secondary)
            }

            TextEditor(text: Binding(
                get: { document.scriptText },
                set: { document.scriptText = $0 }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding()
    }
}
