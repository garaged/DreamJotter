import Foundation

struct ReleaseIdentity: Equatable, Sendable {
    let version: String
    let build: String

    static func current(bundle: Bundle = .main) -> ReleaseIdentity {
        ReleaseIdentity(
            version: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Development",
            build: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "local"
        )
    }
}

struct SupportDiagnostics: Codable, Equatable, Sendable {
    let generatedAt: Date
    let appVersion: String
    let appBuild: String
    let operatingSystem: String
    let architecture: String
    let localeIdentifier: String
    let packageStatus: String
    let recentErrorSummary: String?
    let includesScreenplayContent: Bool
}

enum SupportDiagnosticsBuilder {
    static func make(
        release: ReleaseIdentity = .current(),
        packageURL: URL?,
        recentErrorSummary: String?,
        processInfo: ProcessInfo = .processInfo,
        locale: Locale = .current,
        generatedAt: Date = Date()
    ) -> SupportDiagnostics {
        SupportDiagnostics(
            generatedAt: generatedAt,
            appVersion: release.version,
            appBuild: release.build,
            operatingSystem: processInfo.operatingSystemVersionString,
            architecture: runtimeArchitecture,
            localeIdentifier: locale.identifier,
            packageStatus: packageURL == nil ? "unsaved-or-no-project" : "saved-project-open",
            recentErrorSummary: sanitize(recentErrorSummary),
            includesScreenplayContent: false
        )
    }

    static func encode(_ diagnostics: SupportDiagnostics) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(diagnostics)
    }

    private static func sanitize(_ value: String?) -> String? {
        guard let value else { return nil }
        let collapsed = value
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return collapsed.isEmpty ? nil : String(collapsed.prefix(500))
    }

    private static var runtimeArchitecture: String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }
}

enum PackageRecoveryAction: String, CaseIterable, Equatable, Sendable {
    case exportDiagnostics
    case chooseBackup
    case revealPackage
    case cancel
}

struct PackageRecoveryContext: Equatable, Sendable {
    let packageExists: Bool
    let backupAvailable: Bool
    let packageCanBeRevealed: Bool
}

enum PackageRecoveryPolicy {
    static func actions(for context: PackageRecoveryContext) -> [PackageRecoveryAction] {
        var actions: [PackageRecoveryAction] = [.exportDiagnostics]
        if context.backupAvailable { actions.append(.chooseBackup) }
        if context.packageExists, context.packageCanBeRevealed { actions.append(.revealPackage) }
        actions.append(.cancel)
        return actions
    }

    static func permitsImplicitSourceMutation(_ action: PackageRecoveryAction) -> Bool {
        false
    }
}

enum CrashSafePresentationPolicy {
    static func message(for error: Error, operation: AppErrorSourceOperation) -> String {
        let appError = AppError.wrap(error, operation: operation)
        let message = appError.userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let recovery = appError.recoverySuggestion?.trimmingCharacters(in: .whitespacesAndNewlines)
        return [message, recovery]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")
    }
}

struct LongScriptPerformanceBudget: Equatable, Sendable {
    let elementCount: Int
    let openSeconds: Double
    let editSeconds: Double
    let saveSeconds: Double
    let exportSeconds: Double

    static let releaseGate = LongScriptPerformanceBudget(
        elementCount: 10_000,
        openSeconds: 5,
        editSeconds: 0.2,
        saveSeconds: 5,
        exportSeconds: 15
    )

    func accepts(open: Double, edit: Double, save: Double, export: Double) -> Bool {
        open <= openSeconds && edit <= editSeconds && save <= saveSeconds && export <= exportSeconds
    }
}

extension Notification.Name {
    static let dreamJotterExportDiagnostics = Notification.Name("DreamJotterExportDiagnostics")
}
