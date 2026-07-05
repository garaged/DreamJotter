import Foundation

@MainActor
enum IOSWorkspacePane: String, CaseIterable, Identifiable, Hashable {
    case screenplay
    case scenes
    case characters
    case locations
    case notes
    case review

    var id: String { rawValue }

    var title: String {
        switch self {
        case .screenplay: "Screenplay"
        case .scenes: "Scenes"
        case .characters: "Characters"
        case .locations: "Locations"
        case .notes: "Notes"
        case .review: "Review"
        }
    }

    var systemImage: String {
        switch self {
        case .screenplay: "text.alignleft"
        case .scenes: "rectangle.stack"
        case .characters: "person.2"
        case .locations: "mappin.and.ellipse"
        case .notes: "note.text"
        case .review: "checkmark.circle"
        }
    }
}
