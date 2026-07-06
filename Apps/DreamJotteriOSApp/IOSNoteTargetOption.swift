import DreamJotterCore

struct IOSNoteTargetOption: Identifiable {
    let link: NoteLink
    let title: String

    var id: String {
        "\(link.targetKind.rawValue):\(link.targetID)"
    }
}
