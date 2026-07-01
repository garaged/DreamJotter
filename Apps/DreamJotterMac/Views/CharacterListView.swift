import DreamJotterCore
import SwiftUI

struct CharacterListView: View {
    let characters: [CharacterRecord]

    var body: some View {
        if characters.isEmpty {
            Text("No characters")
                .foregroundStyle(.secondary)
        } else {
            ForEach(characters, id: \.id) { character in
                Text(character.displayName)
                    .lineLimit(1)
            }
        }
    }
}
