import DreamJotterCore
import SwiftUI

struct CharacterListView: View {
    let characters: [CharacterRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Characters")
                .font(.headline)

            if characters.isEmpty {
                Text("No characters yet. Type uppercase character cues in the Script pane to derive this list.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(characters, id: \.id) { character in
                    Text(character.displayName)
                        .lineLimit(1)
                }
            }
        }
    }
}
