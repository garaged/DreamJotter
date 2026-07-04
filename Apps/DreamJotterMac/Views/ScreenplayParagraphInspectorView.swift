import DreamJotterCore
import SwiftUI

struct ScreenplayParagraphInspectorView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var showsFormattingGuide = false

    private var cursorLocation: Int {
        document.editorNavigationState.cursorTextRange?.location ?? 0
    }

    private var selection: ScreenplayParagraphSelection {
        document.paragraphSelection(at: cursorLocation)
    }

    private var currentGuideEntry: ScreenplayFormattingGuideEntry? {
        ScreenplayFormattingGuide.entry(for: selection.type)
    }

    var body: some View {
        ScrollView {
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

                if let entry = currentGuideEntry {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Editor syntax")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(entry.example)
                            .font(.system(.callout, design: .monospaced))
                            .textSelection(.enabled)
                        Text(entry.guidance)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

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

                DisclosureGroup("Formatting Guide", isExpanded: $showsFormattingGuide) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Use a marker when automatic paragraph detection is ambiguous. Markers are editor syntax only; they are removed from rendered screenplay text and PDF output.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(ScreenplayFormattingGuide.entries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(ScreenplayParagraphTypeControl.displayName(for: entry.type))
                                        .font(.callout.weight(.semibold))
                                    Spacer()
                                    Text(entry.marker)
                                        .font(.system(.caption, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(nsColor: .controlBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                Text(entry.example)
                                    .font(.system(.caption, design: .monospaced))
                                    .textSelection(.enabled)
                                Text(entry.guidance)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding(.top, 8)
                }

                Text("The paragraph type engine is shared by editor styling, semantic parsing, and PDF layout.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screenplay paragraph inspector")
    }
}
