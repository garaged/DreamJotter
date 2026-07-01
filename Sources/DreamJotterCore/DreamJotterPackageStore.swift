import Foundation

public struct PackageManifest: Codable, Equatable, Sendable {
    public let packageId: String
    public let formatVersion: String
    public let minimumReaderVersion: String
    public let createdAt: Date
    public let updatedAt: Date
    public let projectFile: String
    public let screenplayFile: String
    public let sections: [String: PackageSection]
    public let snapshotsPath: String
    public let attachmentsPath: String
    public let exportsPath: String
    public let indexesPath: String

    public init(
        packageId: String,
        formatVersion: String = DreamJotterPackageStore.supportedFormatVersion,
        minimumReaderVersion: String = DreamJotterPackageStore.supportedFormatVersion,
        createdAt: Date,
        updatedAt: Date,
        projectFile: String = "project.json",
        screenplayFile: String = "screenplay.json",
        sections: [String: PackageSection] = DreamJotterPackageStore.defaultSections,
        snapshotsPath: String = "snapshots",
        attachmentsPath: String = "attachments",
        exportsPath: String = "exports",
        indexesPath: String = "indexes"
    ) {
        self.packageId = packageId
        self.formatVersion = formatVersion
        self.minimumReaderVersion = minimumReaderVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.projectFile = projectFile
        self.screenplayFile = screenplayFile
        self.sections = sections
        self.snapshotsPath = snapshotsPath
        self.attachmentsPath = attachmentsPath
        self.exportsPath = exportsPath
        self.indexesPath = indexesPath
    }
}

public struct PackageSection: Codable, Equatable, Sendable {
    public let path: String
    public let required: Bool

    public init(path: String, required: Bool) {
        self.path = path
        self.required = required
    }
}

public enum StorageSeverity: String, Codable, Equatable, Sendable {
    case info
    case warning
    case recoverable
    case fatal
}

public struct StorageDiagnostic: Codable, Equatable, Sendable {
    public let code: String
    public let severity: StorageSeverity
    public let path: String?
    public let message: String
    public let recoverySuggestion: String?

    public init(
        code: String,
        severity: StorageSeverity,
        path: String? = nil,
        message: String,
        recoverySuggestion: String? = nil
    ) {
        self.code = code
        self.severity = severity
        self.path = path
        self.message = message
        self.recoverySuggestion = recoverySuggestion
    }
}

public struct PackageLoadResult: Equatable, Sendable {
    public let project: DreamJotterProject?
    public let manifest: PackageManifest?
    public let diagnostics: [StorageDiagnostic]

    public init(project: DreamJotterProject?, manifest: PackageManifest?, diagnostics: [StorageDiagnostic]) {
        self.project = project
        self.manifest = manifest
        self.diagnostics = diagnostics
    }
}

public enum DreamJotterPackageStore {
    public static let supportedFormatVersion = "1.0.0"

    public static let defaultSections: [String: PackageSection] = [
        "characters": PackageSection(path: "characters.json", required: false),
        "notes": PackageSection(path: "notes.json", required: false),
        "inbox": PackageSection(path: "inbox.json", required: false),
        "sceneCards": PackageSection(path: "scene-cards.json", required: false),
        "exportPresets": PackageSection(path: "export-presets.json", required: false),
        "story": PackageSection(path: "story.json", required: false),
        "pro": PackageSection(path: "pro.json", required: false),
        "fountainProjection": PackageSection(path: "script.fountain", required: false)
    ]

    public static func packageURL(for project: DreamJotterProject, in directory: URL) -> URL {
        directory.appendingPathComponent(ProjectFactory.packageName(for: project), isDirectory: true)
    }

    public static func save(_ project: DreamJotterProject, to packageURL: URL, updatedAt: Date) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: packageURL, withIntermediateDirectories: true)

        for directory in ["snapshots", "attachments", "exports", "indexes"] {
            try fileManager.createDirectory(at: packageURL.appendingPathComponent(directory, isDirectory: true), withIntermediateDirectories: true)
        }

        let manifest = PackageManifest(
            packageId: project.metadata.id,
            createdAt: project.metadata.createdAt,
            updatedAt: updatedAt
        )

        try write(project.metadata, to: packageURL.appendingPathComponent(manifest.projectFile))
        try write(project.screenplay, to: packageURL.appendingPathComponent(manifest.screenplayFile))
        try write(project.characters, to: packageURL.appendingPathComponent("characters.json"))
        try write(project.notes, to: packageURL.appendingPathComponent("notes.json"))
        try write(project.inboxItems, to: packageURL.appendingPathComponent("inbox.json"))
        try write(project.sceneCards, to: packageURL.appendingPathComponent("scene-cards.json"))
        try write(project.exportPresets, to: packageURL.appendingPathComponent("export-presets.json"))
        try write(project.story, to: packageURL.appendingPathComponent("story.json"))
        try write(project.pro, to: packageURL.appendingPathComponent("pro.json"))
        try FountainIO.exportScreenplay(project.screenplay).write(to: packageURL.appendingPathComponent("script.fountain"), atomically: true, encoding: .utf8)
        try saveSnapshots(project.snapshots, to: packageURL.appendingPathComponent("snapshots", isDirectory: true))
        try write(manifest, to: packageURL.appendingPathComponent("manifest.json"))
    }

    public static func load(from packageURL: URL) -> PackageLoadResult {
        var diagnostics: [StorageDiagnostic] = []
        let manifestURL = packageURL.appendingPathComponent("manifest.json")

        guard FileManager.default.fileExists(atPath: manifestURL.path) else {
            return PackageLoadResult(
                project: nil,
                manifest: nil,
                diagnostics: [StorageDiagnostic(
                    code: "missingManifest",
                    severity: .fatal,
                    path: "manifest.json",
                    message: "The package manifest is missing.",
                    recoverySuggestion: "Restore from a snapshot or backup archive."
                )]
            )
        }

        guard let manifest: PackageManifest = decode(PackageManifest.self, from: manifestURL, relativePath: "manifest.json", diagnostics: &diagnostics) else {
            return PackageLoadResult(project: nil, manifest: nil, diagnostics: diagnostics)
        }

        if unsupportedMajorVersion(manifest.formatVersion) {
            diagnostics.append(StorageDiagnostic(
                code: "unsupportedFormatVersion",
                severity: .fatal,
                path: "manifest.json",
                message: "This package format is newer than this reader supports.",
                recoverySuggestion: "Open the package with a newer compatible version of DreamJotter."
            ))
            return PackageLoadResult(project: nil, manifest: manifest, diagnostics: diagnostics)
        }

        guard let metadata: ProjectMetadata = decodeRequired(
            ProjectMetadata.self,
            from: packageURL.appendingPathComponent(manifest.projectFile),
            relativePath: manifest.projectFile,
            diagnostics: &diagnostics
        ) else {
            return PackageLoadResult(project: nil, manifest: manifest, diagnostics: diagnostics)
        }

        guard let screenplay: ScreenplayDocument = decodeRequired(
            ScreenplayDocument.self,
            from: packageURL.appendingPathComponent(manifest.screenplayFile),
            relativePath: manifest.screenplayFile,
            diagnostics: &diagnostics
        ) else {
            return PackageLoadResult(project: nil, manifest: manifest, diagnostics: diagnostics)
        }

        let characters = decodeOptional([CharacterRecord].self, from: packageURL, section: manifest.sections["characters"], name: "characters", diagnostics: &diagnostics) ?? []
        let notes = decodeOptional([ProjectNote].self, from: packageURL, section: manifest.sections["notes"], name: "notes", diagnostics: &diagnostics) ?? []
        let inboxItems = decodeOptional([InboxItem].self, from: packageURL, section: manifest.sections["inbox"], name: "inbox", diagnostics: &diagnostics) ?? []
        let sceneCards = decodeOptional([SceneCard].self, from: packageURL, section: manifest.sections["sceneCards"], name: "sceneCards", diagnostics: &diagnostics) ?? []
        let exportPresets = decodeOptional([ExportPreset].self, from: packageURL, section: manifest.sections["exportPresets"], name: "exportPresets", diagnostics: &diagnostics) ?? ExportPresetCatalog.builtInPresets()
        let story = decodeOptional(StoryDevelopmentState.self, from: packageURL, section: manifest.sections["story"], name: "story", diagnostics: &diagnostics) ?? StoryDevelopmentState()
        let pro = decodeOptional(ProProjectState.self, from: packageURL, section: manifest.sections["pro"], name: "pro", diagnostics: &diagnostics) ?? ProProjectState()
        let snapshots = loadSnapshots(from: packageURL.appendingPathComponent(manifest.snapshotsPath, isDirectory: true), diagnostics: &diagnostics)

        let project = DreamJotterProject(
            metadata: metadata,
            screenplay: screenplay,
            mode: .simple,
            characters: characters,
            notes: notes,
            inboxItems: inboxItems,
            sceneCards: sceneCards,
            snapshots: snapshots,
            exportPresets: exportPresets,
            story: story,
            pro: pro
        )
        return PackageLoadResult(project: project, manifest: manifest, diagnostics: diagnostics)
    }

    private static func saveSnapshots(_ snapshots: [SnapshotRecord], to snapshotsURL: URL) throws {
        for snapshot in snapshots {
            let snapshotDirectory = snapshotsURL.appendingPathComponent(snapshot.id, isDirectory: true)
            try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
            try write(snapshot, to: snapshotDirectory.appendingPathComponent("snapshot.json"))
            try write(snapshot.project.metadata, to: snapshotDirectory.appendingPathComponent("project.json"))
            try write(snapshot.project.screenplay, to: snapshotDirectory.appendingPathComponent("screenplay.json"))
            try write(snapshot.project.characters, to: snapshotDirectory.appendingPathComponent("characters.json"))
            try write(snapshot.project.notes, to: snapshotDirectory.appendingPathComponent("notes.json"))
            try write(snapshot.project.story, to: snapshotDirectory.appendingPathComponent("story.json"))
            try write(snapshot.project.pro, to: snapshotDirectory.appendingPathComponent("pro.json"))
        }
    }

    private static func loadSnapshots(from snapshotsURL: URL, diagnostics: inout [StorageDiagnostic]) -> [SnapshotRecord] {
        guard let directories = try? FileManager.default.contentsOfDirectory(at: snapshotsURL, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }

        return directories.compactMap { directory in
            let snapshotURL = directory.appendingPathComponent("snapshot.json")
            guard FileManager.default.fileExists(atPath: snapshotURL.path) else {
                diagnostics.append(StorageDiagnostic(
                    code: "snapshotMissing",
                    severity: .warning,
                    path: "snapshots/\(directory.lastPathComponent)/snapshot.json",
                    message: "A snapshot metadata file is missing."
                ))
                return nil
            }
            return decode(SnapshotRecord.self, from: snapshotURL, relativePath: "snapshots/\(directory.lastPathComponent)/snapshot.json", diagnostics: &diagnostics)
        }
        .sorted { $0.createdAt < $1.createdAt }
    }

    private static func write<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    private static func decodeRequired<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        relativePath: String,
        diagnostics: inout [StorageDiagnostic]
    ) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            diagnostics.append(StorageDiagnostic(
                code: "missingRequiredFile",
                severity: .fatal,
                path: relativePath,
                message: "A required package file is missing.",
                recoverySuggestion: "Restore from a snapshot or backup archive."
            ))
            return nil
        }
        return decode(type, from: url, relativePath: relativePath, diagnostics: &diagnostics)
    }

    private static func decodeOptional<T: Decodable>(
        _ type: T.Type,
        from packageURL: URL,
        section: PackageSection?,
        name: String,
        diagnostics: inout [StorageDiagnostic]
    ) -> T? {
        guard let section else {
            return nil
        }

        let url = packageURL.appendingPathComponent(section.path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            if section.required {
                diagnostics.append(StorageDiagnostic(
                    code: "missingRequiredFile",
                    severity: .fatal,
                    path: section.path,
                    message: "A required package section is missing."
                ))
            } else {
                diagnostics.append(StorageDiagnostic(
                    code: "missingOptionalFile",
                    severity: .warning,
                    path: section.path,
                    message: "The optional \(name) section is missing."
                ))
            }
            return nil
        }

        return decode(type, from: url, relativePath: section.path, diagnostics: &diagnostics)
    }

    private static func decode<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        relativePath: String,
        diagnostics: inout [StorageDiagnostic]
    ) -> T? {
        do {
            let data = try Data(contentsOf: url)
            _ = try JSONSerialization.jsonObject(with: data)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch is DecodingError {
            diagnostics.append(StorageDiagnostic(
                code: "invalidSchema",
                severity: .fatal,
                path: relativePath,
                message: "A package file does not match the expected schema."
            ))
            return nil
        } catch {
            diagnostics.append(StorageDiagnostic(
                code: "invalidJSON",
                severity: .fatal,
                path: relativePath,
                message: "A package file could not be read as valid JSON."
            ))
            return nil
        }
    }

    private static func unsupportedMajorVersion(_ version: String) -> Bool {
        let supportedMajor = supportedFormatVersion.split(separator: ".").first
        let versionMajor = version.split(separator: ".").first
        let versionMajorNumber = versionMajor.flatMap { Int($0) } ?? 0
        let supportedMajorNumber = supportedMajor.flatMap { Int($0) } ?? 0
        return versionMajorNumber > supportedMajorNumber
    }
}
