import DreamJotterCore
import Foundation

extension ProjectDocumentViewModel {
    mutating func removeStoredProfile(id: String, kind: ProfileKind) {
        let now = Date()
        let request = ProfileCommandRequest(
            id: "remove-\(kind.rawValue)-\(UUID().uuidString)",
            action: .delete,
            profileKind: kind,
            profileID: id,
            confirmed: true,
            requestedAt: now
        )
        let output = CommandEngine.execute(request, project: project, now: now)
        guard output.result.status == .succeeded else { return }
        self = ProjectDocumentViewModel(
            project: output.project,
            packageURL: packageURL,
            scriptText: scriptText,
            isDirty: true
        )
    }
}
