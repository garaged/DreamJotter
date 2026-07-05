import DreamJotterCore
import Foundation

public struct IOSPackageGeneration: Equatable, Codable, Sendable {
    public let value: String

    public init(value: String) {
        self.value = value
    }
}

public struct IOSProjectDocumentSnapshot: Sendable {
    public let project: DreamJotterProject
    public let packageURL: URL
    public let generation: IOSPackageGeneration

    public init(
        project: DreamJotterProject,
        packageURL: URL,
        generation: IOSPackageGeneration
    ) {
        self.project = project
        self.packageURL = packageURL
        self.generation = generation
    }
}

public enum IOSProjectDocumentError: Error, Equatable, LocalizedError, Sendable {
    case securityScopedAccessDenied
    case invalidPackage(String)
    case externalModificationDetected
    case coordinatedReadFailed(String)
    case coordinatedWriteFailed(String)

    public var errorDescription: String? {
        switch self {
        case .securityScopedAccessDenied:
            return "DreamJotter could not access the selected file location."
        case .invalidPackage(let message):
            return message
        case .externalModificationDetected:
            return "The project changed in another app or device. Reload it or save a copy before continuing."
        case .coordinatedReadFailed(let message):
            return "DreamJotter could not read the project: \(message)"
        case .coordinatedWriteFailed(let message):
            return "DreamJotter could not save the project: \(message)"
        }
    }
}

public struct IOSSecurityScopedAccess: @unchecked Sendable {
    private let beginAccess: (URL) -> Bool
    private let endAccess: (URL) -> Void

    public init(
        beginAccess: @escaping (URL) -> Bool,
        endAccess: @escaping (URL) -> Void
    ) {
        self.beginAccess = beginAccess
        self.endAccess = endAccess
    }

    public static let system = IOSSecurityScopedAccess(
        beginAccess: { $0.startAccessingSecurityScopedResource() },
        endAccess: { $0.stopAccessingSecurityScopedResource() }
    )

    public static let unrestricted = IOSSecurityScopedAccess(
        beginAccess: { _ in true },
        endAccess: { _ in }
    )

    func withAccess<T>(to url: URL, operation: () throws -> T) throws -> T {
        guard beginAccess(url) else {
            throw IOSProjectDocumentError.securityScopedAccessDenied
        }
        defer { endAccess(url) }
        return try operation()
    }
}

public struct IOSFileCoordination: @unchecked Sendable {
    private let read: (URL, @escaping (URL) throws -> Void) throws -> Void
    private let write: (URL, @escaping (URL) throws -> Void) throws -> Void

    public init(
        read: @escaping (URL, @escaping (URL) throws -> Void) throws -> Void,
        write: @escaping (URL, @escaping (URL) throws -> Void) throws -> Void
    ) {
        self.read = read
        self.write = write
    }

    public static let system = IOSFileCoordination(
        read: { url, accessor in
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var coordinationError: NSError?
            var accessorError: Error?
            coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { coordinatedURL in
                do { try accessor(coordinatedURL) } catch { accessorError = error }
            }
            if let coordinationError { throw coordinationError }
            if let accessorError { throw accessorError }
        },
        write: { url, accessor in
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var coordinationError: NSError?
            var accessorError: Error?
            coordinator.coordinate(writingItemAt: url, options: .forReplacing, error: &coordinationError) { coordinatedURL in
                do { try accessor(coordinatedURL) } catch { accessorError = error }
            }
            if let coordinationError { throw coordinationError }
            if let accessorError { throw accessorError }
        }
    )

    public static let direct = IOSFileCoordination(
        read: { url, accessor in try accessor(url) },
        write: { url, accessor in try accessor(url) }
    )

    func coordinateRead(at url: URL, accessor: @escaping (URL) throws -> Void) throws {
        try read(url, accessor)
    }

    func coordinateWrite(at url: URL, accessor: @escaping (URL) throws -> Void) throws {
        try write(url, accessor)
    }
}

private final class IOSProjectLoadCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var project: DreamJotterProject?
    private var diagnosticMessage: String?

    func store(project: DreamJotterProject?, diagnosticMessage: String?) {
        lock.lock()
        self.project = project
        self.diagnosticMessage = diagnosticMessage
        lock.unlock()
    }

    func snapshot() -> (project: DreamJotterProject?, diagnosticMessage: String?) {
        lock.lock()
        defer { lock.unlock() }
        return (project, diagnosticMessage)
    }
}

public actor IOSProjectDocumentAdapter {
    private let fileManager: FileManager
    private let securityScopedAccess: IOSSecurityScopedAccess
    private let coordination: IOSFileCoordination

    public init(
        fileManager: FileManager = .default,
        securityScopedAccess: IOSSecurityScopedAccess = .system,
        coordination: IOSFileCoordination = .system
    ) {
        self.fileManager = fileManager
        self.securityScopedAccess = securityScopedAccess
        self.coordination = coordination
    }

    public func createProject(
        title: String,
        at packageURL: URL,
        now: Date = Date()
    ) throws -> IOSProjectDocumentSnapshot {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let project = ProjectFactory.createBlankProject(
            title: normalizedTitle.isEmpty ? "Untitled" : normalizedTitle,
            projectID: "project-\(UUID().uuidString)",
            screenplayID: "screenplay-\(UUID().uuidString)",
            createdAt: now
        )

        try securityScopedAccess.withAccess(to: packageURL.deletingLastPathComponent()) {
            do {
                try coordination.coordinateWrite(at: packageURL) { coordinatedURL in
                    try DreamJotterPackageStore.save(project, to: coordinatedURL, updatedAt: now)
                }
            } catch {
                throw IOSProjectDocumentError.coordinatedWriteFailed(error.localizedDescription)
            }
        }

        return try snapshot(for: project, at: packageURL)
    }

    public func openProject(at packageURL: URL) throws -> IOSProjectDocumentSnapshot {
        let capture = IOSProjectLoadCapture()

        try securityScopedAccess.withAccess(to: packageURL) {
            do {
                try coordination.coordinateRead(at: packageURL) { coordinatedURL in
                    let result = DreamJotterPackageStore.load(from: coordinatedURL)
                    capture.store(
                        project: result.project,
                        diagnosticMessage: result.diagnostics.first?.message
                    )
                }
            } catch {
                throw IOSProjectDocumentError.coordinatedReadFailed(error.localizedDescription)
            }
        }

        let result = capture.snapshot()
        guard let loadedProject = result.project else {
            throw IOSProjectDocumentError.invalidPackage(
                result.diagnosticMessage ?? "DreamJotter could not open this package."
            )
        }
        return try snapshot(for: loadedProject, at: packageURL)
    }

    public func saveProject(
        _ project: DreamJotterProject,
        at packageURL: URL,
        expectedGeneration: IOSPackageGeneration?,
        now: Date = Date()
    ) throws -> IOSProjectDocumentSnapshot {
        try securityScopedAccess.withAccess(to: packageURL) {
            if let expectedGeneration,
               try generation(at: packageURL) != expectedGeneration {
                throw IOSProjectDocumentError.externalModificationDetected
            }

            do {
                try coordination.coordinateWrite(at: packageURL) { coordinatedURL in
                    try DreamJotterPackageStore.save(project, to: coordinatedURL, updatedAt: now)
                }
            } catch let error as IOSProjectDocumentError {
                throw error
            } catch {
                throw IOSProjectDocumentError.coordinatedWriteFailed(error.localizedDescription)
            }
        }

        return try snapshot(for: project, at: packageURL)
    }

    public func generation(at packageURL: URL) throws -> IOSPackageGeneration {
        guard fileManager.fileExists(atPath: packageURL.path) else {
            return IOSPackageGeneration(value: "missing")
        }

        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey]
        let enumerator = fileManager.enumerator(
            at: packageURL,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )

        var records: [String] = []
        while let fileURL = enumerator?.nextObject() as? URL {
            let values = try fileURL.resourceValues(forKeys: keys)
            let relativePath = fileURL.path.replacingOccurrences(of: packageURL.path, with: "")
            let timestamp = values.contentModificationDate?.timeIntervalSince1970 ?? 0
            records.append("\(relativePath)|\(values.isDirectory == true ? "d" : "f")|\(values.fileSize ?? 0)|\(timestamp)")
        }

        return IOSPackageGeneration(value: records.sorted().joined(separator: "\n"))
    }

    private func snapshot(
        for project: DreamJotterProject,
        at packageURL: URL
    ) throws -> IOSProjectDocumentSnapshot {
        IOSProjectDocumentSnapshot(
            project: project,
            packageURL: packageURL,
            generation: try generation(at: packageURL)
        )
    }
}
