import SwiftUI

struct ProjectLibraryView: View {
    @State private var title = "Untitled"

    let createAction: (String) -> Void
    let openAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("DreamJotter")
                .font(.system(size: 34, weight: .semibold))

            HStack(spacing: 10) {
                TextField("Project title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 320)

                Button("New Project") {
                    createAction(title)
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button("Open Package") {
                    openAction()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }

            Text("Create or open a local .dreamjotter package.")
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
