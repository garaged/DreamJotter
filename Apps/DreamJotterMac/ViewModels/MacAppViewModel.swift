import DreamJotterCore
import Foundation

struct MacAppViewModel: Equatable {
    var currentDocument: ProjectDocumentViewModel?

    var hasOpenProject: Bool {
        currentDocument != nil
    }

    mutating func createBlankProject(title: String, now: Date = Date()) {
        let project = ProjectFactory.createBlankProject(
            title: title,
            projectID: "project-\(UUID().uuidString)",
            screenplayID: "screenplay-\(UUID().uuidString)",
            createdAt: now
        )
        currentDocument = ProjectDocumentViewModel(project: project)
    }

    mutating func openPackage(at packageURL: URL) throws {
        let result = DreamJotterPackageStore.load(from: packageURL)
        if let project = result.project {
            currentDocument = ProjectDocumentViewModel(project: project, packageURL: packageURL)
            return
        }

        let message = result.diagnostics.first?.message ?? "The package could not be opened."
        throw MacAppError(message)
    }

    mutating func closeProject() {
        currentDocument = nil
    }
}

struct MacAppError: Error, LocalizedError, Equatable {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
