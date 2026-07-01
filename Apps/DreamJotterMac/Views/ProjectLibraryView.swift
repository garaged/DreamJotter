import SwiftUI

struct ProjectLibraryView: View {
    @State private var title = "Untitled"

    let recentProjectURLs: [URL]
    let createAction: (String) -> Void
    let openAction: () -> Void
    let openRecentAction: (URL) -> Void

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

            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Projects")
                    .font(.headline)

                if recentProjectURLs.isEmpty {
                    Text("Saved or opened projects will appear here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recentProjectURLs, id: \.self) { url in
                        Button {
                            openRecentAction(url)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(url.deletingPathExtension().lastPathComponent)
                                Text(url.path)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 12)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
