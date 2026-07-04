import DreamJotterCore
import SwiftUI

struct ScreenplayParagraphInspectorView: View {
    @Binding var document: ProjectDocumentViewModel

    private var cursorLocation: Int {
        document.editorNavigationState.cursorTextRange?.location ?? 0
    }

    private var selection: ScreenplayParagraphSelection {
        document.paragraphSelection(at: cursorLocation)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paragraph Type")
                .font(.headline)

            Picker("Type", selection: Binding(
                get: { selection.type },
                set: { document.setParagraphType($0, at: cursorLocation) }
            )) {
                ForEach(ScreenplayParagraphTypeControl.editableTypes, id: \.self) { type in
                    Text(ScreenplayParagraphTypeControl.displayName(for: type))
                        .tag(type)
                }
            }
            .labelsHidden()

            Text(ScreenplayParagraphTypeControl.description(for: selection.type))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            Text("Current paragraph")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(selection.sourceText.isEmpty ? String(localized: "Empty paragraph") : selection.sourceText)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text("Explicit paragraph types are stored in the screenplay text and used by both the editor and PDF export.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screenplay paragraph inspector")
    }
}
