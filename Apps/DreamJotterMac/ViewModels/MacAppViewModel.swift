import DreamJotterCore
import Foundation

enum SaveRequestResult: Equatable {
    case saved
    case requiresSaveAs
}

enum ProjectReplacementDecision: Equatable {
    case replaced
    case requiresConfirmation(String)
}

enum PendingProjectReplacement: Equatable {
    case newProject(title: String)
    case openPackage(URL)
    case closeProject
}

struct RecentProjectStore {
    var load: () -> [URL]
    var save: ([URL]) -> Void

    static func userDefaults(
        defaults: UserDefaults = .standard,
        key: String = "DreamJotterRecentProjectURLs"
    ) -> RecentProjectStore {
        RecentProjectStore(
            load: {
                defaults.stringArray(forKey: key)?.map(URL.init(fileURLWithPath:)) ?? []
            },
            save: { urls in
                defaults.set(urls.map(\.path), forKey: key)
            }
        )
    }

    static func memory(initialURLs: [URL] = []) -> RecentProjectStore {
        final class Box {
            var urls: [URL]

            init(_ urls: [URL]) {
                self.urls = urls
            }
        }

        let box = Box(initialURLs)
        return RecentProjectStore(
            load: { box.urls },
            save: { box.urls = $0 }
        )
    }
}

struct MacAppViewModel {
    var currentDocument: ProjectDocumentViewModel?
    private(set) var recentProjectURLs: [URL]
    private(set) var pendingReplacement: PendingProjectReplacement?
    private var recentProjectStore: RecentProjectStore

    init(recentProjectStore: RecentProjectStore = .userDefaults()) {
        self.recentProjectStore = recentProjectStore
        recentProjectURLs = recentProjectStore.load()
    }

    var hasOpenProject: Bool {
        currentDocument != nil
    }

    var currentDocumentRequiresSave: Bool {
        currentDocument?.packageURL == nil
    }

    var currentDocumentIsDirty: Bool {
        currentDocument?.isDirty == true
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

    mutating func requestNewProject(title: String, now: Date = Date()) -> ProjectReplacementDecision {
        guard canReplaceCurrentProject else {
            pendingReplacement = .newProject(title: title)
            return .requiresConfirmation("The current project has unsaved changes. Save it before starting another project, or discard those changes.")
        }

        createBlankProject(title: title, now: now)
        return .replaced
    }

    mutating func requestOpenPackage(at packageURL: URL) throws -> ProjectReplacementDecision {
        guard canReplaceCurrentProject else {
            pendingReplacement = .openPackage(packageURL)
            return .requiresConfirmation("The current project has unsaved changes. Save it before opening another project, or discard those changes.")
        }

        try openPackage(at: packageURL)
        return .replaced
    }

    mutating func requestCloseProject() -> ProjectReplacementDecision {
        guard canReplaceCurrentProject else {
            pendingReplacement = .closeProject
            return .requiresConfirmation("The current project has unsaved changes. Save it before returning to the library, or discard those changes.")
        }

        closeProject()
        return .replaced
    }

    mutating func confirmPendingReplacement(now: Date = Date()) throws {
        guard let pendingReplacement else { return }
        self.pendingReplacement = nil

        switch pendingReplacement {
        case .newProject(let title):
            createBlankProject(title: title, now: now)
        case .openPackage(let packageURL):
            try openPackage(at: packageURL)
        case .closeProject:
            closeProject()
        }
    }

    mutating func cancelPendingReplacement() {
        pendingReplacement = nil
    }

    mutating func openPackage(at packageURL: URL) throws {
        let result = DreamJotterPackageStore.load(from: packageURL)
        if let project = result.project {
            currentDocument = ProjectDocumentViewModel(project: project, packageURL: packageURL)
            recordRecentProject(packageURL)
            return
        }

        let message = result.diagnostics.first?.message ?? "DreamJotter could not open this package. Choose a valid .dreamjotter folder."
        throw MacAppError(message)
    }

    mutating func saveCurrentProject(now: Date = Date()) throws -> SaveRequestResult {
        guard var document = currentDocument else { return .saved }
        guard let packageURL = document.packageURL else { return .requiresSaveAs }

        try document.save(to: packageURL, now: now)
        currentDocument = document
        recordRecentProject(packageURL)
        return .saved
    }

    mutating func saveCurrentProject(to packageURL: URL, now: Date = Date()) throws {
        guard var document = currentDocument else { return }
        try document.save(to: packageURL, now: now)
        currentDocument = document
        recordRecentProject(packageURL)
    }

    func exportCurrentProject(to fileURL: URL) throws {
        try currentDocument?.exportFountain(to: fileURL)
    }

    mutating func closeProject() {
        currentDocument = nil
    }

    mutating func forgetInvalidRecentProject(_ packageURL: URL) {
        recentProjectURLs.removeAll { $0 == packageURL }
        recentProjectStore.save(recentProjectURLs)
    }

    private var canReplaceCurrentProject: Bool {
        currentDocument?.isDirty != true
    }

    private mutating func recordRecentProject(_ packageURL: URL) {
        recentProjectURLs.removeAll { $0 == packageURL }
        recentProjectURLs.insert(packageURL, at: 0)
        recentProjectURLs = Array(recentProjectURLs.prefix(10))
        recentProjectStore.save(recentProjectURLs)
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
