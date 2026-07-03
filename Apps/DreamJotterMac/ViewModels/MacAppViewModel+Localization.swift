import DreamJotterCore
import Foundation

extension MacAppViewModel {
    mutating func requestOpenPackageRespectingLanguage(at packageURL: URL) throws -> ProjectReplacementDecision {
        let decision = try requestOpenPackage(at: packageURL)
        if decision == .replaced {
            currentDocument?.refreshParseRespectingLanguage()
        }
        return decision
    }

    mutating func saveCurrentProjectRespectingLanguage(now: Date = Date()) throws -> SaveRequestResult {
        guard var document = currentDocument else { return .saved }
        guard let packageURL = document.packageURL else { return .requiresSaveAs }
        try document.saveRespectingLanguage(to: packageURL.standardizedFileURL, now: now)
        currentDocument = document
        return .saved
    }

    mutating func saveCurrentProjectRespectingLanguage(
        to packageURL: URL,
        now: Date = Date()
    ) throws -> SaveAsRequestResult {
        guard var document = currentDocument else { return .saved }
        try document.saveRespectingLanguage(to: packageURL.standardizedFileURL, now: now)
        currentDocument = document
        return .saved
    }

    mutating func saveAndConfirmPendingReplacementRespectingLanguage(
        now: Date = Date()
    ) throws -> SaveBeforeReplacementResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        return try ScreenplayParsingContext.$language.withValue(language) {
            try saveAndConfirmPendingReplacement(now: now)
        }
    }

    mutating func saveAndConfirmPendingRestoreRespectingLanguage(
        now: Date = Date()
    ) throws -> SaveBeforeRestoreResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        return try ScreenplayParsingContext.$language.withValue(language) {
            try saveAndConfirmPendingRestore(now: now)
        }
    }

    mutating func restoreBackupRespectingLanguage(
        from data: Data,
        allowReplacingDirtyProject: Bool = false,
        now: Date = Date()
    ) -> RestoreResult {
        let result = restoreBackup(
            from: data,
            allowReplacingDirtyProject: allowReplacingDirtyProject,
            now: now
        )
        if result.status == .restored {
            currentDocument?.refreshParseRespectingLanguage(now: now)
        }
        return result
    }
}
