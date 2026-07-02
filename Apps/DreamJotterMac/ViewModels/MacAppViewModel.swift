import DreamJotterCore
import Foundation

enum SaveRequestResult: Equatable {
    case saved
    case requiresSaveAs
}

enum SaveAsRequestResult: Equatable {
    case saved
    case canceled
}

enum ProjectReplacementDecision: Equatable {
    case replaced
    case requiresConfirmation(String)
}

enum SaveBeforeReplacementResult: Equatable {
    case replaced
    case requiresSaveAs
}

enum PendingProjectReplacement: Equatable {
    case newProject(title: String)
    case openPackage(URL)
    case closeProject
    case closeWindow
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
        recentProjectURLs = Self.deduplicatedRecentProjectURLs(recentProjectStore.load())
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

    mutating func requestCloseWindow() -> ProjectReplacementDecision {
        guard canReplaceCurrentProject else {
            pendingReplacement = .closeWindow
            return .requiresConfirmation("The current project has unsaved changes. Save it before closing this window, or discard those changes.")
        }

        closeProject()
        return .replaced
    }

    mutating func confirmPendingReplacement(now: Date = Date()) throws {
        try discardPendingReplacement(now: now)
    }

    mutating func discardPendingReplacement(now: Date = Date()) throws {
        try applyPendingReplacement(now: now)
    }

    mutating func saveAndConfirmPendingReplacement(now: Date = Date()) throws -> SaveBeforeReplacementResult {
        guard pendingReplacement != nil else { return .replaced }
        let result = try saveCurrentProject(now: now)
        guard result == .saved else { return .requiresSaveAs }
        try applyPendingReplacement(now: now)
        return .replaced
    }

    mutating func confirmPendingReplacementAfterExternalSave(now: Date = Date()) throws {
        guard currentDocument?.isDirty != true else {
            throw AppError(
                category: .saveFailed,
                userMessage: "DreamJotter could not finish because the current project still has unsaved changes.",
                recoverySuggestion: "Save the project, then try again.",
                sourceOperation: .save
            )
        }
        try applyPendingReplacement(now: now)
    }

    mutating func cancelSaveAs() -> SaveAsRequestResult {
        .canceled
    }

    mutating func cancelPendingReplacement() {
        pendingReplacement = nil
    }

    mutating func openPackage(at packageURL: URL) throws {
        let normalizedURL = Self.normalizedFileURL(packageURL)
        let result = DreamJotterPackageStore.load(from: normalizedURL)
        if let project = result.project {
            let canonicalText = FountainIO.exportScreenplay(project.screenplay)
            let scriptText = canonicalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? DreamJotterPackageStore.fountainProjectionText(from: normalizedURL)
                : nil
            currentDocument = ProjectDocumentViewModel(project: project, packageURL: normalizedURL, scriptText: scriptText)
            recordRecentProject(normalizedURL)
            return
        }

        let diagnostic = result.diagnostics.first
        throw AppError.storage(
            diagnostic,
            operation: .open,
            fallbackMessage: "DreamJotter could not open this package. Choose a valid .dreamjotter folder."
        )
    }

    mutating func saveCurrentProject(now: Date = Date()) throws -> SaveRequestResult {
        guard var document = currentDocument else { return .saved }
        guard let packageURL = document.packageURL else { return .requiresSaveAs }

        let normalizedURL = Self.normalizedFileURL(packageURL)
        do {
            try document.save(to: normalizedURL, now: now)
        } catch {
            throw AppError.wrap(error, operation: .save)
        }
        currentDocument = document
        recordRecentProject(normalizedURL)
        return .saved
    }

    mutating func saveCurrentProject(to packageURL: URL, now: Date = Date()) throws -> SaveAsRequestResult {
        guard var document = currentDocument else { return .saved }
        let normalizedURL = Self.normalizedFileURL(packageURL)
        do {
            try document.save(to: normalizedURL, now: now)
        } catch {
            throw AppError.wrap(error, operation: .saveAs)
        }
        currentDocument = document
        recordRecentProject(normalizedURL)
        return .saved
    }

    func exportCurrentProject(to fileURL: URL) throws {
        do {
            try currentDocument?.exportFountain(to: fileURL)
        } catch {
            throw AppError.wrap(error, operation: .export)
        }
    }

    func exportCurrentProject(request: ExportRequest, preset: ExportPreset, now: Date = Date()) -> ExportFeedback {
        guard let document = currentDocument else {
            return ExportFeedback(
                kind: .error,
                userMessage: "Open a project before exporting.",
                sourceOperation: "export",
                timestamp: now
            )
        }

        let export = ExportWorkflow.exportData(
            for: document.project,
            request: request,
            preset: preset,
            generatedAt: now
        )

        guard export.result.status == .success, let data = export.data else {
            return .from(export.result, timestamp: now)
        }

        do {
            try data.write(to: URL(fileURLWithPath: request.destinationPath), options: .atomic)
            return .from(export.result, timestamp: now)
        } catch {
            let appError = AppError.wrap(error, operation: .export)
            return ExportFeedback(
                kind: .error,
                userMessage: appError.userMessage,
                technicalDetail: appError.technicalDetail,
                outputPath: request.destinationPath,
                sourceOperation: "export",
                timestamp: now
            )
        }
    }

    mutating func restoreBackup(from data: Data, allowReplacingDirtyProject: Bool = false, now: Date = Date()) -> RestoreResult {
        let restore = BackupRestoreWorkflow.validateRestore(
            from: data,
            currentProjectIsDirty: currentDocument?.isDirty == true,
            allowReplacingDirtyProject: allowReplacingDirtyProject,
            completedAt: now
        )

        guard restore.result.status == .restored, let project = restore.project else {
            return restore.result
        }

        currentDocument = ProjectDocumentViewModel(project: project)
        return restore.result
    }

    mutating func closeProject() {
        currentDocument = nil
    }

    mutating func forgetInvalidRecentProject(_ packageURL: URL) {
        let normalizedURL = Self.normalizedFileURL(packageURL)
        recentProjectURLs.removeAll { Self.normalizedFileURL($0) == normalizedURL }
        recentProjectStore.save(recentProjectURLs)
    }

    private mutating func applyPendingReplacement(now: Date) throws {
        guard let pendingReplacement else { return }
        self.pendingReplacement = nil

        switch pendingReplacement {
        case .newProject(let title):
            createBlankProject(title: title, now: now)
        case .openPackage(let packageURL):
            try openPackage(at: packageURL)
        case .closeProject:
            closeProject()
        case .closeWindow:
            closeProject()
        }
    }

    private var canReplaceCurrentProject: Bool {
        currentDocument?.isDirty != true
    }

    private mutating func recordRecentProject(_ packageURL: URL) {
        let normalizedURL = Self.normalizedFileURL(packageURL)
        recentProjectURLs.removeAll { Self.normalizedFileURL($0) == normalizedURL }
        recentProjectURLs.insert(normalizedURL, at: 0)
        recentProjectURLs = Array(recentProjectURLs.prefix(10))
        recentProjectStore.save(recentProjectURLs)
    }

    private static func deduplicatedRecentProjectURLs(_ urls: [URL]) -> [URL] {
        var seen: Set<String> = []
        var deduplicated: [URL] = []
        for url in urls {
            let normalizedURL = normalizedFileURL(url)
            guard seen.insert(normalizedURL.path).inserted else { continue }
            deduplicated.append(normalizedURL)
        }
        return Array(deduplicated.prefix(10))
    }

    private static func normalizedFileURL(_ url: URL) -> URL {
        url.standardizedFileURL
    }
}

enum AppErrorCategory: String, Equatable {
    case openFailed
    case saveFailed
    case saveAsCanceled
    case saveAsFailed
    case exportFailed
    case invalidPackage
    case unsupportedPackageVersion
    case missingProjectFile
    case permissionDenied
    case unknown
}

enum AppErrorSourceOperation: String, Equatable {
    case open
    case save
    case saveAs
    case export
    case recentProjectOpen
    case close
    case unknown
}

struct AppError: Error, LocalizedError, Equatable {
    let id: String
    let category: AppErrorCategory
    let userMessage: String
    let technicalDetail: String?
    let recoverySuggestion: String?
    let sourceOperation: AppErrorSourceOperation
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        category: AppErrorCategory,
        userMessage: String,
        technicalDetail: String? = nil,
        recoverySuggestion: String? = nil,
        sourceOperation: AppErrorSourceOperation,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.userMessage = userMessage
        self.technicalDetail = technicalDetail
        self.recoverySuggestion = recoverySuggestion
        self.sourceOperation = sourceOperation
        self.timestamp = timestamp
    }

    var errorDescription: String? {
        if let recoverySuggestion, !recoverySuggestion.isEmpty {
            return "\(userMessage) \(recoverySuggestion)"
        }
        return userMessage
    }

    static func storage(
        _ diagnostic: StorageDiagnostic?,
        operation: AppErrorSourceOperation,
        fallbackMessage: String
    ) -> AppError {
        guard let diagnostic else {
            return AppError(
                category: .openFailed,
                userMessage: fallbackMessage,
                sourceOperation: operation
            )
        }

        let category: AppErrorCategory
        switch diagnostic.code {
        case "unsupportedFormatVersion":
            category = .unsupportedPackageVersion
        case "missingManifest", "invalidJSON", "invalidSchema":
            category = .invalidPackage
        case "missingRequiredFile":
            category = .missingProjectFile
        default:
            category = .openFailed
        }

        return AppError(
            category: category,
            userMessage: userMessage(for: category, fallback: diagnostic.message),
            technicalDetail: "\(diagnostic.code): \(diagnostic.message)",
            recoverySuggestion: diagnostic.recoverySuggestion,
            sourceOperation: operation
        )
    }

    static func wrap(_ error: Error, operation: AppErrorSourceOperation) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if isPermissionDenied(error) {
            return AppError(
                category: .permissionDenied,
                userMessage: "DreamJotter does not have permission to complete this action.",
                technicalDetail: error.localizedDescription,
                recoverySuggestion: "Choose another location or update file permissions.",
                sourceOperation: operation
            )
        }

        let category: AppErrorCategory
        switch operation {
        case .open, .recentProjectOpen:
            category = .openFailed
        case .save:
            category = .saveFailed
        case .saveAs:
            category = .saveAsFailed
        case .export:
            category = .exportFailed
        case .close, .unknown:
            category = .unknown
        }

        return AppError(
            category: category,
            userMessage: userMessage(for: category, fallback: "DreamJotter could not complete this action."),
            technicalDetail: error.localizedDescription,
            recoverySuggestion: recoverySuggestion(for: category),
            sourceOperation: operation
        )
    }

    private static func userMessage(for category: AppErrorCategory, fallback: String) -> String {
        switch category {
        case .openFailed:
            return "DreamJotter could not open this project package."
        case .saveFailed:
            return "DreamJotter could not save this project."
        case .saveAsCanceled:
            return "Save As was canceled."
        case .saveAsFailed:
            return "DreamJotter could not save this project to the chosen location."
        case .exportFailed:
            return "DreamJotter could not export the Fountain file."
        case .invalidPackage:
            return "DreamJotter could not open this project because the package is not valid."
        case .unsupportedPackageVersion:
            return "This project was saved by a newer version of DreamJotter."
        case .missingProjectFile:
            return "DreamJotter could not open this project because a required project file is missing."
        case .permissionDenied:
            return "DreamJotter does not have permission to complete this action."
        case .unknown:
            return fallback
        }
    }

    private static func recoverySuggestion(for category: AppErrorCategory) -> String? {
        switch category {
        case .openFailed, .invalidPackage, .missingProjectFile:
            return "Choose another .dreamjotter package or restore this project from a backup."
        case .unsupportedPackageVersion:
            return "Open this project with a newer compatible version of DreamJotter."
        case .saveFailed, .saveAsFailed, .exportFailed, .permissionDenied:
            return "Choose another location or check file permissions."
        case .saveAsCanceled, .unknown:
            return nil
        }
    }

    private static func isPermissionDenied(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain {
            return [
                CocoaError.fileReadNoPermission.rawValue,
                CocoaError.fileWriteNoPermission.rawValue,
                CocoaError.fileWriteVolumeReadOnly.rawValue
            ].contains(nsError.code)
        }
        return nsError.domain == NSPOSIXErrorDomain && nsError.code == EACCES
    }
}

typealias MacAppError = AppError
