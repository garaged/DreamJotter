import Foundation

public struct BackupArchive: Codable, Equatable, Sendable {
    public let id: String
    public let formatVersion: String
    public let packageFormatVersion: String
    public let projectID: String
    public let projectTitle: String
    public let createdAt: Date
    public let containsScreenplay: Bool
    public let containsCharacters: Bool
    public let containsLocations: Bool
    public let containsNotes: Bool
    public let containsSceneMetadata: Bool
    public let containsRoutines: Bool
    public let project: DreamJotterProject

    public init(
        id: String,
        formatVersion: String = "1.0.0",
        packageFormatVersion: String = DreamJotterPackageStore.supportedFormatVersion,
        projectID: String,
        projectTitle: String,
        createdAt: Date,
        containsScreenplay: Bool,
        containsCharacters: Bool,
        containsLocations: Bool,
        containsNotes: Bool,
        containsSceneMetadata: Bool,
        containsRoutines: Bool,
        project: DreamJotterProject
    ) {
        self.id = id
        self.formatVersion = formatVersion
        self.packageFormatVersion = packageFormatVersion
        self.projectID = projectID
        self.projectTitle = projectTitle
        self.createdAt = createdAt
        self.containsScreenplay = containsScreenplay
        self.containsCharacters = containsCharacters
        self.containsLocations = containsLocations
        self.containsNotes = containsNotes
        self.containsSceneMetadata = containsSceneMetadata
        self.containsRoutines = containsRoutines
        self.project = project
    }
}

public enum RestoreResultStatus: String, Codable, Equatable, Sendable {
    case restored
    case failed
    case confirmationRequired
}

public struct RestoreResult: Codable, Equatable, Sendable {
    public let id: String
    public let status: RestoreResultStatus
    public let restoredProjectID: String?
    public let userMessage: String
    public let technicalDetail: String?
    public let completedAt: Date
    public let dirtyStateChanged: Bool

    public init(
        id: String,
        status: RestoreResultStatus,
        restoredProjectID: String?,
        userMessage: String,
        technicalDetail: String? = nil,
        completedAt: Date,
        dirtyStateChanged: Bool = false
    ) {
        self.id = id
        self.status = status
        self.restoredProjectID = restoredProjectID
        self.userMessage = userMessage
        self.technicalDetail = technicalDetail
        self.completedAt = completedAt
        self.dirtyStateChanged = dirtyStateChanged
    }
}

public enum BackupRestoreWorkflow {
    public static func makeArchive(for project: DreamJotterProject, createdAt: Date) -> BackupArchive {
        BackupArchive(
            id: "backup-\(project.metadata.id)-\(Int(createdAt.timeIntervalSince1970))",
            projectID: project.metadata.id,
            projectTitle: project.metadata.title,
            createdAt: createdAt,
            containsScreenplay: true,
            containsCharacters: !project.characters.isEmpty,
            containsLocations: !project.locations.isEmpty,
            containsNotes: !project.notes.isEmpty,
            containsSceneMetadata: !project.sceneCards.isEmpty,
            containsRoutines: !project.pro.routines.isEmpty,
            project: project
        )
    }

    public static func encode(_ archive: BackupArchive) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(archive)
    }

    public static func decode(_ data: Data) throws -> BackupArchive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupArchive.self, from: data)
    }

    public static func jsonString(for project: DreamJotterProject, createdAt: Date) throws -> String {
        let data = try encode(makeArchive(for: project, createdAt: createdAt))
        return String(decoding: data, as: UTF8.self)
    }

    public static func validateRestore(
        from data: Data,
        currentProjectIsDirty: Bool,
        allowReplacingDirtyProject: Bool = false,
        completedAt: Date = Date()
    ) -> (project: DreamJotterProject?, result: RestoreResult) {
        let archive: BackupArchive
        do {
            archive = try decode(data)
        } catch {
            return (nil, RestoreResult(
                id: "restore-result-invalid-\(Int(completedAt.timeIntervalSince1970))",
                status: .failed,
                restoredProjectID: nil,
                userMessage: "This backup could not be read.",
                technicalDetail: String(describing: error),
                completedAt: completedAt
            ))
        }

        guard archive.formatVersion.hasPrefix("1.") else {
            return (nil, RestoreResult(
                id: "restore-result-\(archive.id)",
                status: .failed,
                restoredProjectID: nil,
                userMessage: "This backup was made by an unsupported version of DreamJotter.",
                technicalDetail: "Backup archive formatVersion=\(archive.formatVersion)",
                completedAt: completedAt
            ))
        }

        guard archive.packageFormatVersion == DreamJotterPackageStore.supportedFormatVersion else {
            return (nil, RestoreResult(
                id: "restore-result-\(archive.id)",
                status: .failed,
                restoredProjectID: nil,
                userMessage: "This backup uses an unsupported project package format.",
                technicalDetail: "Backup packageFormatVersion=\(archive.packageFormatVersion)",
                completedAt: completedAt
            ))
        }

        guard archive.projectID == archive.project.metadata.id else {
            return (nil, RestoreResult(
                id: "restore-result-\(archive.id)",
                status: .failed,
                restoredProjectID: nil,
                userMessage: "This backup does not match its project metadata.",
                technicalDetail: "Archive projectID=\(archive.projectID), project.metadata.id=\(archive.project.metadata.id)",
                completedAt: completedAt
            ))
        }

        if currentProjectIsDirty && !allowReplacingDirtyProject {
            return (nil, RestoreResult(
                id: "restore-result-\(archive.id)",
                status: .confirmationRequired,
                restoredProjectID: archive.projectID,
                userMessage: "Save or discard your current changes before restoring this backup.",
                completedAt: completedAt
            ))
        }

        return (archive.project, RestoreResult(
            id: "restore-result-\(archive.id)",
            status: .restored,
            restoredProjectID: archive.projectID,
            userMessage: "Backup is valid and ready to restore.",
            completedAt: completedAt,
            dirtyStateChanged: false
        ))
    }
}
