import Foundation

enum IOSWorkspacePane: String, CaseIterable, Identifiable, Hashable, Sendable {
    case dashboard
    case screenplay
    case scenes
    case characters
    case locations
    case notes
    case review
    case healthReport

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .screenplay: "Screenplay"
        case .scenes: "Scenes"
        case .characters: "Characters"
        case .locations: "Locations"
        case .notes: "Notes"
        case .review: "Review"
        case .healthReport: "Health Report"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .screenplay: "text.alignleft"
        case .scenes: "rectangle.stack"
        case .characters: "person.2"
        case .locations: "mappin.and.ellipse"
        case .notes: "note.text"
        case .review: "checkmark.circle"
        case .healthReport: "waveform.path.ecg"
        }
    }
}
