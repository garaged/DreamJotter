import SwiftUI

struct ScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(document.project.metadata.title)
                .font(.title2.weight(.semibold))

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
